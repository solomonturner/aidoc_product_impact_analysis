WITH flagged_post AS (
    SELECT
        s.scan_id,
        r.worklist,
        ROUND(EXTRACT(EPOCH FROM (r.read_started_at - s.scan_completed_at)) / 60, 2) AS queue_minutes,
        ROUND(EXTRACT(EPOCH FROM (r.read_completed_at - s.scan_completed_at)) / 60, 2) AS turnaround_minutes
    FROM scans s
    JOIN ai_flags af ON af.scan_id = s.scan_id AND af.flagged = 1
    JOIN reads r ON r.scan_id = s.scan_id
    WHERE s.scan_completed_at >= DATE '2025-01-01'
)
SELECT
    worklist,
    COUNT(*) AS cases,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY queue_minutes) AS median_queue,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY turnaround_minutes) AS median_turnaround
FROM flagged_post
GROUP BY worklist;