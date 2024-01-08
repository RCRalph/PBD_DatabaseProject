import pyodbc
from faker import Faker
from random import randrange, choice, sample
from datetime import datetime, timedelta

class Room:
    id: int
    place_limit: int

    def __init__(self, id, place_limit):
        self.id = id
        self.place_limit = place_limit

class ActivityFactory:
    cursor: pyodbc.Cursor
    schema: str
    fake: Faker

    tutors: list[int]
    coordinators: list[int]
    online_platforms: list[int]
    rooms: list[Room]

    meeting_types = ["on_site_meetings", "online_asynchronous_meetings", "online_synchronous_meetings"]

    def __init__(self, cursor: pyodbc.Cursor, schema: str):
        self.cursor = cursor
        self.schema = schema
        self.fake = Faker("pl_PL")

        cursor.execute(f"""
            SELECT user_id
            FROM {schema}.tutors
        """)

        self.tutors = list(map(lambda x: x[0], cursor.fetchall()))

        cursor.execute(f"""
            SELECT user_id
            FROM {schema}.coordinators
        """)

        self.coordinators = list(map(lambda x: x[0], cursor.fetchall()))

        cursor.execute(f"""
            SELECT id
            FROM {schema}.online_platforms
        """)

        self.online_platforms = list(map(lambda x: x[0], cursor.fetchall()))

        cursor.execute(f"""
            SELECT id, place_limit
            FROM {schema}.rooms
            ORDER BY place_limit
        """)

        self.rooms = [Room(item[0], item[1]) for item in cursor.fetchall()]

    def generate_activity_data(self):
        title = None
        while not title or len(title) > 128:
            title = self.fake.unique.sentence()[:-1]

        description = self.fake.sentence()

        return (title, description)

    def generate_webinars(self, count: int):
        print(f"Generating webinars... ({count})")

        for _ in range(count):
            tutor_id = choice(self.tutors)
            platform_id = choice(self.online_platforms)
            start_time = datetime.today() - timedelta(
                days=randrange(-365, 365),
                hours=randrange(8, 17),
                minutes=randrange(4)*15
            )
            end_time = start_time + timedelta(hours=randrange(3), minutes=randrange(2) * 30)
            price = max(round(randrange(11000) / 100, 2) - 10, 0)

            self.cursor.execute(f"""
                DECLARE @webinar_id INT;
                EXEC {self.schema}.create_webinar ?, ?, ?, ?, ?, ?, ?, @webinar_id OUTPUT;
                SELECT @webinar_id;
            """, *self.generate_activity_data(), tutor_id, platform_id, start_time, end_time, price)

            result = self.cursor.fetchone()
            if result is None:
                raise ValueError()

            webinar_id = result[0]

            if datetime.now() + timedelta(days=30) > start_time:
                meeting_url = self.fake.unique.uri()

                self.cursor.execute(
                    f"EXEC {self.schema}.update_webinar_meeting_url ?, ?;",
                    webinar_id, meeting_url
                )

            if datetime.now() > end_time:
                recording_url = self.fake.unique.uri()

                self.cursor.execute(
                    f"EXEC {self.schema}.update_webinar_recording_url ?, ?;",
                    webinar_id, recording_url
                )

    def generate_random_meeting_times(self, start_date: datetime, end_date: datetime, n: int):
        def check_conflict(meeting_times, new_start, new_end):
            for start, end in meeting_times:
                if new_start < end and new_end > start:
                    return True

            return False

        meeting_times = []
        date_range = (end_date - start_date).days + 1

        for _ in range(n):
            while True:
                random_day = randrange(date_range)
                selected_date = start_date + timedelta(days=random_day)

                start_time = datetime(
                    selected_date.year, selected_date.month, selected_date.day,
                    randrange(8, 17), randrange(4) * 15
                )

                duration = timedelta(hours=randrange(1, 4))

                end_time = start_time + duration

                if not check_conflict(meeting_times, start_time, end_time):
                    meeting_times.append((start_time, end_time))
                    break

        return meeting_times

    def generate_courses(self, count: int):
        print(f"Generating courses... ({count})")

        for _ in range(count):
            coordinator_id = choice(self.coordinators)
            price = round(randrange(10000) / 100, 2)

            self.cursor.execute(f"""
                DECLARE @course_id INT;
                EXEC {self.schema}.create_course ?, ?, ?, ?, @course_id OUTPUT;
                SELECT @course_id;
            """, *self.generate_activity_data(), coordinator_id, price)

            result = self.cursor.fetchone()
            if result is None:
                raise ValueError()

            course_id = result[0]

            module_count = randrange(3, 10)
            start_date = datetime.today() - timedelta(days=randrange(-365, 365))
            total_meeting_count = randrange(module_count * 2, module_count * 4)
            end_date = start_date + timedelta(days=randrange(total_meeting_count // 5, total_meeting_count) + 1)

            meeting_times = self.generate_random_meeting_times(start_date, end_date, total_meeting_count)

            custom_breakpoints = sorted(sample(range(0, len(meeting_times) + 1), module_count))

            if 0 not in custom_breakpoints:
                custom_breakpoints.insert(0, 0)
            if len(meeting_times) not in custom_breakpoints:
                custom_breakpoints.append(len(meeting_times))

            subranges = [(custom_breakpoints[i], custom_breakpoints[i + 1]) for i in range(len(custom_breakpoints) - 1)]

            for (i, j) in subranges:
                self.cursor.execute(f"""
                    DECLARE @module_id INT;
                    EXEC {self.schema}.create_course_module ?, ?, ?, @module_id OUTPUT;
                    SELECT @course_id;
                """, course_id, *self.generate_activity_data())

                result = self.cursor.fetchone()
                if result is None:
                    raise ValueError()

                module_id = result[0]
                module_type = choice(self.meeting_types + ["hybrid"])

                for (start_time, end_time) in meeting_times[i:j]:
                    tutor_id = choice(self.tutors)

                    match choice(self.meeting_types) if module_type == "hybrid" else module_type:
                        case "on_site_meetings":
                            room_id = choice(list(map(lambda x: x.id, self.rooms)))

                            self.cursor.execute(
                                f"""
                                    DECLARE @meeting_id INT;
                                    EXEC {self.schema}.create_course_module_on_site_meeting
                                        ?, ?, ?, ?, ?, ?, ?, @meeting_id OUTPUT;
                                """,
                                module_id, *self.generate_activity_data(),
                                tutor_id, room_id, start_time, end_time
                            )

                        case "online_asynchronous_meetings":
                            recording_url = self.fake.unique.uri()

                            self.cursor.execute(
                                f"""
                                    DECLARE @meeting_id INT;
                                    EXEC {self.schema}.create_course_module_online_asynchronous_meeting
                                        ?, ?, ?, ?, ?, @meeting_id OUTPUT;
                                """,
                                module_id, *self.generate_activity_data(),
                                tutor_id, recording_url
                            )

                        case "online_synchronous_meetings":
                            platform_id = choice(self.online_platforms)

                            self.cursor.execute(
                                f"""
                                    DECLARE @meeting_id INT;
                                    EXEC {self.schema}.create_course_module_online_synchronous_meeting
                                        ?, ?, ?, ?, ?, ?, ?, @meeting_id OUTPUT;
                                    SELECT @meeting_id;
                                """,
                                module_id, *self.generate_activity_data(),
                                tutor_id, platform_id, start_time, end_time
                            )

                            result = self.cursor.fetchone()
                            if result is None:
                                raise ValueError()

                            meeting_id = result[0]

                            if datetime.now() + timedelta(days=30) > start_time:
                                meeting_url = self.fake.unique.uri()

                                self.cursor.execute(
                                    f"EXEC {self.schema}.update_course_module_online_synchronous_meeting_url ?, ?;",
                                    meeting_id, meeting_url
                                )

                            if datetime.now() > end_time:
                                recording_url = self.fake.unique.uri()

                                self.cursor.execute(
                                    f"EXEC {self.schema}.update_course_module_online_synchronous_meeting_recording_url ?, ?;",
                                    meeting_id, recording_url
                                )

    def generate_study_modules(self, study_id):
        module_ids = []

        for _ in range(randrange(4, 8)):
            coordinator_id = choice(self.coordinators)

            self.cursor.execute(f"""
                DECLARE @module_id INT;
                EXEC {self.schema}.create_study_module ?, ?, ?, ?, @module_id OUTPUT;
                SELECT @module_id;
            """, study_id, *self.generate_activity_data(), coordinator_id)

            result = self.cursor.fetchone()
            if result is None:
                raise ValueError()

            module_ids.append(result[0])

        return module_ids

    def generate_study_sessions(self, study_id, rooms: list[Room]):
        def study_session_end_time(start: datetime):
            return start + timedelta(days=2, hours=8)

        start_date = datetime(randrange(2020, 2025), 9, 1)
        semesters = []
        for _ in range(randrange(3, 6)):
            semesters.append((start_date, start_date + timedelta(6 * 30)))
            start_date = start_date.replace(year=start_date.year + 1)
            semesters.append((start_date - timedelta(6 * 30), start_date))

        for (start, end) in semesters:
            module_ids = self.generate_study_modules(study_id)
            start_time = start + timedelta(days=(4 - start.weekday() + 7) % 7, hours=8)

            while study_session_end_time(start_time + timedelta(weeks=2)) < end:
                price = round(randrange(10000) / 100, 2)

                self.cursor.execute(f"""
                    DECLARE @session_id INT;
                    EXEC {self.schema}.create_study_session ?, ?, ?, ?, @session_id OUTPUT;
                    SELECT @session_id;
                """, study_id, *self.generate_activity_data(), price)

                result = self.cursor.fetchone()
                if result is None:
                    raise ValueError()

                session_id = result[0]

                meeting_times = self.generate_random_meeting_times(
                    start_time,
                    study_session_end_time(start_time),
                    randrange(5, 10)
                )

                for (meeting_start, meeting_end) in meeting_times:
                    tutor_id = choice(self.tutors)
                    module_id = choice(module_ids)
                    price = round(randrange(10000) / 100, 2)

                    match choice(self.meeting_types):
                        case "on_site_meetings":
                            room_id = choice(list(map(lambda x: x.id, rooms)))

                            self.cursor.execute(
                                f"""
                                    DECLARE @meeting_id INT;
                                    EXEC {self.schema}.create_study_on_site_meeting
                                        ?, ?, ?, ?, ?, ?, ?, @meeting_id OUTPUT;
                                """,
                                module_id, session_id, *self.generate_activity_data(),
                                tutor_id, room_id, meeting_start, meeting_end, price
                            )

                        case "online_asynchronous_meetings":
                            recording_url = self.fake.unique.uri()

                            self.cursor.execute(
                                f"""
                                    DECLARE @meeting_id INT;
                                    EXEC {self.schema}.create_study_online_asynchronous_meeting
                                        ?, ?, ?, ?, ?, @meeting_id OUTPUT;
                                """,
                                module_id, session_id, *self.generate_activity_data(),
                                tutor_id, recording_url, price
                            )

                        case "online_synchronous_meetings":
                            platform_id = choice(self.online_platforms)

                            self.cursor.execute(
                                f"""
                                    DECLARE @meeting_id INT;
                                    EXEC {self.schema}.create_study_online_synchronous_meeting
                                        ?, ?, ?, ?, ?, ?, ?, @meeting_id OUTPUT;
                                    SELECT @meeting_id;
                                """,
                                module_id, session_id, *self.generate_activity_data(),
                                tutor_id, platform_id, meeting_start, meeting_end, price
                            )

                            result = self.cursor.fetchone()
                            if result is None:
                                raise ValueError()

                            meeting_id = result[0]

                            if datetime.now() + timedelta(days=30) > meeting_start:
                                meeting_url = self.fake.unique.uri()

                                self.cursor.execute(
                                    f"EXEC {self.schema}.update_study_online_synchronous_meeting_url ?, ?;",
                                    meeting_id, meeting_url
                                )

                            if datetime.now() > meeting_end:
                                recording_url = self.fake.unique.uri()

                                self.cursor.execute(
                                    f"EXEC {self.schema}.update_study_online_synchronous_meeting_recording_url ?, ?;",
                                    meeting_id, recording_url
                                )

                start_time += timedelta(weeks=2)

            price = round(randrange(10000) / 100, 2)
            self.cursor.execute(f"""
                DECLARE @session_id INT;
                EXEC {self.schema}.create_study_session ?, ?, ?, ?, @session_id OUTPUT;
                SELECT @session_id;
            """, study_id, *self.generate_activity_data(), price)

            result = self.cursor.fetchone()
            if result is None:
                raise ValueError()

            internship_session_id = result[0]

            internship_coordinator_id = choice(self.coordinators)
            self.cursor.execute(f"""
                DECLARE @module_id INT;
                EXEC {self.schema}.create_study_module ?, ?, ?, ?, @module_id OUTPUT;
                SELECT @module_id;
            """, study_id, *self.generate_activity_data(), internship_coordinator_id)

            result = self.cursor.fetchone()
            if result is None:
                raise ValueError()

            internship_module_id = result[0]

            meeting_times = self.generate_random_meeting_times(
                start_time,
                study_session_end_time(start_time),
                randrange(5, 10)
            )

            for (meeting_start, meeting_end) in meeting_times:
                tutor_id = choice(self.tutors)

                self.cursor.execute(
                    f"""
                        DECLARE @meeting_id INT;
                        EXEC {self.schema}.create_study_internship_meeting ?, ?, ?, ?, ?, ?, ?, @meeting_id OUTPUT;
                    """,
                    internship_module_id, internship_session_id, *self.generate_activity_data(),
                    tutor_id, meeting_start, meeting_end
                )

    def generate_studies(self, count: int):
        print(f"Generating studies... ({count})")

        for _ in range(count):
            price = round(randrange(10000) / 100, 2) + 100
            place_limit = randrange(self.rooms[0].place_limit, self.rooms[-1].place_limit)

            self.cursor.execute(f"""
                DECLARE @study_id INT;
                EXEC {self.schema}.create_study ?, ?, ?, ?, @study_id OUTPUT;
                SELECT @study_id;
            """, *self.generate_activity_data(), price, place_limit)

            result = self.cursor.fetchone()
            if result is None:
                raise ValueError()

            study_id = result[0]

            rooms_smallest_index = 0
            for rooms_smallest_index, room in enumerate(self.rooms):
                if room.place_limit >= place_limit:
                    break

            self.generate_study_sessions(study_id, self.rooms[rooms_smallest_index:])
