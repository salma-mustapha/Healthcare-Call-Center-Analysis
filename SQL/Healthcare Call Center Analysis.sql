SELECT 'call_volume' AS table_name, COUNT(*) AS row_count
FROM call_volume

UNION ALL

SELECT 'call_wait_time' AS table_name, COUNT(*) AS row_count
FROM call_wait_time

UNION ALL

SELECT 'call_abandonment' AS table_name, COUNT(*) AS row_count
FROM call_abandonment;

SELECT
    v.field1 AS reporting_period,
    v."SB 1289 Measure 1. Total Call Volume" AS county_name
FROM call_volume v
LEFT JOIN call_wait_time w
    ON v.field1 = w."Reporting Period"
    AND v."SB 1289 Measure 1. Total Call Volume" = w."County Name"
WHERE w."Reporting Period" IS NULL;

SELECT
    COUNT(*) AS actual_call_volume_records
FROM call_volume
WHERE field1 <> 'Reporting Period';

SELECT
    COUNT(*) AS actual_call_abandonment_records
FROM call_abandonment
WHERE "SB 1289 Measure 3. Average Abandonment Rate" <> 'Reporting Period';

SELECT
    COUNT(*) AS actual_call_wait_time_records
FROM call_wait_time
WHERE "Reporting Period" <> 'Reporting Period';

SELECT *
FROM clean_call_volume
LIMIT 5;

CREATE VIEW clean_call_volume AS
SELECT
    field1 AS reporting_period,
    "SB 1289 Measure 1. Total Call Volume" AS county_name,
    REPLACE(field5, ',', '') AS total_calls
FROM call_volume
WHERE field1 <> 'Reporting Period';

SELECT *
FROM clean_call_volume
LIMIT 5;

CREATE VIEW clean_call_abandonment AS
SELECT
    "SB 1289 Measure 3. Average Abandonment Rate" AS reporting_period,
    field2 AS county_name,
    CAST(field3 AS REAL) AS abandonment_rate
FROM call_abandonment
WHERE "SB 1289 Measure 3. Average Abandonment Rate" <> 'Reporting Period';

SELECT *
FROM clean_call_abandonment
LIMIT 5;

CREATE VIEW clean_call_wait_time AS
SELECT
    "Reporting Period" AS reporting_period,
    "County Name" AS county_name,
    "Average Wait Time All Languages" AS avg_wait_time
FROM call_wait_time
WHERE "Reporting Period" <> 'Reporting Period';

SELECT *
FROM clean_call_wait_time
LIMIT 5;

SELECT DISTINCT reporting_period
FROM clean_call_volume
ORDER BY reporting_period;

SELECT DISTINCT reporting_period
FROM clean_call_abandonment
ORDER BY reporting_period;

SELECT DISTINCT
    'Call Volume' AS dataset,
    reporting_period
FROM clean_call_volume

UNION

SELECT DISTINCT
    'Wait Time' AS dataset,
    reporting_period
FROM clean_call_wait_time

UNION

SELECT DISTINCT
    'Abandonment' AS dataset,
    reporting_period
FROM clean_call_abandonment

ORDER BY dataset, reporting_period;

CREATE VIEW analysis_call_volume AS
SELECT
    CASE reporting_period
        WHEN 'Jan-26' THEN '2026-01'
        WHEN 'Feb-26' THEN '2026-02'
        WHEN 'Mar-26' THEN '2026-03'
        WHEN 'Apr-26' THEN '2026-04'
        WHEN 'May-26' THEN '2026-05'
        WHEN 'Jun-26' THEN '2026-06'
    END AS month,
    county_name,
    CAST(total_calls AS INTEGER) AS total_calls
FROM clean_call_volume;

SELECT *
FROM analysis_call_volume
LIMIT 5;

DROP VIEW IF EXISTS analysis_call_volume;

CREATE VIEW analysis_call_volume AS
SELECT
    CASE reporting_period
        WHEN 'Jan-26' THEN '2026-01'
        WHEN 'Feb-26' THEN '2026-02'
        WHEN 'Mar-26' THEN '2026-03'
        WHEN 'Apr-26' THEN '2026-04'
        WHEN 'May-26' THEN '2026-05'
        WHEN 'Jun-26' THEN '2026-06'
    END AS month,
    county_name,
    CAST(total_calls AS INTEGER) AS total_calls
FROM clean_call_volume;

SELECT *
FROM analysis_call_volume
LIMIT 5;

DROP VIEW IF EXISTS analysis_call_abandonment;

CREATE VIEW analysis_call_abandonment AS
SELECT
    CASE reporting_period
        WHEN 'January 2026' THEN '2026-01'
        WHEN 'February 2026' THEN '2026-02'
        WHEN 'March 2026' THEN '2026-03'
        WHEN 'April 2026' THEN '2026-04'
        WHEN 'May 2026' THEN '2026-05'
        WHEN 'June 2026' THEN '2026-06'
    END AS month,
    county_name,
    abandonment_rate
FROM clean_call_abandonment;

SELECT *
FROM analysis_call_abandonment
LIMIT 5;

DROP VIEW IF EXISTS analysis_call_wait_time;

CREATE VIEW analysis_call_wait_time AS
SELECT
    CASE reporting_period
        WHEN 'Jan-26' THEN '2026-01'
        WHEN 'Feb-26' THEN '2026-02'
        WHEN 'Mar-26' THEN '2026-03'
        WHEN 'Apr-26' THEN '2026-04'
        WHEN 'May-26' THEN '2026-05'
        WHEN 'Jun-26' THEN '2026-06'
    END AS month,
    county_name,
    avg_wait_time,
    (
        CAST(substr(avg_wait_time, 1, instr(avg_wait_time, ':') - 1) AS INTEGER) * 60
        +
        CAST(
            substr(
                avg_wait_time,
                instr(avg_wait_time, ':') + 1,
                2
            ) AS INTEGER
        )
        +
        CAST(
            substr(avg_wait_time, -2) AS INTEGER
        ) / 60.0
    ) AS avg_wait_minutes
FROM clean_call_wait_time;

SELECT *
FROM analysis_call_wait_time
LIMIT 5;

DROP VIEW IF EXISTS healthcare_call_center;

CREATE VIEW healthcare_call_center AS
SELECT
    v.month,
    v.county_name,
    v.total_calls,
    a.abandonment_rate,
    w.avg_wait_minutes
FROM analysis_call_volume v
LEFT JOIN analysis_call_abandonment a
    ON v.month = a.month
    AND v.county_name = a.county_name
LEFT JOIN analysis_call_wait_time w
    ON v.month = w.month
    AND v.county_name = w.county_name;
	
SELECT *
FROM healthcare_call_center
LIMIT 10;

SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN total_calls IS NULL THEN 1 ELSE 0 END) AS missing_call_volume,
    SUM(CASE WHEN abandonment_rate IS NULL THEN 1 ELSE 0 END) AS missing_abandonment_rate,
    SUM(CASE WHEN avg_wait_minutes IS NULL THEN 1 ELSE 0 END) AS missing_wait_time
FROM healthcare_call_center;

SELECT
    month,
    county_name,
    total_calls,
    avg_wait_minutes
FROM healthcare_call_center
WHERE abandonment_rate IS NULL
ORDER BY month, county_name;

SELECT
    reporting_period,
    county_name,
    abandonment_rate
FROM clean_call_abandonment
WHERE county_name = 'Napa'
ORDER BY reporting_period;

SELECT
    SUM(total_calls) AS total_calls,
    AVG(total_calls) AS avg_calls_per_county_month,
    AVG(avg_wait_minutes) AS avg_wait_minutes,
    AVG(abandonment_rate) AS avg_abandonment_rate
FROM healthcare_call_center;

SELECT
    month,
    SUM(total_calls) AS total_calls,
    ROUND(AVG(avg_wait_minutes), 2) AS avg_wait_minutes,
    ROUND(AVG(abandonment_rate) * 100, 2) AS avg_abandonment_rate_pct
FROM healthcare_call_center
GROUP BY month
ORDER BY month;

SELECT
    county_name,
    SUM(total_calls) AS total_calls,
    ROUND(AVG(avg_wait_minutes), 2) AS avg_wait_minutes,
    ROUND(AVG(abandonment_rate) * 100, 2) AS avg_abandonment_rate_pct
FROM healthcare_call_center
GROUP BY county_name
ORDER BY total_calls DESC
LIMIT 10;

SELECT
    county_name,
    ROUND(AVG(avg_wait_minutes), 2) AS avg_wait_minutes,
    SUM(total_calls) AS total_calls,
    ROUND(AVG(abandonment_rate) * 100, 2) AS avg_abandonment_rate_pct
FROM healthcare_call_center
GROUP BY county_name
ORDER BY avg_wait_minutes DESC
LIMIT 10;

SELECT
    county_name,
    ROUND(AVG(avg_wait_minutes), 2) AS avg_wait_minutes,
    SUM(total_calls) AS total_calls,
    ROUND(AVG(abandonment_rate) * 100, 2) AS avg_abandonment_rate_pct
FROM healthcare_call_center
GROUP BY county_name
ORDER BY avg_wait_minutes ASC
LIMIT 10;

SELECT
    county_name,
    SUM(total_calls) AS total_calls,
    ROUND(AVG(avg_wait_minutes), 2) AS avg_wait_minutes,
    ROUND(AVG(abandonment_rate) * 100, 2) AS avg_abandonment_rate_pct
FROM healthcare_call_center
GROUP BY county_name
HAVING SUM(total_calls) >= 100000
ORDER BY avg_wait_minutes DESC
LIMIT 10;

SELECT
    county_name,
    SUM(total_calls) AS total_calls,
    ROUND(AVG(abandonment_rate) * 100, 2) AS avg_abandonment_rate_pct,
    ROUND(AVG(avg_wait_minutes), 2) AS avg_wait_minutes
FROM healthcare_call_center
GROUP BY county_name
HAVING SUM(total_calls) >= 100000
ORDER BY avg_abandonment_rate_pct DESC
LIMIT 10;

SELECT
    ROUND(
        (
            SUM(
                (avg_wait_minutes - avg_wait) *
                (abandonment_rate - avg_abandonment)
            )
        )
        /
        SQRT(
            SUM(
                (avg_wait_minutes - avg_wait) *
                (avg_wait_minutes - avg_wait)
            )
            *
            SUM(
                (abandonment_rate - avg_abandonment) *
                (abandonment_rate - avg_abandonment)
            )
        ),
        3
    ) AS wait_abandonment_correlation
FROM healthcare_call_center
CROSS JOIN (
    SELECT
        AVG(avg_wait_minutes) AS avg_wait,
        AVG(abandonment_rate) AS avg_abandonment
    FROM healthcare_call_center
)
WHERE avg_wait_minutes IS NOT NULL
  AND abandonment_rate IS NOT NULL;
  
SELECT
    CASE
        WHEN avg_wait_minutes < 15 THEN 'Under 15 min'
        WHEN avg_wait_minutes < 30 THEN '15–29 min'
        WHEN avg_wait_minutes < 60 THEN '30–59 min'
        ELSE '60+ min'
    END AS wait_time_group,
    COUNT(*) AS county_month_records,
    ROUND(AVG(avg_wait_minutes), 2) AS avg_wait_minutes,
    ROUND(AVG(abandonment_rate) * 100, 2) AS avg_abandonment_rate_pct
FROM healthcare_call_center
WHERE abandonment_rate IS NOT NULL
GROUP BY wait_time_group
ORDER BY
    CASE wait_time_group
        WHEN 'Under 15 min' THEN 1
        WHEN '15–29 min' THEN 2
        WHEN '30–59 min' THEN 3
        WHEN '60+ min' THEN 4
    END;
	
SELECT
    month,
    county_name,
    total_calls,
    ROUND(avg_wait_minutes, 2) AS avg_wait_minutes,
    ROUND(abandonment_rate * 100, 2) AS abandonment_rate_pct
FROM healthcare_call_center
WHERE avg_wait_minutes >= 60
   OR abandonment_rate >= 40
ORDER BY avg_wait_minutes DESC;

SELECT
    county_name,
    SUM(total_calls) AS total_calls,
    ROUND(AVG(abandonment_rate) * 100, 2) AS avg_abandonment_rate_pct,
    ROUND(AVG(avg_wait_minutes), 2) AS avg_wait_minutes
FROM healthcare_call_center
GROUP BY county_name
HAVING SUM(total_calls) >= 100000
   AND AVG(abandonment_rate) >= 0.30
ORDER BY avg_abandonment_rate_pct DESC;

SELECT
    county_name,
    ROUND(
        AVG(CASE WHEN month = '2026-01' THEN avg_wait_minutes END), 2
    ) AS jan_wait_minutes,
    ROUND(
        AVG(CASE WHEN month = '2026-06' THEN avg_wait_minutes END), 2
    ) AS jun_wait_minutes,
    ROUND(
        (AVG(CASE WHEN month = '2026-06' THEN avg_wait_minutes END) -
         AVG(CASE WHEN month = '2026-01' THEN avg_wait_minutes END)), 2
    ) AS wait_increase_minutes,
    ROUND(
        AVG(CASE WHEN month = '2026-01' THEN abandonment_rate END) * 100, 2
    ) AS jan_abandonment_pct,
    ROUND(
        AVG(CASE WHEN month = '2026-06' THEN abandonment_rate END) * 100, 2
    ) AS jun_abandonment_pct
FROM healthcare_call_center
GROUP BY county_name
HAVING jun_wait_minutes > jan_wait_minutes
   AND jun_abandonment_pct > jan_abandonment_pct
ORDER BY wait_increase_minutes DESC;

SELECT
    county_name,
    SUM(total_calls) AS total_calls,
    ROUND(AVG(avg_wait_minutes), 2) AS avg_wait_minutes,
    ROUND(AVG(abandonment_rate) * 100, 2) AS avg_abandonment_rate_pct
FROM healthcare_call_center
GROUP BY county_name
HAVING SUM(total_calls) >= 250000
   AND AVG(avg_wait_minutes) >= 40
   AND AVG(abandonment_rate) >= 0.30
ORDER BY avg_abandonment_rate_pct DESC;

SELECT
    month,
    SUM(total_calls) AS total_calls,
    ROUND(AVG(avg_wait_minutes), 2) AS avg_wait_minutes,
    ROUND(AVG(abandonment_rate) * 100, 2) AS avg_abandonment_rate_pct
FROM healthcare_call_center
GROUP BY month
ORDER BY month;

SELECT
    county_name,
    SUM(total_calls) AS total_calls,
    ROUND(
        AVG(CASE WHEN month = '2026-01' THEN abandonment_rate END) * 100,
        2
    ) AS jan_abandonment_pct,
    ROUND(
        AVG(CASE WHEN month = '2026-06' THEN abandonment_rate END) * 100,
        2
    ) AS jun_abandonment_pct,
    ROUND(
        (
            AVG(CASE WHEN month = '2026-06' THEN abandonment_rate END) -
            AVG(CASE WHEN month = '2026-01' THEN abandonment_rate END)
        ) * 100,
        2
    ) AS abandonment_change_pct_points
FROM healthcare_call_center
GROUP BY county_name
HAVING SUM(total_calls) >= 100000
   AND jan_abandonment_pct IS NOT NULL
   AND jun_abandonment_pct IS NOT NULL
   AND jun_abandonment_pct < jan_abandonment_pct
ORDER BY abandonment_change_pct_points ASC
LIMIT 10;
