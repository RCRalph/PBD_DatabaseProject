import pyodbc
from faker import Faker
from random import sample, choice, randrange

class TranslationFactory:
    cursor: pyodbc.Cursor
    schema: str
    fake: Faker

    meetings: list[int]
    languages: dict[int, list[int]]

    def __init__(self, cursor: pyodbc.Cursor, schema: str):
        self.cursor = cursor
        self.schema = schema
        self.fake = Faker("pl_PL")

        cursor.execute(f"""
            SELECT activity_id
            FROM {schema}.meetings
            WHERE activity_id NOT IN (
                SELECT {schema}.meeting_translators.meeting_id
                FROM {schema}.meeting_translators
            )
        """)

        self.meetings = list(map(lambda x: x[0], cursor.fetchall()))

        cursor.execute(f"""
            SELECT translator_id, language_id
            FROM {schema}.translators_languages
        """)

        self.languages = {}
        for translator_id, language_id in cursor.fetchall():
            if language_id in self.languages:
                self.languages[language_id].append(translator_id)
            else:
                self.languages[language_id] = [translator_id]

    def generate_translations(self, ratio: float):
        meeting_ids = sample(self.meetings, int(len(self.meetings) * ratio))

        print(f"Generating translations... ({len(meeting_ids)})")

        for meeting_id in meeting_ids:
            # English most common language
            language_id = 6 if randrange(100) else choice(list(self.languages.keys()))
            translator_id = choice(self.languages[language_id])

            self.cursor.execute(f"""
                EXEC {self.schema}.assign_language_to_meeting ?, ?, ?;
            """, meeting_id, language_id, translator_id)


