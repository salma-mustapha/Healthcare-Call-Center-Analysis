-- 1. TOTAL COMPLAINTS
SELECT COUNT(*) AS total_complaints
FROM CFPB_Complaints_May_July_2026;


-- 2. COMPLAINTS BY PRODUCT
SELECT
    Product,
    COUNT(*) AS total_complaints
FROM CFPB_Complaints_May_July_2026
GROUP BY Product
ORDER BY total_complaints DESC;


-- 3. TOP 10 COMPLAINT ISSUES
SELECT
    Issue,
    COUNT(*) AS total_complaints
FROM CFPB_Complaints_May_July_2026
GROUP BY Issue
ORDER BY total_complaints DESC
LIMIT 10;
SELECT
    Issue,
    COUNT(*) AS total_complaints
FROM CFPB_Complaints_May_July_2026
GROUP BY Issue
ORDER BY total_complaints DESC
LIMIT 10;


-- 4. TOP 10 COMPANIES BY COMPLAINTS
SELECT
    Company,
    COUNT(*) AS total_complaints
FROM CFPB_Complaints_May_July_2026
GROUP BY Company
ORDER BY total_complaints DESC
LIMIT 10;


-- 5. COMPLAINTS BY MONTH
SELECT
    strftime('%Y-%m', "Date received") AS month,
    COUNT(*) AS total_complaints
FROM CFPB_Complaints_May_July_2026
GROUP BY month
ORDER BY month;


-- 6. COMPANY RESPONSE TO CONSUMER
SELECT
    "Company response to consumer",
    COUNT(*) AS total_complaints,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM CFPB_Complaints_May_July_2026),
        2
    ) AS percentage
FROM CFPB_Complaints_May_July_2026
GROUP BY "Company response to consumer"
ORDER BY total_complaints DESC;

-- 7. TIMELY RESPONSE RATE
SELECT
    SUM(
        CASE
            WHEN "Timely response?" = 'Yes' THEN 1
            ELSE 0
        END
    ) AS timely_responses,

    COUNT(*) AS total_complaints,

    ROUND(
        SUM(
            CASE
                WHEN "Timely response?" = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS timely_response_rate
FROM CFPB_Complaints_May_July_2026;

-- 8. TOP 10 SUB-ISSUES
SELECT
    "Sub-issue",
    COUNT(*) AS total_complaints
FROM CFPB_Complaints_May_July_2026
WHERE "Sub-issue" IS NOT NULL
    AND "Sub-issue" <> ''
GROUP BY "Sub-issue"
ORDER BY total_complaints DESC
LIMIT 10;

-- 9. RESPONSE OUTCOMES BY PRODUCT
SELECT
    Product,
    COUNT(*) AS total_complaints,

    SUM(
        CASE
            WHEN "Company response to consumer" = 'Closed with monetary relief'
            THEN 1
            ELSE 0
        END
    ) AS monetary_relief_complaints,

    ROUND(
        SUM(
            CASE
                WHEN "Company response to consumer" = 'Closed with monetary relief'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS monetary_relief_rate

FROM CFPB_Complaints_May_July_2026
GROUP BY Product
ORDER BY monetary_relief_rate DESC;

-- 10. TOP 5 PRODUCTS WITH HIGHEST TIMELY RESPONSE RATE

SELECT
    Product,
    COUNT(*) AS total_complaints,
    SUM(
        CASE
            WHEN "Timely response?" = 'Yes' THEN 1
            ELSE 0
        END
    ) AS timely_responses,
    ROUND(
        SUM(
            CASE
                WHEN "Timely response?" = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS timely_response_rate
FROM CFPB_Complaints_May_July_2026
GROUP BY Product
ORDER BY timely_response_rate DESC;
