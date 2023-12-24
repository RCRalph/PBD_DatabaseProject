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

    def generate_activity(self):
        title = None
        while not title or len(title) > 128:
            title = self.fake.unique.sentence()[:-1]

        description = self.fake.paragraph()

        self.cursor.execute(f"""
            INSERT INTO {self.schema}.activities (title, description)
            VALUES (?, ?)
        """, title, description)

        self.cursor.execute("SELECT @@IDENTITY;")

        result = self.cursor.fetchone()
        if result is None:
            raise ValueError()

        return result[0]

    def generate_webinars(self, count: int):
        print(f"Generating webinars... ({count})")

        for _ in range(count):
            activity_id = self.generate_activity()

            tutor_id = choice(self.tutors)

            self.cursor.execute(f"""
                INSERT INTO {self.schema}.meetings (activity_id, tutor_id)
                VALUES (?, ?)
            """, activity_id, tutor_id)

            platform_id = choice(self.online_platforms)
            meeting_url = self.fake.unique.uri() if randrange(10) < 9 else None
            recording_url = self.fake.unique.uri() if meeting_url is not None and randrange(3) < 2 else None

            self.cursor.execute(f"""
                INSERT INTO {self.schema}.online_synchronous_meetings (meeting_id, platform_id, meeting_url, recording_url)
                VALUES (?, ?, ?, ?)
            """, activity_id, platform_id, meeting_url, recording_url)

            start_time = datetime.today() - timedelta(
                days=randrange(3649),
                hours=randrange(8, 17),
                minutes=randrange(4)*15
            )

            end_time = start_time + timedelta(hours=randrange(3), minutes=randrange(2) * 30)

            self.cursor.execute(f"""
                INSERT INTO {self.schema}.meeting_schedule (meeting_id, start_time, end_time)
                VALUES (?, ?, ?)
            """, activity_id, start_time, end_time)

            price = round(randrange(10000) / 100, 2)

            self.cursor.execute(f"""
                INSERT INTO {self.schema}.products (activity_id, price)
                VALUES (?, ?)
            """, activity_id, price)

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

    def generate_meeting(self, meeting_type: str, start_time: datetime, end_time: datetime, rooms: list[Room]):
        meeting_id = self.generate_activity()

        self.cursor.execute(f"""
            INSERT INTO {self.schema}.meetings (activity_id, tutor_id)
            VALUES (?, ?)
        """, meeting_id, choice(self.tutors))

        match meeting_type:
            case "on_site_meetings":
                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.on_site_meetings (meeting_id, room_id)
                    VALUES (?, ?)
                """, meeting_id, choice(list(map(lambda x: x.id, rooms))))

                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.meeting_schedule (meeting_id, start_time, end_time)
                    VALUES (?, ?, ?)
                """, meeting_id, start_time, end_time)

            case "online_synchronous_meetings":
                meeting_url = self.fake.unique.uri() if randrange(10) < 9 else None
                recording_url = self.fake.unique.uri() if meeting_url is not None and randrange(3) < 2 else None

                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.online_synchronous_meetings (meeting_id, platform_id, meeting_url, recording_url)
                    VALUES (?, ?, ?, ?)
                """, meeting_id, choice(self.online_platforms), meeting_url, recording_url)

                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.meeting_schedule (meeting_id, start_time, end_time)
                    VALUES (?, ?, ?)
                """, meeting_id, start_time, end_time)

            case "online_asynchronous_meetings":
                recording_url = self.fake.unique.uri()

                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.online_asynchronous_meetings (meeting_id, recording_url)
                    VALUES (?, ?)
                """, meeting_id, recording_url)

            case "internships":
                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.internships (meeting_id)
                    VALUES (?)
                """, meeting_id)

                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.meeting_schedule (meeting_id, start_time, end_time)
                    VALUES (?, ?, ?)
                """, meeting_id, start_time, end_time)

        return meeting_id

    def generate_courses(self, count: int):
        print(f"Generating courses... ({count})")

        for _ in range(count):
            course_id = self.generate_activity()

            coordinator_id = choice(self.coordinators)

            self.cursor.execute(f"""
                INSERT INTO {self.schema}.courses (activity_id, coordinator_id)
                VALUES (?, ?)
            """, course_id, coordinator_id)

            module_count = randrange(3, 10)
            start_date = datetime.today() - timedelta(days=3650)
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
                module_id = self.generate_activity()
                module_type = choice(self.meeting_types + ["hybrid"])

                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.course_modules (activity_id, course_id)
                    VALUES (?, ?)
                """, module_id, course_id)

                for (start_time, end_time) in meeting_times[i:j]:
                    meeting_id = self.generate_meeting(
                        choice(self.meeting_types) if module_type == "hybrid" else module_type,
                        start_time,
                        end_time,
                        self.rooms
                    )

                    self.cursor.execute(f"""
                        INSERT INTO {self.schema}.module_meetings (meeting_id, module_id)
                        VALUES (?, ?)
                    """, meeting_id, module_id)

            price = round(randrange(10000) / 100, 2)

            self.cursor.execute(f"""
                INSERT INTO {self.schema}.products (activity_id, price)
                VALUES (?, ?)
            """, course_id, price)

    def generate_study_modules(self, study_id):
        module_ids = []

        for _ in range(randrange(10, 30)):
            module_id = self.generate_activity()

            self.cursor.execute(f"""
                INSERT INTO {self.schema}.study_modules (activity_id, study_id, coordinator_id)
                VALUES (?, ?, ?)
            """, module_id, study_id, choice(self.coordinators))

            module_ids.append(module_id)

        return module_ids

    def generate_study_sessions(self, study_id, module_ids, rooms):
        def study_session_end_time(start: datetime):
            return start + timedelta(days=2, hours=8)

        def datetime_next_week(time: datetime):
            return time + timedelta(weeks=1)

        start_date = datetime(randrange(2015, 2022), 9, 1)
        semesters = []
        for _ in range(randrange(3, 6)):
            semesters.append((start_date, start_date + timedelta(6 * 30)))
            start_date = start_date.replace(year=start_date.year + 1)
            semesters.append((start_date - timedelta(6 * 30), start_date))

        for (start, end) in semesters:
            start_time = start + timedelta(days=(4 - start.weekday() + 7) % 7, hours=8)

            while study_session_end_time(datetime_next_week(start_time)) < end:
                session_id = self.generate_activity()

                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.study_sessions (activity_id, study_id)
                    VALUES (?, ?)
                """, session_id, study_id)

                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.products (activity_id, price)
                    VALUES (?, ?)
                """, session_id, round(randrange(10000, 100000) / 100, 2))

                meeting_times = self.generate_random_meeting_times(
                    start_time,
                    study_session_end_time(start_time),
                    randrange(5, 10)
                )

                for (meeting_start, meeting_end) in meeting_times:
                    meeting_id = self.generate_meeting(
                        choice(self.meeting_types),
                        meeting_start,
                        meeting_end,
                        rooms
                    )

                    self.cursor.execute(f"""
                        INSERT INTO {self.schema}.products (activity_id, price)
                        VALUES (?, ?)
                    """, meeting_id, round(randrange(10000) / 100, 2))

                    self.cursor.execute(f"""
                        INSERT INTO {self.schema}.study_meetings (meeting_id, session_id, module_id)
                        VALUES (?, ?, ?)
                    """, meeting_id, session_id, choice(module_ids))

                start_time += timedelta(weeks=1)

            session_id = self.generate_activity()

            self.cursor.execute(f"""
                INSERT INTO {self.schema}.study_sessions (activity_id, study_id)
                VALUES (?, ?)
            """, session_id, study_id)

            self.cursor.execute(f"""
                INSERT INTO {self.schema}.products (activity_id, price)
                VALUES (?, ?)
            """, session_id, round(randrange(10000, 100000) / 100, 2))

            meeting_times = self.generate_random_meeting_times(
                start_time,
                study_session_end_time(start_time),
                randrange(5, 10)
            )

            for (meeting_start, meeting_end) in meeting_times:
                meeting_id = self.generate_meeting(
                    "internships",
                    meeting_start,
                    meeting_end,
                    rooms
                )

                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.products (activity_id, price)
                    VALUES (?, ?)
                """, meeting_id, round(randrange(10000) / 100, 2))

                self.cursor.execute(f"""
                    INSERT INTO {self.schema}.study_meetings (meeting_id, session_id, module_id)
                    VALUES (?, ?, ?)
                """, meeting_id, session_id, choice(module_ids))

    def generate_studies(self, count: int):
        print(f"Generating studies... ({count})")

        for _ in range(count):
            study_id = self.generate_activity()
            study_place_limit = randrange(self.rooms[0].place_limit, self.rooms[-1].place_limit)

            rooms_smallest_index = 0
            for rooms_smallest_index, room in enumerate(self.rooms):
                if room.place_limit >= study_place_limit:
                    break

            self.cursor.execute(f"""
                INSERT INTO {self.schema}.studies (activity_id, place_limit)
                VALUES (?, ?)
            """, study_id, study_place_limit)

            modules = self.generate_study_modules(study_id)
            self.generate_study_sessions(study_id, modules, self.rooms[rooms_smallest_index:])

            self.cursor.execute(f"""
                INSERT INTO {self.schema}.products (activity_id, price)
                VALUES (?, ?)
            """, study_id, round(randrange(10000) / 100, 2))
