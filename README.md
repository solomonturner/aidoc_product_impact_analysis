# Aidoc Product Impact Analysis: Did AI Triage Shorten Time-to-Diagnosis?

**Tools:** SQL (PostgreSQL) · Power BI

> **Note:** Northgate Health is a fictional hospital group created for this project. Aidoc is a real AI radiology company, and this analysis evaluates its product at the fictional Northgate sites. All data is synthetic and does not reflect real patient records or actual Aidoc performance. The dataset was designed to simulate a realistic hospital evaluation for analytical purposes.

## Executive Summary

I evaluated Aidoc, an AI-powered radiology triage product, across three hospitals in Northgate Health's network, to answer a question from the Chief of Radiology:

**"We've had Aidoc running across our hospitals for a year now. Leadership wants to know if it's actually making a difference, and whether we should renew and expand it to more sites. Can you find out?"**

The answer is yes. Median turnaround time for confirmed critical scans fell by 49.2 minutes, from 93.1 minutes before implementation to 44.0 minutes afterward. This exceeded the predefined 30-minute improvement threshold by 19.1 minutes. The proportion of critical scans read within 60 minutes increased by 55.1 percentage points, from 15.2% to 70.3%, substantially exceeding the 10-point target.

The improvement was concentrated in the radiologist queue rather than the reading process itself. Median queue time decreased by 50.2 minutes, while median read duration remained virtually unchanged at 22.0 minutes before implementation and 21.9 minutes afterward. A comparison of post-implementation cases confirms the mechanism: scans placed on the AI-prioritized worklist had a median turnaround time of 38 minutes, compared with 90 minutes for flagged scans that remained on the standard worklist.

Adoption was strong, with 86.2% of flagged scans reaching the AI-prioritized worklist (2,576 of 2,990). However, 414 flagged scans did not receive prioritization, and Aidoc failed to flag 593 scans that were subsequently confirmed as critical. These missed cases experienced a median turnaround of 94.5 minutes, close to the pre-AI baseline.

Performance also varied by hospital. Riverside Memorial improved from 94.1 to 60.1 minutes, lagging behind Northgate General and St. Clair Community, which reached 41.1 and 41.9 minutes, respectively.

**Recommendation: Renew the Aidoc subscription and expand to other hospitals in the Northgate Health network.** Expansion should be accompanied by investigation into Riverside's relative inefficiencies, and ongoing monitoring of model performance.

The analysis follows the DMAIC framework (Define, Measure, Analyze, Improve, Control), a Lean Six Sigma approach, providing a structured way to evaluate the product's impact and identify opportunities for continued improvement.


[aidocdashboardgif.webm](https://github.com/user-attachments/assets/737b9375-ba28-4ce8-a690-101bc7b2d774)


## DMAIC

### 1. Define

**Problem statement.** Aidoc had been operational across Northgate Health for one year. Leadership needed to determine whether the technology delivered a meaningful improvement in critical scan turnaround times before deciding whether to renew and expand the subscription.

**Critical-to-quality (CTQ) measures.** The primary measure was turnaround time, defined as the time between scan completion and the radiologist completing the read (read\_completed\_at minus scan\_completed\_at), for scans subsequently confirmed as critical. The secondary measure was queue time, defined as the time between scan completion and the radiologist beginning the review (read\_started\_at minus scan\_completed\_at). Queue time was selected as a key driver because Aidoc prioritizes critical scans in the radiologist's worklist rather than accelerating the reading process itself. Read completion serves as a proxy for identifying a critical finding. The dataset does not establish when a finding was communicated or acted upon clinically.

**Scope.** Three Northgate Health hospitals. January 2023 to December 2025. CT scans only. Four critical finding types: intracranial hemorrhage, pulmonary embolism, cervical spine fracture, and large vessel occlusion. Comparison of 24 months before implementation against 12 months afterward. Treatment outcomes, subscription costs, individual radiologist review times, other AI products, and non-CT imaging were outside the scope of the available data.

**Success criteria.** Two improvement thresholds were established before measuring the results: reduce median turnaround time for confirmed critical scans by at least 30 minutes, and increase the proportion of confirmed critical scans read within 60 minutes by at least 10 percentage points. The 30-minute threshold was selected based on the clinical significance of faster stroke diagnosis, where approximately 30 minutes of treatment delay is associated with substantial neuronal loss and worse patient outcomes. The threshold represents the minimum improvement considered meaningful for the renewal decision, rather than simply relying on statistical significance. Based on the pre-AI baseline, the resulting targets were a median turnaround of 63.1 minutes or less (93.1 minus 30), and a share read within 60 minutes of at least 25.2% (15.2% plus 10 percentage points).

### 2. Measure

**Data sources.** The dataset contains 95,302 cleaned CT scans, covering 24 months before Aidoc implementation and 12 months afterward. Aidoc went live at all three hospitals on January 1, 2025.

| File | Rows | Contents |
| --- | --- | --- |
| `data/sites.csv` | 3 | Hospital reference information |
| `data/scans.csv` | 95,302 | CT scans, hospital, modality, shift, scan completion, ground-truth critical flag and finding type |
| `data/ai_flags.csv` | 33,559 | Aidoc flags, finding type, confidence, flagged status and processing time |
| `data/reads.csv` | 95,310 | Radiologist, read start and completion timestamps, worklist and confirmed finding |

**Data preparation and pipeline.** Power Query was used to clean and consolidate the source CSV files. The cleaned tables were exported to CSV and imported into PostgreSQL through pgAdmin. SQL analysis was performed in VS Code, with the resulting queries and metrics used to build the Power BI dashboard.

**Data cleaning and quality checks.** Cleaning was performed at the individual measure level rather than excluding an entire record because of one invalid field. Null or non-positive processing times were excluded from the relevant processing-time calculation only. Impossible timestamps were excluded from turnaround calculations. Records with otherwise valid information were retained for unaffected measures. Twelve orphan records in ai\_flags and eight in reads, containing scan IDs without a matching scan record, were excluded through the joins and documented in the data quality log. Results were checked for clustering by hospital and month.

**Baseline validation.** Monthly median turnaround times remained relatively stable throughout the pre-AI period, ranging from approximately 87 to 98 minutes between January 2023 and December 2024. Following the January 2025 implementation, monthly medians dropped to approximately 42 to 47 minutes. There was no apparent gradual improvement before implementation that would readily explain the subsequent reduction.

### 3. Analyze

**1. Turnaround time, the primary measure.** Median turnaround time for confirmed critical scans decreased from 93.1 minutes before implementation to 44.0 minutes afterward, an improvement of 49.2 minutes. This exceeded the predefined 30-minute threshold by 19.1 minutes, and cleared the target of 63.1 minutes by a considerable margin.

**2. Proportion of critical scans read within 60 minutes.** The percentage of confirmed critical scans read within 60 minutes increased from 15.21% (861 of 5,659) before implementation to 70.26% (2,079 of 2,959) afterward, an improvement of 55.05 percentage points. This substantially exceeded the predefined 10-percentage-point improvement target.

**3. Queue time vs. read duration.** The most important operational finding was where the improvement occurred.

| Measure | Pre-AI | Post-AI |
| --- | --- | --- |
| Median turnaround | 93.1 min | 44.0 min |
| Median queue time | 70.8 min | 20.7 min |
| Median read duration | 22.0 min | 21.9 min |

Queue time decreased by approximately 50.2 minutes, while reading duration remained virtually unchanged. The primary benefit of Aidoc was reducing the time critical scans spent waiting for radiologist review, rather than making radiologists faster at interpreting scans.

**4. Performance by hospital.** All three hospitals improved, but Riverside Memorial experienced a considerably smaller reduction, although it still beat the baseline threshold.

| Hospital | Pre-AI | Post-AI | Improvement |
| --- | --- | --- | --- |
| Northgate General | 91.8 min | 41.1 min | 50.7 min |
| St. Clair Community | 93.6 min | 41.9 min | 51.7 min |
| Riverside Memorial | 94.1 min | 60.1 min | 34.0 min |

Riverside's post-AI median turnaround was approximately 19 minutes higher than the other two hospitals, making it the primary site for further investigation.

**5. Mechanism test: prioritized vs. standard worklist.** To understand the operational impact of Aidoc, I compared flagged scans that reached the AI-prioritized worklist against flagged scans that remained on the standard worklist.

| Measure | AI-Prioritized | Standard Worklist |
| --- | --- | --- |
| Scans | 2,576 | 414 |
| Median queue time | 15.5 min | 69.5 min |
| Median turnaround | 38.0 min | 90.4 min |

Flagged scans reaching the AI-prioritized worklist experienced a median turnaround approximately 52 minutes faster than those remaining on the standard worklist. This provides strong evidence that worklist prioritization is an important driver of the observed improvement. However, the comparison is observational and does not independently establish causation.

**6. Adoption and AI processing performance.** Aidoc flagged 2,990 of 33,547 post-implementation scans, representing 8.91% of total volume. Of those flagged scans, 2,576 reached the AI-prioritized worklist, a prioritization adoption rate of 86.2%. The remaining 414 flagged scans did not receive the intended prioritization. AI processing time was consistent, with a median of 5.0 minutes and a mean of approximately 5.01 minutes.

**7. Detection accuracy: precision vs. sensitivity.** Two measures were used to evaluate Aidoc's detection performance. Precision asks: of the scans flagged by Aidoc, how many were actually critical? Sensitivity asks: of all scans that were actually critical, how many did Aidoc successfully identify?

| Measure | Result |
| --- | --- |
| Total flagged scans | 2,990 |
| True critical scans flagged | 2,366 |
| False positives | 624 |
| Total true critical scans | 2,959 |
| Critical scans missed | 593 |
| Precision | 79.13% |
| Sensitivity | 79.96% |

Precision was 79.13%, meaning approximately four out of five scans flagged by Aidoc were subsequently confirmed as critical. Sensitivity was 79.96%, meaning Aidoc successfully identified approximately four out of five scans that were actually critical. The two measures use the same numerator but different denominators. Their similar percentages are coincidental.

The more significant concern is the 593 critical scans that Aidoc failed to flag. These cases remained on the standard worklist and experienced a median turnaround of 94.5 minutes, compared with 40.3 minutes for successfully flagged critical scans. There is an important trade-off between sensitivity and precision. Lowering the detection threshold could identify more critical scans, but would also increase false positives and potentially create additional workload for radiologists. Aidoc's current performance represents a balance between the two, but the missed critical cases warrant further investigation.

### 4. Improve

The analysis identified five opportunities to improve performance and strengthen the implementation.

1. **Renew and expand Aidoc.** The product exceeded both predefined success thresholds, demonstrated consistent improvement across all four finding types, and showed strong adoption. The mechanism analysis also supports the conclusion that prioritization is an important driver of the improvement. Renewal and expansion to other hospitals in the Northgate Health network are recommended.
2. **Address the prioritization adoption gap.** A total of 414 flagged scans did not reach the AI-prioritized worklist. Investigate the cause of these missed prioritization events by hospital and shift, working with the technical team to identify potential routing or worklist configuration issues. The objective should be to ensure that flagged scans consistently receive the intended prioritization.
3. **Work with Aidoc to reduce missed critical cases.** The 593 critical scans that Aidoc failed to identify represent the most significant detection gap. Work with Aidoc's team to investigate common characteristics among missed cases, including finding type, hospital, shift, and confidence scores where available. Review opportunities to improve model sensitivity through threshold adjustments or model training, while considering the operational impact of additional false positives. The objective is to improve detection without creating excessive alert fatigue or unnecessary workload for radiologists. No software solution is perfect, and the goal is to keep improving the model so the network operates at maximum efficiency.
4. **Monitor false positives and alert fatigue.** Aidoc generated 624 false-positive flags, representing scans that were prioritized but subsequently determined not to be critical. Although some false positives are expected in an AI-assisted triage system, excessive alerts can reduce operational efficiency and potentially lead to alert fatigue. Track precision over time and work with radiologists to assess whether false-positive alerts are affecting the effectiveness of the prioritized worklist.
5. **Investigate Riverside Memorial.** Riverside experienced the smallest improvement, with a post-AI median turnaround of 60.1 minutes compared with approximately 41 minutes at the other two hospitals. Investigate whether Riverside's performance is related to lower adoption or prioritization rates, differences in AI flagging performance, radiologist staffing and availability, worklist configuration and routing, or differences in scan volume or operational processes. Bringing Riverside closer to the network average represents a significant opportunity for further improvement.

### 5. Control

**Dashboard and monitoring.** To sustain the improvements and monitor ongoing performance, Northgate should establish a monthly reporting process using the Power BI dashboard. The dashboard includes four KPI cards and three primary visualizations. KPI cards: median turnaround time for confirmed critical scans, percentage of critical scans read within 60 minutes, median queue time, and AI prioritization adoption rate. Visualizations: monthly median turnaround trend, including the January 2025 implementation date and the 63.1-minute target; median turnaround by hospital, comparing pre- and post-implementation performance; and median turnaround by worklist, comparing AI-prioritized and standard worklist cases.

**Ongoing performance measures.** The following metrics should be monitored monthly:

| Metric | Purpose |
| --- | --- |
| Median turnaround | Confirm sustained improvement |
| Percentage read within 60 minutes | Monitor performance against the predefined target |
| Median queue time | Identify changes in radiologist waiting time |
| Prioritization adoption | Ensure flagged scans receive the intended boost |
| Precision | Monitor false-positive alerts |
| Sensitivity | Monitor the proportion of critical scans detected |
| Missed critical scans | Identify potential safety and detection gaps |

The Chief of Radiology should review the dashboard monthly, with particular attention to Riverside Memorial, prioritization adoption, and missed critical cases.

**Limitations.** No randomized control group: the analysis uses a before-and-after comparison. Although the baseline was stable and non-critical scans showed little change, other operational factors may have contributed to the observed improvement. Read completion as a proxy: turnaround time measures scan completion to radiologist read completion. It does not establish when a finding was communicated or when clinical action occurred. No cost data: the analysis does not include subscription fees, implementation costs, or operational savings. Therefore, a financial return on investment cannot be calculated. No patient outcome data: faster radiologist reads are an important operational improvement, but the dataset does not establish whether Aidoc improved treatment times, patient outcomes, or mortality. Synthetic data: all records were generated for analytical purposes and do not represent actual hospital performance or Aidoc product results. The results support renewal and expansion based on operational performance, but the network should continue evaluating the product's effectiveness, safety, and financial value as additional data becomes available.

## SQL Queries

All analysis queries are in the `sql/` folder. The key queries are reproduced below in collapsible blocks. Some medians are calculated in Power BI from the row-level query results, except where noted.

<details>
<summary>Turnaround and queue (Queries 1 and 2)</summary>

Row-level turnaround and queue times for confirmed critical scans, staged pre-AI and post-AI by scan date. Power BI takes the median.

```sql
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
```

```sql
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
```

</details>

<details>
<summary>Share read within 60 minutes (Query 3)</summary>

```sql
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
```

</details>

<details>
<summary>Adoption (Query 4)</summary>

```sql
/*How many of the Aidoc flagged scans actually get prioritized?
QUestion to explore in #6 "Does AI confidence interval affect
prioritization?"
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
```

</details>

<details>
<summary>AI processing time and flag rate (Queries 5 and 8)</summary>

```sql
--Average or Median Aidoc processing time
--Visualized in Power BI (median aggregation)

SELECT
    AVG(ai_processing_minutes) AS avg_processing_time,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ai_processing_minutes) AS median_processing_time
FROM ai_flags
```

```sql
--Flag rate: share of post-AI scans Aidoc flagged
--Feeds KPI card 4 (with precision)
SELECT
    COUNT(*) AS post_scans,
    SUM(CASE WHEN af.flagged = 1 THEN 1 ELSE 0 END) AS flagged_scans,
    ROUND(100.0 * SUM(CASE WHEN af.flagged = 1 THEN 1 ELSE 0 END)::numeric / COUNT(*), 2) AS flag_rate_pct
FROM scans s
LEFT JOIN ai_flags af ON af.scan_id = s.scan_id
WHERE s.scan_completed_at >= DATE '2025-01-01';
```

</details>

<details>
<summary>Precision and sensitivity (Query 6)</summary>

```sql
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
```

</details>

<details>
<summary>Mechanism test: prioritized vs. standard worklist (Query 9)</summary>

```sql
--Mechanism test: flagged cases on the AI-prioritized worklist vs the standard worklist, post-AI only
--Feeds breakdown visual 3
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
```

</details>

<details>
<summary>Volumes (Query 10)</summary>

```sql
--Volumes: scans and criticals by stage
--Feeds KPI card 8 (confounder check)
SELECT
    CASE WHEN scan_completed_at < DATE '2025-01-01' THEN 'Pre-AI' ELSE 'Post-AI' END AS stage,
    COUNT(*) AS scans,
    SUM(CASE WHEN tru_critical = 1 THEN 1 ELSE 0 END) AS critical_scans
FROM scans
GROUP BY stage
ORDER BY stage DESC;
```

</details>
