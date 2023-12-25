import pyodbc
from faker import Faker
from random import sample, choice, randrange, random

class StudentModule:
    student_id: int
    module_id: int

    def __init__(self, student_id, module_id):
        self.student_id = student_id
        self.module_id = module_id

class StudentMeeting:
    student_id: int
    meeting_id: int

    def __init__(self, student_id, meeting_id):
        self.student_id = student_id
        self.meeting_id = meeting_id

class PassesAndPresenceFactory:
    cursor: pyodbc.Cursor
    schema: str
    fake: Faker

    student_modules: list[StudentModule]
    student_meetings: list[StudentMeeting]
    products: list[int]

    def __init__(self, cursor: pyodbc.Cursor, schema: str):
        self.cursor = cursor
        self.schema = schema
        self.fake = Faker("pl_PL")

        cursor.execute(f"""
            SELECT {schema}.orders.student_id, {schema}.study_modules.activity_id
            FROM {schema}.order_details
                JOIN {schema}.orders ON {schema}.order_details.order_id = {schema}.orders.id
                JOIN {schema}.studies ON {schema}.order_details.product_id = {schema}.studies.activity_id
                JOIN {schema}.study_modules ON {schema}.studies.activity_id = {schema}.study_modules.study_id
        """)

        self.student_modules = list(map(lambda x: StudentModule(x[0], x[1]), cursor.fetchall()))

        cursor.execute(f"""
            SELECT {schema}.orders.student_id, {schema}.study_meetings.meeting_id
            FROM {schema}.order_details
                JOIN {schema}.orders ON {schema}.order_details.order_id = {schema}.orders.id
                JOIN {schema}.studies ON {schema}.order_details.product_id = {schema}.studies.activity_id
                JOIN {schema}.study_modules ON {schema}.studies.activity_id = {schema}.study_modules.study_id
                JOIN {schema}.study_meetings ON {schema}.study_modules.activity_id = {schema}.study_meetings.module_id
            UNION
            SELECT orders.student_id, module_meetings.meeting_id
            FROM {schema}.order_details
                JOIN {schema}.orders ON {schema}.order_details.order_id = {schema}.orders.id
                JOIN {schema}.courses ON {schema}.order_details.product_id = {schema}.courses.activity_id
                JOIN {schema}.course_modules ON {schema}.courses.activity_id = {schema}.course_modules.course_id
                JOIN {schema}.module_meetings ON {schema}.course_modules.activity_id = {schema}.module_meetings.module_id
            UNION
            SELECT orders.student_id, meetings.activity_id
            FROM {schema}.order_details
                JOIN {schema}.orders ON {schema}.order_details.order_id = {schema}.orders.id
                JOIN {schema}.meetings ON {schema}.order_details.product_id = {schema}.meetings.activity_id
        """)

        self.student_meetings = list(map(lambda x: StudentMeeting(x[0], x[1]), cursor.fetchall()))

        cursor.execute(f"""
            SELECT {schema}.courses.activity_id
            FROM {schema}.courses
                JOIN {schema}.products ON {schema}.courses.activity_id = {schema}.products.activity_id
            UNION
            SELECT {schema}.meetings.activity_id
            FROM {schema}.meetings
                JOIN {schema}.products ON {schema}.meetings.activity_id = {schema}.products.activity_id
        """)

        self.products = list(map(lambda x: x[0], cursor.fetchall()))

    def generate_passes(self, ratio: float):
        passes = sample(self.student_modules, round(len(self.student_modules) * ratio))

        print(f"Generating passes... ({len(passes)})")

        for student_module in passes:
            self.cursor.execute(f"""
                INSERT INTO {self.schema}.study_module_passes (student_id, module_id)
                VALUES (?, ?)
            """, student_module.student_id, student_module.module_id)

    def generate_presence(self, presence_ratio: float, presence_makeup_ratio: float):
        presence = sample(self.student_meetings, round(len(self.student_meetings) * presence_ratio))

        print(f"Generating presence... ({len(presence)})")

        for student_meeting in presence:
            self.cursor.execute(f"""
                INSERT INTO {self.schema}.meeting_presence (student_id, meeting_id)
                VALUES (?, ?)
            """, student_meeting.student_id, student_meeting.meeting_id)

            if random() < presence_makeup_ratio:
                make_up_activity_id = choice([i for i in self.products if i != student_meeting.meeting_id])

                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.meeting_presence_make_up (student_id, meeting_id, activity_id)
                    VALUES (?, ?, ?)
                """, student_meeting.student_id, student_meeting.meeting_id, make_up_activity_id)
