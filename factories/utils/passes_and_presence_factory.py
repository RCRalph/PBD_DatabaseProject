import pyodbc
from faker import Faker
from random import sample, choice, random

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
            SELECT DISTINCT {schema}.orders.student_id, {schema}.study_modules.activity_id
            FROM {schema}.order_details
                JOIN {schema}.orders ON {schema}.order_details.order_id = {schema}.orders.id
                JOIN {schema}.studies ON {schema}.order_details.product_id = {schema}.studies.activity_id
                JOIN {schema}.study_modules ON {schema}.studies.activity_id = {schema}.study_modules.study_id
            WHERE NOT EXISTS (
                SELECT {schema}.study_module_passes.student_id, {schema}.study_module_passes.module_id
                FROM {schema}.study_module_passes
                WHERE {schema}.study_module_passes.student_id = {schema}.orders.student_id
                    AND {schema}.study_module_passes.module_id = {schema}.study_modules.activity_id
            )
        """)

        self.student_modules = list(map(lambda x: StudentModule(x[0], x[1]), cursor.fetchall()))

        cursor.execute(f"""
            WITH meeting_students (student_id, meeting_id) AS (
                SELECT {schema}.orders.student_id, {schema}.study_meetings.meeting_id
                FROM {schema}.order_details
                    JOIN {schema}.orders ON {schema}.order_details.order_id = {schema}.orders.id
                    JOIN {schema}.studies ON {schema}.order_details.product_id = {schema}.studies.activity_id
                    JOIN {schema}.study_modules ON {schema}.studies.activity_id = {schema}.study_modules.study_id
                    JOIN {schema}.study_meetings ON {schema}.study_modules.activity_id = {schema}.study_meetings.module_id
                UNION
                SELECT {schema}.orders.student_id, {schema}.module_meetings.meeting_id
                FROM order_details
                    JOIN {schema}.orders ON {schema}.order_details.order_id = {schema}.orders.id
                    JOIN {schema}.courses ON {schema}.order_details.product_id = {schema}.courses.activity_id
                    JOIN {schema}.course_modules ON {schema}.courses.activity_id = {schema}.course_modules.course_id
                    JOIN {schema}.module_meetings ON {schema}.course_modules.activity_id = {schema}.module_meetings.module_id
                UNION
                SELECT {schema}.orders.student_id, {schema}.meetings.activity_id
                FROM order_details
                    JOIN {schema}.orders ON {schema}.order_details.order_id = {schema}.orders.id
                    JOIN {schema}.meetings ON {schema}.order_details.product_id = {schema}.meetings.activity_id
            )

            SELECT meeting_students.student_id, meeting_students.meeting_id
            FROM meeting_students
            WHERE NOT EXISTS (
                SELECT {schema}.meeting_presence.student_id, {schema}.meeting_presence.meeting_id
                FROM {schema}.meeting_presence
                WHERE {schema}.meeting_presence.student_id = meeting_students.student_id
                    AND {schema}.meeting_presence.meeting_id = meeting_students.meeting_id
            )
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

    def generate_passes(self):
        print(f"Generating passes... ({len(self.student_modules)})")

        for student_module in self.student_modules:
            try:
                self.cursor.execute(
                    f"EXEC {self.schema}.give_student_module_pass ?, ?;",
                    student_module.module_id, student_module.student_id
                )
            except Exception: pass

    def generate_presence(self, presence_ratio: float, presence_makeup_ratio: float):
        presence = sample(self.student_meetings, round(len(self.student_meetings) * presence_ratio))

        print(f"Generating presence... ({len(presence)})")

        for student_meeting in presence:
            if random() < presence_makeup_ratio:
                make_up_activity_id = choice([i for i in self.products if i != student_meeting.meeting_id])

                self.cursor.execute(
                    f"EXEC {self.schema}.set_student_conditional_presence ?, ?;",
                    student_meeting.meeting_id, student_meeting.student_id, make_up_activity_id
                )
            else:
                self.cursor.execute(
                    f"EXEC {self.schema}.register_student_presence ?, ?;",
                    student_meeting.meeting_id, student_meeting.student_id
                )
