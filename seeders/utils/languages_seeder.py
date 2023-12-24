import pyodbc, json

def seed_languages(cursor: pyodbc.Cursor, schema: str):
    print("Seeding languages...")

    cursor.execute(f"""
        SELECT name
        FROM {schema}.languages
    """)

    languages = set(map(lambda x: x[0], cursor.fetchall()))

    with open("seeders/data/languages.json") as file:
        data = json.load(file)

        for language in data:
            if language not in languages:
                cursor.execute(f"""
                    INSERT INTO {schema}.languages (name)
                    VALUES (?)
                """, language)

        print(len(data))
