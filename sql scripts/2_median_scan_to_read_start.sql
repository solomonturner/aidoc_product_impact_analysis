/*
Median to be calculated in Power BI. 
PERCENTILE_CONT(0.5) not used here
The time between the scan taking place and the radiologist 
reading the scan is important, because this determines whether
Aidoc is prioritizing the critical scans and whether radiologists 
are attending to the most critical scans/patients
*/
WITH scan_complete AS (
    SELECT
        scan_id,
        scan_completed_at,
        site_id,
        tru_critical
    FROM scans
    WHERE tru_critical = 1
),
read_started AS (
    SELECT
        scan_id,
        read_started_at
    FROM reads
)
SELECT
    sc.scan_id,
    sc.site_id,
    rs.read_started_at - sc.scan_completed_at AS read_turnaround,
    ROUND(EXTRACT(EPOCH FROM (rs.read_started_at - sc.scan_completed_at)) / 60, 2) AS read_turnaround_minutes,
    EXTRACT(YEAR FROM sc.scan_completed_at) AS scan_year,
    CASE
        WHEN EXTRACT(YEAR FROM sc.scan_completed_at) <= 2024 THEN 'Pre-AI'
        ELSE 'Post-AI'
        END AS stage
FROM scan_complete sc
INNER JOIN read_started rs 
    ON rs.scan_id = sc.scan_id
ORDER BY 
    scan_id,
    scan_year;