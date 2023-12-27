CREATE VIEW webinars AS
SELECT
	online_synchronous_meetings.meeting_id AS webinar_id,
	activities.title AS title,
	activities.description AS description,
	meetings.tutor_id AS tutor_id,
	meeting_schedule.start_time AS start_time,
	meeting_schedule.end_time AS end_time,
    ISNULL(languages.name, 'Polski') AS language,
    meeting_translators.translator_id AS translator_id,
	online_synchronous_meetings.meeting_url AS meeting_url,
	online_synchronous_meetings.recording_url AS recording_url,
	online_platforms.name AS online_platform,
	products.price AS price
FROM online_synchronous_meetings
	JOIN meeting_schedule ON online_synchronous_meetings.meeting_id = meeting_schedule.meeting_id
	JOIN meetings ON online_synchronous_meetings.meeting_id = meetings.activity_id
	JOIN activities ON online_synchronous_meetings.meeting_id = activities.id
	JOIN online_platforms ON online_synchronous_meetings.platform_id = online_platforms.id
	JOIN products ON online_synchronous_meetings.meeting_id = products.activity_id
    LEFT JOIN meeting_translators ON meetings.activity_id = meeting_translators.meeting_id
    LEFT JOIN languages ON meeting_translators.language_id = languages.id
WHERE
	online_synchronous_meetings.meeting_id NOT IN (
		SELECT study_meetings.meeting_id
		FROM study_meetings
		UNION
		SELECT module_meetings.meeting_id
		FROM module_meetings
		UNION
		SELECT internships.meeting_id
		FROM internships
		UNION
		SELECT on_site_meetings.meeting_id
		FROM on_site_meetings
		UNION
		SELECT online_asynchronous_meetings.meeting_id
		FROM online_asynchronous_meetings
	)
