CREATE VIEW study_passes AS
SELECT
    studies.activity_id AS study_id,
    product_owners.student_id,
    dbo.is_student_passing_studies(
        studies.activity_id,
        product_owners.student_id
    ) AS passes
FROM studies
    JOIN product_owners ON studies.activity_id = product_owners.product_id
