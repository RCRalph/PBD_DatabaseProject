CREATE VIEW meeting_participants AS
SELECT
    meetings.activity_id AS meeting_id,
    product_owners.student_id,
    CASE
        WHEN meeting_types.meeting_type <> 'webinar'
        THEN dbo.is_student_present(
            meetings.activity_id,
            product_owners.student_id
        )
    END AS presence
FROM meetings
    JOIN product_owners ON meetings.activity_id = product_owners.product_id
    JOIN meeting_types ON meetings.activity_id = meeting_types.meeting_id
UNION
SELECT
    study_meeting_information.meeting_id,
    product_owners.student_id,
    dbo.is_student_present(
        study_meeting_information.meeting_id,
        product_owners.student_id
    ) AS presence
FROM study_meeting_information
    JOIN product_owners ON study_meeting_information.study_id = product_owners.product_id
UNION
SELECT
    course_meeting_information.meeting_id,
    product_owners.student_id,
    dbo.is_student_present(
        course_meeting_information.meeting_id,
        product_owners.student_id
    ) AS presence
FROM course_meeting_information
    JOIN product_owners ON course_meeting_information.course_id = product_owners.product_id
