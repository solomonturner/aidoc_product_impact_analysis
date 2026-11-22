--Median to be calculated in Power BI
--From parsing through the data, looks like Aidoc
--makes a big difference in total turnaround time
--Only need criticals as aidocs primary benefit is flagging
--and prioritizing scans deemed to be critical
WITH scan_complete AS (
    SELECT
        scan_id,
        scan_completed_at,
        site_id,
        shift,
        true_finding_type,
        tru_critical
    FROM scans
    WHERE tru_critical = 1
),
read_complete AS (
    SELECT
        scan_id,
        read_completed_at
    FROM reads
)
SELECT
    sc.scan_id,
    sc.site_id,
    sc.shift,
    sc.true_finding_type,
    sc.scan_completed_at,
    rc.read_completed_at - sc.scan_completed_at AS turnaround,
    ROUND(EXTRACT(EPOCH FROM (rc.read_completed_at - sc.scan_completed_at)) / 60, 2) AS turnaround_minutes,
    EXTRACT(YEAR FROM sc.scan_completed_at) AS scan_year,
    CASE
        WHEN EXTRACT(YEAR FROM sc.scan_completed_at) <= 2024 THEN 'Pre-AI'
        ELSE 'Post-AI'
        END AS stage
FROM scan_complete sc
INNER JOIN read_complete rc 
    ON rc.scan_id = sc.scan_id
ORDER BY 
    scan_id,
    scan_year;
