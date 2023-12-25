import pyodbc
from faker import Faker
from random import sample, choice, randrange
from datetime import datetime, timedelta

class Product:
    id: int
    price: int

    def __init__(self, id, price):
        self.id = id
        self.price = price

class OrderFactory:
    cursor: pyodbc.Cursor
    schema: str
    fake: Faker

    products: list[Product]
    students: list[int]
    statuses: list[int]

    def __init__(self, cursor: pyodbc.Cursor, schema: str):
        self.cursor = cursor
        self.schema = schema
        self.fake = Faker("pl_PL")

        cursor.execute(f"""
            SELECT activity_id, price
            FROM {schema}.products
        """)

        self.products = list(map(lambda x: Product(x[0], x[1]), cursor.fetchall()))

        cursor.execute(f"""
            SELECT user_id
            FROM {schema}.students
        """)

        self.students = list(map(lambda x: x[0], cursor.fetchall()))

        cursor.execute(f"""
            SELECT id
            FROM {schema}.order_statuses
        """)

        self.statuses = list(map(lambda x: x[0], cursor.fetchall()))

    def generate_shopping_cart(self, count: int):
        print(f"Generating shopping cart... ({count})")

        cart_set = set()
        while len(cart_set) < count:
            cart_set.add((choice(self.products).id, choice(self.students)))

        for product_id, student_id in cart_set:
            self.cursor.execute(f"""
                INSERT INTO {self.schema}.shopping_cart (product_id, student_id)
                VALUES (?, ?)
            """, product_id, student_id)

    def generate_order(self):
        student_id = choice(self.students)
        payment_url = self.fake.unique.uri()
        order_date = datetime.today() - timedelta(days=randrange(3650))

        self.cursor.execute(f"""
            INSERT INTO {self.schema}.orders (student_id, payment_url, order_date)
            VALUES (?, ?, ?)
        """, student_id, payment_url, order_date)

        self.cursor.execute("SELECT @@IDENTITY;")

        result = self.cursor.fetchone()
        if result is None:
            raise ValueError()

        return result[0]

    def generate_orders(self, count: int):
        print(f"Generating orders... ({count})")

        for _ in range(count):
            order_id = self.generate_order()
            products = sample(self.products, randrange(1, 10))
            status_id = choice(self.statuses)

            for product in products:
                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.order_details (order_id, product_id, price, status_id)
                    VALUES (?, ?, ?, ?)
                """, order_id, product.id, product.price, status_id)
