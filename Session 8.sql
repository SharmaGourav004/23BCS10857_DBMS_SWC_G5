--Q1---------------------------------------------------------------
CREATE OR REPLACE FUNCTION top_rated_support_employees()
RETURNS TABLE (
    employee_id TEXT,
    employee_name TEXT,
    avg_satisfaction DOUBLE PRECISION,
    employee_rank BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH avg_scores AS (
        SELECT
            ast.employee_id,
            ast.employee_name,
            AVG(ast.customer_satisfaction) AS avg_satisfaction
        FROM amazon_support_tickets ast
        WHERE ast.resolution_status = 'Resolved'
        GROUP BY ast.employee_id, ast.employee_name
    ),
    ranked_employees AS (
        SELECT
            a.employee_id,
            a.employee_name,
            a.avg_satisfaction,
            DENSE_RANK() OVER (ORDER BY a.avg_satisfaction DESC) AS employee_rank
        FROM avg_scores a
    )
    SELECT
        r.employee_id,
        r.employee_name,
        r.avg_satisfaction,
        r.employee_rank
    FROM ranked_employees r
    WHERE r.employee_rank <= 3;
END;
$$;
--Q2------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION distinct_salaries()
RETURNS TABLE (
    department TEXT,
    salary BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH ranked_salaries AS (
        SELECT
            t.department,
            t.salary,
            DENSE_RANK() OVER (
                PARTITION BY t.department
                ORDER BY t.salary DESC
            ) AS salary_rank
        FROM (
            SELECT DISTINCT department, salary
            FROM twitter_employee
        ) t
    )
    SELECT
        r.department,
        r.salary
    FROM ranked_salaries r
    WHERE r.salary_rank <= 3
    ORDER BY r.department, r.salary DESC;
END;
$$;
