CREATE FUNCTION get_make_up_presence_activity(@meeting_id INT, @student_id INT)
RETURNS INT
BEGIN
    RETURN (
        SELECT activity_id
        FROM meeting_presence_make_up
        WHERE student_id = @student_id AND meeting_id = @meeting_id
    )
END
