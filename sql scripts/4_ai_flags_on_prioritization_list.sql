/*How many of the Aidoc flagged scans actually get prioritized?
12 scans in ai_flags that are not present in the scans table.
Removed via the join in the CTE
Convert to percentage in Power BI
*/

WITH ai_flagged AS(
    SELECT
        af.scan_id,
        af.flagged
    FROM ai_flags af
    JOIN scans s
        ON s.scan_id=af.scan_id
    WHERE flagged = 1
    ),

prioritized AS (
    SELECT
        scan_id,
        worklist
    FROM reads
    WHERE EXTRACT(YEAR FROM read_completed_at) = 2025
    AND worklist = 'ai-prioritized'
)

SELECT 
    ROUND(100.0 * COUNT(p.scan_id) / COUNT(af.scan_id), 2) AS adoption_rate
FROM ai_flagged af
LEFT JOIN prioritized p
    ON af.scan_id=p.scan_id
