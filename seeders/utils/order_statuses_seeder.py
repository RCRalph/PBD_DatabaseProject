import pyodbc, json

def seed_order_statuses(cursor: pyodbc.Cursor, schema: str):
    print("Seeding order_statuses...")

    cursor.execute(f"""
        SELECT name
        FROM {schema}.order_statuses
    """)

    order_statuses = set(map(lambda x: x[0], cursor.fetchall()))

    with open("seeders/data/order_statuses.json") as file:
        data = json.load(file)

        for order_status in data:
            if order_status not in order_statuses:
                cursor.execute(f"""
                    INSERT INTO {schema}.order_statuses (name)
                    VALUES (?)
                """, order_status)

        print(len(data))
