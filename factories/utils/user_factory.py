import pyodbc, random
from faker import Faker
from hashlib import sha256

class UserFactory:
    cursor: pyodbc.Cursor
    schema: str
    fake: Faker
    languages: list[int]
    polish_cities: list[int]
    foreign_cities: list[int]

    def __init__(self, cursor: pyodbc.Cursor, schema: str):
        self.cursor = cursor
        self.schema = schema
        self.fake = Faker("pl_PL")

        cursor.execute(f"""
            SELECT id
            FROM {schema}.languages
        """)

        self.languages = list(map(lambda x: x[0], cursor.fetchall()))

        cursor.execute(f"""
            SELECT cities.id
            FROM {schema}.cities
            JOIN {schema}.countries ON {schema}.cities.country_id = {schema}.countries.id
            WHERE {schema}.countries.name LIKE 'Polska'
        """)

        self.polish_cities = list(map(lambda x: x[0], cursor.fetchall()))

        cursor.execute(f"""
            SELECT cities.id
            FROM {schema}.cities
            JOIN {schema}.countries ON {schema}.cities.country_id = {schema}.countries.id
            WHERE {schema}.countries.name NOT LIKE 'Polska'
        """)

        self.foreign_cities = list(map(lambda x: x[0], cursor.fetchall()))

    def generate_user_data(self):
        email = self.fake.unique.email()
        password = sha256(self.fake.password().encode("utf-8")).hexdigest()
        first_name = self.fake.first_name()
        last_name = self.fake.last_name()
        phone = self.fake.phone_number().replace(" ", "") if random.randrange(5) < 2 else None

        return (email, password, first_name, last_name, phone)

    def generate_students(self, count: int):
        print(f"Generating students... ({count})")

        for _ in range(count):
            self.cursor.execute(f"""
                DECLARE @user_id INT;
                EXEC {self.schema}.create_student ?, ?, ?, ?, ?, @user_id OUTPUT;
                SELECT @user_id;
            """, *self.generate_user_data())

            result = self.cursor.fetchone()
            if result is None:
                raise ValueError()

            user_id = result[0]

            if random.randrange(5) < 3:
                street = self.fake.street_address()
                zip_code = "".join(random.choice("0123456789") for _ in range(5))
                city_id = random.choice(self.polish_cities if random.randrange(10) < 8 else self.foreign_cities)

                self.cursor.execute(f"""
                    EXEC {self.schema}.assign_address_to_student ?, ?, ?, ?;
                """, user_id, street, zip_code, city_id)

    def generate_tutors(self, count: int):
        print(f"Generating tutors... ({count})")

        for _ in range(count):
            self.cursor.execute(f"""
                DECLARE @user_id INT;
                EXEC {self.schema}.create_tutor ?, ?, ?, ?, ?, @user_id OUTPUT;
                SELECT @user_id;
            """, *self.generate_user_data())

    def generate_coordinators(self, count: int):
        print(f"Generating coordinators... ({count})")

        for _ in range(count):
            self.cursor.execute(f"""
                DECLARE @user_id INT;
                EXEC {self.schema}.create_coordinator ?, ?, ?, ?, ?, @user_id OUTPUT;
                SELECT @user_id;
            """, *self.generate_user_data())

    def generate_translators(self, count: int):
        print(f"Generating translators... ({count})")

        for _ in range(count):
            self.cursor.execute(f"""
                DECLARE @user_id INT;
                EXEC {self.schema}.create_translator ?, ?, ?, ?, ?, @user_id OUTPUT;
                SELECT @user_id;
            """, *self.generate_user_data())

            result = self.cursor.fetchone()
            if result is None:
                raise ValueError()

            user_id = result[0]

            for language_id in random.sample(self.languages, random.randrange(5) + 1):
                self.cursor.execute(f"""
                    EXEC {self.schema}.assign_language_to_translator ?, ?;
                """, user_id, language_id)
