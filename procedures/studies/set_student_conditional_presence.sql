CREATE PROCEDURE set_student_conditional_presence
    @meeting_id INT,
    @student_id INT,
    @conditional_activity_id INT
AS BEGIN
    IF @student_id NOT IN (SELECT user_id FROM students)
        THROW 50000, 'Student not found', 11;
    ELSE IF @meeting_id NOT IN (SELECT activity_id FROM meetings)
        THROW 50001, 'Meeting not found', 11;
    ELSE IF @student_id NOT IN (SELECT student_id FROM meeting_participants WHERE meeting_id = @meeting_id)
        THROW 50002, 'Student cannot attend this meeting', 16;
    ELSE IF @student_id IN (SELECT student_id FROM meeting_participants WHERE meeting_id = @meeting_id AND presence = 1)
        THROW 50003, 'Student already present', 16;
    ELSE IF @conditional_activity_id NOT IN (
        SELECT activity_id
        FROM courses
        UNION
        SELECT meeting_id
        FROM meeting_types
        WHERE meeting_type LIKE 'study_%'
    )
        THROW 50004, 'Cannot assign this activity as conditional activity', 16;

    INSERT INTO meeting_presence (meeting_id, student_id)
    VALUES (@meeting_id, @student_id);

    INSERT INTO meeting_presence_make_up (meeting_id, student_id, activity_id)
    VALUES (@meeting_id, @student_id, @conditional_activity_id);

    IF 1 = dbo.is_conditional_presence_cycle(@meeting_id, @student_id)
    BEGIN
        DELETE meeting_presence_make_up
        WHERE meeting_id = @meeting_id AND student_id = @student_id;

        DELETE meeting_presence
        WHERE meeting_id = @meeting_id AND student_id = @student_id;

        THROW 50005, 'Setting this conditional activity would introduce a cycle', 16;
    END
END
