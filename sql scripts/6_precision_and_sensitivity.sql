/*What did Aidoc miss? 
Post-AI implementation
Precision: of everything flagged, how many were truly critical?
Sensitivity: of all truly critical cases, how many did aidoc catch?
*/

WITH post_ai AS (
    SELECT
        s.scan_id,
        af.flagged,
        s.tru_critical
    FROM scans s
    JOIN ai_flags af ON af.scan_id = s.scan_id
    WHERE s.scan_completed_at >= DATE '2025-01-01'
),

read_counts AS (
    SELECT
        SUM(CASE WHEN flagged = 1 AND tru_critical = 1 THEN 1 ELSE 0 END) AS true_positives,
        SUM(CASE WHEN flagged = 1 AND tru_critical = 0 THEN 1 ELSE 0 END) AS false_positives,
        SUM(CASE WHEN flagged = 0 AND tru_critical = 1 THEN 1 ELSE 0 END) AS false_negatives,
        SUM(CASE WHEN flagged = 1 THEN 1 ELSE 0 END) AS flagged_scans,
        SUM(CASE WHEN tru_critical = 1 THEN 1 ELSE 0 END) AS true_critical_scans
    FROM post_ai
)

SELECT
    true_positives,
    false_positives,
    false_negatives,
    flagged_scans,
    true_critical_scans,
    ROUND(100.0 * true_positives::numeric / flagged_scans, 2) AS precision_pct,
    ROUND(100.0 * true_positives::numeric / true_critical_scans, 2) AS sensitivity_pct
FROM read_counts;