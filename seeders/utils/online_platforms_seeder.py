import pyodbc, json

def seed_online_platforms(cursor: pyodbc.Cursor, schema: str):
    print("Seeding online_platforms...")

    cursor.execute(f"""
        SELECT name
        FROM {schema}.online_platforms
    """)

    online_platforms = set(map(lambda x: x[0], cursor.fetchall()))

    with open("seeders/data/online_platforms.json") as file:
        data = json.load(file)

        for online_platform in data:
            if online_platform not in online_platforms:
                cursor.execute(f"""
                    INSERT INTO {schema}.online_platforms (name)
                    VALUES (?)
                """, online_platform)

        print(len(data))
