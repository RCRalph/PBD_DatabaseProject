import os, pyodbc
from dotenv import load_dotenv

from utils.user_factory import UserFactory
from utils.activity_factory import ActivityFactory
from utils.translation_factory import TranslationFactory
from utils.order_factory import OrderFactory
from utils.passes_and_presence_factory import PassesAndPresenceFactory

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

with pyodbc.connect(connection_string, autocommit=True) as connection:
    cursor = connection.cursor()

    user_factory = UserFactory(cursor, schema)
    user_factory.generate_students(900)
    user_factory.generate_tutors(60)
    user_factory.generate_coordinators(25)
    user_factory.generate_translators(15)

    activity_factory = ActivityFactory(cursor, schema)
    activity_factory.generate_webinars(2500)
    activity_factory.generate_courses(250)
    activity_factory.generate_studies(50)

    translation_factory = TranslationFactory(cursor, schema)
    translation_factory.generate_translations(0.1)

    order_factory = OrderFactory(cursor, schema)
    order_factory.generate_shopping_cart(10000)
    order_factory.generate_orders(5000)

    passes_and_presence_factory = PassesAndPresenceFactory(cursor, schema)
    passes_and_presence_factory.generate_passes(0.95)
    passes_and_presence_factory.generate_presence(0.95, 0.05)
