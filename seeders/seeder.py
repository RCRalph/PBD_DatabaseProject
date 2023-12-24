import os, pyodbc
from dotenv import load_dotenv

from utils.advance_payments_seeder import seed_advance_payments
from utils.cities_and_countries_seeder import seed_cities_and_countries
from utils.languages_seeder import seed_languages
from utils.online_platforms_seeder import seed_online_platforms
from utils.order_statuses_seeder import seed_order_statuses
from utils.rooms_seeder import seed_rooms

load_dotenv()

connection_string = ";".join([
    f"SERVER={os.getenv('DB_SERVER')}",
    f"DATABASE={os.getenv('DB_DATABASE')}",
    f"UID={os.getenv('DB_USERNAME')}",
    f"PWD={os.getenv('DB_PASSWORD')}",
    "DRIVER={ODBC Driver 18 for SQL Server}",
    "ENCRYPT=NO",
    "CHARSET=UTF8",
])

schema = os.getenv('SCHEMA_NAME')
if schema is None:
    raise KeyError()

seeders = [
    seed_advance_payments,
    seed_cities_and_countries,
    seed_languages,
    seed_online_platforms,
    seed_order_statuses,
    seed_rooms
]

with pyodbc.connect(connection_string, autocommit=True) as connection:
    cursor = connection.cursor()

    for seeder in seeders:
        seeder(cursor, schema)
        print()
