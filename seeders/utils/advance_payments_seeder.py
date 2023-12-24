import pyodbc
from datetime import datetime, timedelta
from random import randrange, uniform, sample

def seed_advance_payments(cursor: pyodbc.Cursor, schema: str):
    print("Seeding advance payments...")

    cursor.execute(f"""
        SELECT COUNT(*)
        FROM {schema}.advance_payments
    """)

    result = cursor.fetchone()
    if result is None:
        raise ValueError()

    row_count = result[0]

    if row_count:
        print(f"Already in the database ({row_count})")
        return

    start_date = datetime.today() - timedelta(days=3650)
    end_date = datetime.today() - timedelta(days=randrange(10, 100))
    date_range = end_date - start_date

    date_deltas = sample(range(date_range.days), randrange(20, 40))
    date_deltas.sort()

    random_dates = [(start_date + timedelta(days)).strftime("%Y-%m-%d") for days in date_deltas]

    for i in range(len(random_dates)):
        advance_start_date = random_dates[i]
        advance_end_date = random_dates[i + 1] if i + 1 < len(random_dates) else None

        cursor.execute(f"""
            INSERT INTO {schema}.advance_payments (start_date, end_date, value)
            VALUES (?, ?, ?)
        """, advance_start_date, advance_end_date, round(uniform(0, 0.3), 3))

    print(random_dates[0], random_dates[-1], len(random_dates))

