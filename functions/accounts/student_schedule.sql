CREATE FUNCTION student_schedule(@student_id INT)
RETURNS @result TABLE (
    title NVARCHAR(128) NOT NULL,
    description NVARCHAR(MAX) NULL,
    start_time DATETIME NULL,
    end_time DATETIME NULL
)
BEGIN
    INSERT INTO @result
    SELECT
        webinar_information.title,
        webinar_information.description,
        webinar_information.start_time,
        webinar_information.end_time
    FROM webinar_information
        JOIN product_owners ON webinar_information.webinar_id = product_owners.product_id
    WHERE product_owners.student_id = @student_id
    UNION
    SELECT
        course_meeting_information.title,
        course_meeting_information.description,
        course_meeting_information.start_time,
        course_meeting_information.end_time
    FROM course_meeting_information
        JOIN product_owners ON course_meeting_information.course_id = product_owners.product_id
    WHERE product_owners.student_id = @student_id
    UNION
    SELECT
        study_meeting_information.title,
        study_meeting_information.description,
        study_meeting_information.start_time,
        study_meeting_information.end_time
    FROM study_meeting_information
        JOIN product_owners ON study_meeting_information.session_id = product_owners.product_id
    WHERE product_owners.student_id = @student_id

    RETURN
END
