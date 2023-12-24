import pyodbc
from random import randrange

def seed_rooms(cursor: pyodbc.Cursor, schema: str):
    print("Seeding rooms...")

    cursor.execute(f"""
        SELECT COUNT(*)
        FROM {schema}.rooms
    """)

    result = cursor.fetchone()
    if result is None:
        raise ValueError()

    row_count = result[0]

    if row_count:
        print(f"Already in the database ({row_count})")
        return

    room_count, rooms_per_floor = randrange(25, 75), randrange(5, 15)

    for i in range(room_count):
        cursor.execute(f"""
            INSERT INTO {schema}.rooms (room_name, place_limit)
            VALUES (?, ?)
        """, f"{i // rooms_per_floor + 1}.{i % rooms_per_floor + 1}", randrange(25, 150))

    print(room_count)
