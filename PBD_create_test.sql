-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2023-12-24 11:51:08.662

-- tables
-- Table: activities
CREATE TABLE rcralph_test.activities
(
	id          int           NOT NULL IDENTITY (1, 1),
	title       nvarchar(128) NOT NULL,
	description nvarchar(max) NULL,
	CONSTRAINT activities_ak_1 UNIQUE (title),
	CONSTRAINT activities_pk PRIMARY KEY (id)
);

-- Table: addresses
CREATE TABLE rcralph_test.addresses
(
	student_id int           NOT NULL,
	street     nvarchar(128) NOT NULL,
	zip_code   nvarchar(8)   NOT NULL,
	city_id    int           NOT NULL,
	CONSTRAINT addresses_valid_zip_code CHECK (isnumeric([zip_code]) = 1),
	CONSTRAINT addresses_pk PRIMARY KEY (student_id)
);

-- Table: advance_payments
CREATE TABLE rcralph_test.advance_payments
(
	id         int           NOT NULL IDENTITY (1, 1),
	value      decimal(3, 3) NOT NULL,
	start_date date          NOT NULL,
	end_date   date          NULL DEFAULT NULL,
	CONSTRAINT advance_payments_ak_1 UNIQUE (start_date),
	CONSTRAINT advance_payments_ak_2 UNIQUE (end_date),
	CONSTRAINT advance_payments_valid_dates CHECK ([start_date] <= [end_date]),
	CONSTRAINT advance_payments_valid_value CHECK (0 <= [value] AND [value] <= 1),
	CONSTRAINT advance_payments_pk PRIMARY KEY (id)
);

-- Table: cities
CREATE TABLE rcralph_test.cities
(
	id         int           NOT NULL IDENTITY (1, 1),
	country_id int           NOT NULL,
	name       nvarchar(128) NOT NULL,
	CONSTRAINT cities_ak_1 UNIQUE (name, country_id),
	CONSTRAINT cities_pk PRIMARY KEY (id)
);

-- Table: coordinators
CREATE TABLE rcralph_test.coordinators
(
	user_id int NOT NULL,
	active  bit NOT NULL DEFAULT 1,
	CONSTRAINT coordinators_pk PRIMARY KEY (user_id)
);

-- Table: countries
CREATE TABLE rcralph_test.countries
(
	id   int           NOT NULL IDENTITY (1, 1),
	name nvarchar(128) NOT NULL,
	CONSTRAINT country_ak_1 UNIQUE (name),
	CONSTRAINT countries_pk PRIMARY KEY (id)
);

-- Table: course_modules
CREATE TABLE rcralph_test.course_modules
(
	activity_id int NOT NULL,
	course_id   int NOT NULL,
	CONSTRAINT course_meetings_pk PRIMARY KEY (activity_id)
);

-- Table: courses
CREATE TABLE rcralph_test.courses
(
	activity_id    int NOT NULL,
	coordinator_id int NOT NULL,
	CONSTRAINT courses_pk PRIMARY KEY (activity_id)
);

-- Table: internships
CREATE TABLE rcralph_test.internships
(
	meeting_id int NOT NULL,
	CONSTRAINT internships_pk PRIMARY KEY (meeting_id)
);

-- Table: languages
CREATE TABLE rcralph_test.languages
(
	id   int          NOT NULL IDENTITY (1, 1),
	name nvarchar(64) NOT NULL,
	CONSTRAINT languages_pk PRIMARY KEY (id)
);

-- Table: meeting_presence
CREATE TABLE rcralph_test.meeting_presence
(
	meeting_id int NOT NULL,
	student_id int NOT NULL,
	CONSTRAINT meeting_presence_pk PRIMARY KEY (meeting_id, student_id)
);

-- Table: meeting_presence_make_up
CREATE TABLE rcralph_test.meeting_presence_make_up
(
	meeting_id  int NOT NULL,
	student_id  int NOT NULL,
	activity_id int NOT NULL,
	CONSTRAINT meeting_presence_make_up_pk PRIMARY KEY (meeting_id, student_id)
);

-- Table: meeting_schedule
CREATE TABLE rcralph_test.meeting_schedule
(
	meeting_id int      NOT NULL,
	start_time datetime NOT NULL,
	end_time   datetime NOT NULL,
	CONSTRAINT meeting_schedule_valid_time CHECK ([start_time] <= [end_time]),
	CONSTRAINT meeting_schedule_pk PRIMARY KEY (meeting_id)
);

-- Table: meeting_translations
CREATE TABLE rcralph_test.meeting_translations
(
	meeting_id    int           NOT NULL,
	language_id   int           NOT NULL,
	translator_id int           NOT NULL,
	translation   nvarchar(max) NULL,
	CONSTRAINT translations_pk PRIMARY KEY (meeting_id)
);

-- Table: meetings
CREATE TABLE rcralph_test.meetings
(
	activity_id int NOT NULL,
	tutor_id    int NOT NULL,
	CONSTRAINT meetings_pk PRIMARY KEY (activity_id)
);

-- Table: module_meetings
CREATE TABLE rcralph_test.module_meetings
(
	meeting_id int NOT NULL,
	module_id  int NOT NULL,
	CONSTRAINT module_meetings_pk PRIMARY KEY (meeting_id)
);

-- Table: on_site_meetings
CREATE TABLE rcralph_test.on_site_meetings
(
	meeting_id int NOT NULL,
	room_id    int NOT NULL,
	CONSTRAINT on_site_meetings_pk PRIMARY KEY (meeting_id)
);

-- Table: online_asynchronous_meetings
CREATE TABLE rcralph_test.online_asynchronous_meetings
(
	meeting_id    int           NOT NULL,
	recording_url nvarchar(128) NOT NULL,
	CONSTRAINT online_asynchronous_meetings_pk PRIMARY KEY (meeting_id)
);

-- Table: online_platforms
CREATE TABLE rcralph_test.online_platforms
(
	id   int          NOT NULL IDENTITY (1, 1),
	name nvarchar(64) NOT NULL,
	CONSTRAINT online_platforms_ak_1 UNIQUE (name),
	CONSTRAINT online_platforms_pk PRIMARY KEY (id)
);

-- Table: online_synchronous_meetings
CREATE TABLE rcralph_test.online_synchronous_meetings
(
	meeting_id    int           NOT NULL,
	platform_id   int           NOT NULL,
	meeting_url   nvarchar(128) NULL,
	recording_url nvarchar(128) NULL,
	CONSTRAINT online_synchronous_meetings_pk PRIMARY KEY (meeting_id)
);

CREATE UNIQUE NONCLUSTERED INDEX online_synchronous_meetings_idx_1 on rcralph_test.online_synchronous_meetings (meeting_url ASC)
	WHERE [meeting_url] IS NOT NULL
;

CREATE UNIQUE NONCLUSTERED INDEX online_synchronous_meetings_idx_2 on rcralph_test.online_synchronous_meetings (recording_url ASC)
	WHERE [recording_url] IS NOT NULL
;

-- Table: order_details
CREATE TABLE rcralph_test.order_details
(
	order_id   int   NOT NULL,
	product_id int   NOT NULL,
	price      money NOT NULL,
	status_id  int   NOT NULL,
	CONSTRAINT order_details_valid_price CHECK ([price] >= 0),
	CONSTRAINT order_details_pk PRIMARY KEY (order_id, product_id)
);

-- Table: order_statuses
CREATE TABLE rcralph_test.order_statuses
(
	id   int          NOT NULL IDENTITY (1, 1),
	name nvarchar(64) NOT NULL,
	CONSTRAINT order_statuses_pk PRIMARY KEY (id)
);

-- Table: orders
CREATE TABLE rcralph_test.orders
(
	id          int           NOT NULL IDENTITY (1, 1),
	student_id  int           NOT NULL,
	payment_url nvarchar(128) NOT NULL,
	order_date  date          NOT NULL DEFAULT GETDATE(),
	CONSTRAINT orders_ak_1 UNIQUE (payment_url),
	CONSTRAINT orders_pk PRIMARY KEY (id)
);

-- Table: products
CREATE TABLE rcralph_test.products
(
	activity_id int   NOT NULL,
	price       money NOT NULL DEFAULT 0,
	active      bit   NOT NULL DEFAULT 1,
	CONSTRAINT products_valid_price CHECK ([price] >= 0),
	CONSTRAINT products_pk PRIMARY KEY (activity_id)
);

-- Table: rooms
CREATE TABLE rcralph_test.rooms
(
	id          int          NOT NULL IDENTITY (1, 1),
	room_name   nvarchar(64) NOT NULL,
	place_limit int          NOT NULL,
	CONSTRAINT rooms_ak_1 UNIQUE (room_name),
	CONSTRAINT rooms_valid_place_limit CHECK ([place_limit] > 0),
	CONSTRAINT rooms_pk PRIMARY KEY (id)
);

-- Table: shopping_cart
CREATE TABLE rcralph_test.shopping_cart
(
	product_id int NOT NULL,
	student_id int NOT NULL,
	CONSTRAINT shopping_cart_pk PRIMARY KEY (product_id, student_id)
);

-- Table: students
CREATE TABLE rcralph_test.students
(
	user_id int NOT NULL,
	CONSTRAINT students_pk PRIMARY KEY (user_id)
);

-- Table: studies
CREATE TABLE rcralph_test.studies
(
	activity_id int NOT NULL,
	place_limit int NOT NULL,
	CONSTRAINT studies_place_limit CHECK ([place_limit] > 0),
	CONSTRAINT studies_pk PRIMARY KEY (activity_id)
);

-- Table: study_meetings
CREATE TABLE rcralph_test.study_meetings
(
	meeting_id int NOT NULL,
	session_id int NOT NULL,
	module_id  int NOT NULL,
	CONSTRAINT study_meetings_pk PRIMARY KEY (meeting_id)
);

-- Table: study_module_passes
CREATE TABLE rcralph_test.study_module_passes
(
	student_id int NOT NULL,
	module_id  int NOT NULL,
	CONSTRAINT study_course_passes_pk PRIMARY KEY (student_id, module_id)
);

-- Table: study_modules
CREATE TABLE rcralph_test.study_modules
(
	activity_id    int NOT NULL,
	study_id       int NOT NULL,
	coordinator_id int NOT NULL,
	CONSTRAINT study_modules_pk PRIMARY KEY (activity_id)
);

-- Table: study_sessions
CREATE TABLE rcralph_test.study_sessions
(
	activity_id int NOT NULL,
	study_id    int NOT NULL,
	CONSTRAINT study_sessions_pk PRIMARY KEY (activity_id)
);

-- Table: translators
CREATE TABLE rcralph_test.translators
(
	user_id int NOT NULL,
	active  bit NOT NULL DEFAULT 1,
	CONSTRAINT translators_pk PRIMARY KEY (user_id)
);

-- Table: translators_languages
CREATE TABLE rcralph_test.translators_languages
(
	translator_id int NOT NULL,
	language_id   int NOT NULL,
	CONSTRAINT translators_languages_pk PRIMARY KEY (translator_id, language_id)
);

-- Table: tutors
CREATE TABLE rcralph_test.tutors
(
	user_id int NOT NULL,
	active  bit NOT NULL DEFAULT 1,
	CONSTRAINT tutors_pk PRIMARY KEY (user_id)
);

-- Table: users
CREATE TABLE rcralph_test.users
(
	id         int          NOT NULL IDENTITY (1, 1),
	email      nvarchar(64) NOT NULL,
	password   nvarchar(64) NOT NULL,
	first_name nvarchar(64) NOT NULL,
	last_name  nvarchar(64) NOT NULL,
	phone      nvarchar(16) NULL DEFAULT NULL,
	CONSTRAINT unique_email UNIQUE (email),
	CONSTRAINT users_valid_email CHECK ([email] LIKE '%_@_%._%'),
	CONSTRAINT users_valid_phone CHECK ([phone] IS NULL OR ISNUMERIC([phone]) = 1 OR
										LEFT([phone], 1) = '+' AND ISNUMERIC(SUBSTRING([phone], 2, LEN([phone]))) = 1),
	CONSTRAINT users_pk PRIMARY KEY (id)
);

-- foreign keys
-- Reference: addresses_cities (table: addresses)
ALTER TABLE rcralph_test.addresses
	ADD CONSTRAINT addresses_cities
		FOREIGN KEY (city_id)
			REFERENCES rcralph_test.cities (id);

-- Reference: addresses_students (table: addresses)
ALTER TABLE rcralph_test.addresses
	ADD CONSTRAINT addresses_students
		FOREIGN KEY (student_id)
			REFERENCES rcralph_test.students (user_id);

-- Reference: cities_countries (table: cities)
ALTER TABLE rcralph_test.cities
	ADD CONSTRAINT cities_countries
		FOREIGN KEY (country_id)
			REFERENCES rcralph_test.countries (id);

-- Reference: coordinators_users (table: coordinators)
ALTER TABLE rcralph_test.coordinators
	ADD CONSTRAINT coordinators_users
		FOREIGN KEY (user_id)
			REFERENCES rcralph_test.users (id);

-- Reference: course_meetings_activities (table: course_modules)
ALTER TABLE rcralph_test.course_modules
	ADD CONSTRAINT course_meetings_activities
		FOREIGN KEY (activity_id)
			REFERENCES rcralph_test.activities (id);

-- Reference: course_meetings_courses (table: course_modules)
ALTER TABLE rcralph_test.course_modules
	ADD CONSTRAINT course_meetings_courses
		FOREIGN KEY (course_id)
			REFERENCES rcralph_test.courses (activity_id);

-- Reference: courses_activities (table: courses)
ALTER TABLE rcralph_test.courses
	ADD CONSTRAINT courses_activities
		FOREIGN KEY (activity_id)
			REFERENCES rcralph_test.activities (id);

-- Reference: courses_coordinators (table: courses)
ALTER TABLE rcralph_test.courses
	ADD CONSTRAINT courses_coordinators
		FOREIGN KEY (coordinator_id)
			REFERENCES rcralph_test.coordinators (user_id);

-- Reference: internships_meetings (table: internships)
ALTER TABLE rcralph_test.internships
	ADD CONSTRAINT internships_meetings
		FOREIGN KEY (meeting_id)
			REFERENCES rcralph_test.meetings (activity_id);

-- Reference: meeting_absence_make_up_activities (table: meeting_presence_make_up)
ALTER TABLE rcralph_test.meeting_presence_make_up
	ADD CONSTRAINT meeting_absence_make_up_activities
		FOREIGN KEY (activity_id)
			REFERENCES rcralph_test.activities (id);

-- Reference: meeting_absence_make_up_meeting_presence (table: meeting_presence_make_up)
ALTER TABLE rcralph_test.meeting_presence_make_up
	ADD CONSTRAINT meeting_absence_make_up_meeting_presence
		FOREIGN KEY (meeting_id, student_id)
			REFERENCES rcralph_test.meeting_presence (meeting_id, student_id);

-- Reference: meeting_presence_meetings (table: meeting_presence)
ALTER TABLE rcralph_test.meeting_presence
	ADD CONSTRAINT meeting_presence_meetings
		FOREIGN KEY (meeting_id)
			REFERENCES rcralph_test.meetings (activity_id);

-- Reference: meeting_presence_students (table: meeting_presence)
ALTER TABLE rcralph_test.meeting_presence
	ADD CONSTRAINT meeting_presence_students
		FOREIGN KEY (student_id)
			REFERENCES rcralph_test.students (user_id);

-- Reference: meeting_schedule_meetings (table: meeting_schedule)
ALTER TABLE rcralph_test.meeting_schedule
	ADD CONSTRAINT meeting_schedule_meetings
		FOREIGN KEY (meeting_id)
			REFERENCES rcralph_test.meetings (activity_id);

-- Reference: meeting_translations_languages (table: meeting_translations)
ALTER TABLE rcralph_test.meeting_translations
	ADD CONSTRAINT meeting_translations_languages
		FOREIGN KEY (language_id)
			REFERENCES rcralph_test.languages (id);

-- Reference: meeting_translations_translators (table: meeting_translations)
ALTER TABLE rcralph_test.meeting_translations
	ADD CONSTRAINT meeting_translations_translators
		FOREIGN KEY (translator_id)
			REFERENCES rcralph_test.translators (user_id);

-- Reference: meetings_activities (table: meetings)
ALTER TABLE rcralph_test.meetings
	ADD CONSTRAINT meetings_activities
		FOREIGN KEY (activity_id)
			REFERENCES rcralph_test.activities (id);

-- Reference: meetings_meeting_translations (table: meeting_translations)
ALTER TABLE rcralph_test.meeting_translations
	ADD CONSTRAINT meetings_meeting_translations
		FOREIGN KEY (meeting_id)
			REFERENCES rcralph_test.meetings (activity_id);

-- Reference: meetings_tutors (table: meetings)
ALTER TABLE rcralph_test.meetings
	ADD CONSTRAINT meetings_tutors
		FOREIGN KEY (tutor_id)
			REFERENCES rcralph_test.tutors (user_id);

-- Reference: module_meetings_course_meetings (table: module_meetings)
ALTER TABLE rcralph_test.module_meetings
	ADD CONSTRAINT module_meetings_course_meetings
		FOREIGN KEY (module_id)
			REFERENCES rcralph_test.course_modules (activity_id);

-- Reference: module_meetings_meetings (table: module_meetings)
ALTER TABLE rcralph_test.module_meetings
	ADD CONSTRAINT module_meetings_meetings
		FOREIGN KEY (meeting_id)
			REFERENCES rcralph_test.meetings (activity_id);

-- Reference: on_site_meetings_meetings (table: on_site_meetings)
ALTER TABLE rcralph_test.on_site_meetings
	ADD CONSTRAINT on_site_meetings_meetings
		FOREIGN KEY (meeting_id)
			REFERENCES rcralph_test.meetings (activity_id);

-- Reference: online_asynchronous_meetings_meetings (table: online_asynchronous_meetings)
ALTER TABLE rcralph_test.online_asynchronous_meetings
	ADD CONSTRAINT online_asynchronous_meetings_meetings
		FOREIGN KEY (meeting_id)
			REFERENCES rcralph_test.meetings (activity_id);

-- Reference: online_synchronous_meetings_meetings (table: online_synchronous_meetings)
ALTER TABLE rcralph_test.online_synchronous_meetings
	ADD CONSTRAINT online_synchronous_meetings_meetings
		FOREIGN KEY (meeting_id)
			REFERENCES rcralph_test.meetings (activity_id);

-- Reference: online_synchronous_meetings_online_platforms (table: online_synchronous_meetings)
ALTER TABLE rcralph_test.online_synchronous_meetings
	ADD CONSTRAINT online_synchronous_meetings_online_platforms
		FOREIGN KEY (platform_id)
			REFERENCES rcralph_test.online_platforms (id);

-- Reference: order_details_orders (table: order_details)
ALTER TABLE rcralph_test.order_details
	ADD CONSTRAINT order_details_orders
		FOREIGN KEY (order_id)
			REFERENCES rcralph_test.orders (id);

-- Reference: order_details_payment_status (table: order_details)
ALTER TABLE rcralph_test.order_details
	ADD CONSTRAINT order_details_payment_status
		FOREIGN KEY (status_id)
			REFERENCES rcralph_test.order_statuses (id);

-- Reference: order_details_products (table: order_details)
ALTER TABLE rcralph_test.order_details
	ADD CONSTRAINT order_details_products
		FOREIGN KEY (product_id)
			REFERENCES rcralph_test.products (activity_id);

-- Reference: orders_students (table: orders)
ALTER TABLE rcralph_test.orders
	ADD CONSTRAINT orders_students
		FOREIGN KEY (student_id)
			REFERENCES rcralph_test.students (user_id);

-- Reference: products_activities (table: products)
ALTER TABLE rcralph_test.products
	ADD CONSTRAINT products_activities
		FOREIGN KEY (activity_id)
			REFERENCES rcralph_test.activities (id);

-- Reference: rooms_on_site_meetings (table: on_site_meetings)
ALTER TABLE rcralph_test.on_site_meetings
	ADD CONSTRAINT rooms_on_site_meetings
		FOREIGN KEY (room_id)
			REFERENCES rcralph_test.rooms (id);

-- Reference: shopping_cart_products (table: shopping_cart)
ALTER TABLE rcralph_test.shopping_cart
	ADD CONSTRAINT shopping_cart_products
		FOREIGN KEY (student_id)
			REFERENCES rcralph_test.products (activity_id);

-- Reference: shopping_cart_students (table: shopping_cart)
ALTER TABLE rcralph_test.shopping_cart
	ADD CONSTRAINT shopping_cart_students
		FOREIGN KEY (student_id)
			REFERENCES rcralph_test.students (user_id);

-- Reference: students_users (table: students)
ALTER TABLE rcralph_test.students
	ADD CONSTRAINT students_users
		FOREIGN KEY (user_id)
			REFERENCES rcralph_test.users (id);

-- Reference: studies_activities (table: studies)
ALTER TABLE rcralph_test.studies
	ADD CONSTRAINT studies_activities
		FOREIGN KEY (activity_id)
			REFERENCES rcralph_test.activities (id);

-- Reference: study_meetings_meetings (table: study_meetings)
ALTER TABLE rcralph_test.study_meetings
	ADD CONSTRAINT study_meetings_meetings
		FOREIGN KEY (meeting_id)
			REFERENCES rcralph_test.meetings (activity_id);

-- Reference: study_module_passes_students (table: study_module_passes)
ALTER TABLE rcralph_test.study_module_passes
	ADD CONSTRAINT study_module_passes_students
		FOREIGN KEY (student_id)
			REFERENCES rcralph_test.students (user_id);

-- Reference: study_module_passes_study_modules (table: study_module_passes)
ALTER TABLE rcralph_test.study_module_passes
	ADD CONSTRAINT study_module_passes_study_modules
		FOREIGN KEY (module_id)
			REFERENCES rcralph_test.study_modules (activity_id);

-- Reference: study_modules_activities (table: study_modules)
ALTER TABLE rcralph_test.study_modules
	ADD CONSTRAINT study_modules_activities
		FOREIGN KEY (activity_id)
			REFERENCES rcralph_test.activities (id);

-- Reference: study_modules_coordinators (table: study_modules)
ALTER TABLE rcralph_test.study_modules
	ADD CONSTRAINT study_modules_coordinators
		FOREIGN KEY (coordinator_id)
			REFERENCES rcralph_test.coordinators (user_id);

-- Reference: study_modules_studies (table: study_modules)
ALTER TABLE rcralph_test.study_modules
	ADD CONSTRAINT study_modules_studies
		FOREIGN KEY (study_id)
			REFERENCES rcralph_test.studies (activity_id);

-- Reference: study_modules_study_meetings (table: study_meetings)
ALTER TABLE rcralph_test.study_meetings
	ADD CONSTRAINT study_modules_study_meetings
		FOREIGN KEY (module_id)
			REFERENCES rcralph_test.study_modules (activity_id);

-- Reference: study_sessions_activities (table: study_sessions)
ALTER TABLE rcralph_test.study_sessions
	ADD CONSTRAINT study_sessions_activities
		FOREIGN KEY (activity_id)
			REFERENCES rcralph_test.activities (id);

-- Reference: study_sessions_studies (table: study_sessions)
ALTER TABLE rcralph_test.study_sessions
	ADD CONSTRAINT study_sessions_studies
		FOREIGN KEY (study_id)
			REFERENCES rcralph_test.studies (activity_id);

-- Reference: study_sessions_study_meetings (table: study_meetings)
ALTER TABLE rcralph_test.study_meetings
	ADD CONSTRAINT study_sessions_study_meetings
		FOREIGN KEY (session_id)
			REFERENCES rcralph_test.study_sessions (activity_id);

-- Reference: translators_languages_languages (table: translators_languages)
ALTER TABLE rcralph_test.translators_languages
	ADD CONSTRAINT translators_languages_languages
		FOREIGN KEY (language_id)
			REFERENCES rcralph_test.languages (id);

-- Reference: translators_languages_translators (table: translators_languages)
ALTER TABLE rcralph_test.translators_languages
	ADD CONSTRAINT translators_languages_translators
		FOREIGN KEY (translator_id)
			REFERENCES rcralph_test.translators (user_id);

-- Reference: translators_users (table: translators)
ALTER TABLE rcralph_test.translators
	ADD CONSTRAINT translators_users
		FOREIGN KEY (user_id)
			REFERENCES rcralph_test.users (id);

-- Reference: tutors_users (table: tutors)
ALTER TABLE rcralph_test.tutors
	ADD CONSTRAINT tutors_users
		FOREIGN KEY (user_id)
			REFERENCES rcralph_test.users (id);

-- End of file.

