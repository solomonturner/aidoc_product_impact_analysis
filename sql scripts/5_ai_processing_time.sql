--Average or Median Aidoc processing time
--Visualized in Power BI

SELECT
    AVG(ai_processing_minutes) AS avg_processing_time,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ai_processing_minutes) AS median_processing_time
FROM ai_flags