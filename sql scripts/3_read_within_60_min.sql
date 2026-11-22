WITH scan_complete AS (
    SELECT
        scan_id,
        scan_completed_at,
        site_id,
        tru_critical
    FROM scans
    WHERE tru_critical = 1
),
read_complete AS (
    SELECT
        scan_id,
        read_completed_at
    FROM reads
),
read_within_60 AS (
    SELECT
        sc.scan_id,
        ROUND(EXTRACT(EPOCH FROM (rc.read_completed_at - sc.scan_completed_at)) / 60, 2) AS turnaround_minutes,
        CASE
            WHEN sc.scan_completed_at < DATE '2025-01-01' THEN 'Pre-AI'
            ELSE 'Post-AI'
        END AS stage
    FROM scan_complete sc
    JOIN read_complete rc ON sc.scan_id = rc.scan_id
)
SELECT
    stage,
    SUM(CASE WHEN turnaround_minutes <= 60 THEN 1 ELSE 0 END) AS within_60_count,
    COUNT(*) AS total_critical_cases,
    ROUND(100.0 * SUM(CASE WHEN turnaround_minutes <= 60 THEN 1 ELSE 0 END)::numeric / COUNT(*), 2) AS percent_read_within_60
FROM read_within_60
GROUP BY stage
ORDER BY stage DESC;