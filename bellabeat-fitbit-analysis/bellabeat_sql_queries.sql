/* ============================================================
   BELLABEAT FITBIT ANALYSIS — SQL QUERIES
   Google BigQuery | Dataset: fitbit_data
   ============================================================
   This file documents the full SQL workflow used to clean,
   combine, and analyze the Fitbit Fitness Tracker dataset.
   Organized by phase: PROCESS (cleaning) and ANALYZE (findings).
   ============================================================ */


/* ============================================================
   PHASE 1: PROCESS — DATA CLEANING
   ============================================================ */

-- 1.1 Check for exact duplicate rows in the sleep table
SELECT Id, SleepDay, TotalSleepRecords, COUNT(*) AS cnt
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.sleep_day_2`
GROUP BY Id, SleepDay, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed
HAVING cnt > 1;
-- Result: 3 duplicate rows found

-- 1.2 Verify cleaned sleep table (sleep_day_2_clean) has 0 duplicates
SELECT Id, SleepDay, TotalSleepRecords, COUNT(*) AS cnt
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.sleep_day_2_clean`
GROUP BY Id, SleepDay, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed
HAVING cnt > 1;
-- Result: 0 rows returned — confirmed clean

-- 1.3 Check for duplicate Id + Date combos in daily activity tables
SELECT Id, ActivityDate, COUNT(*) AS cnt
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_1`
GROUP BY Id, ActivityDate
HAVING cnt > 1;
-- Repeat for daily_activity_2 — both returned 0 duplicates

-- 1.4 Check for duplicate Id + Time + Value in heart rate tables
SELECT Id, Time, Value, COUNT(*) AS cnt
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.heartrate_seconds_1`
GROUP BY Id, Time, Value
HAVING cnt > 1;
-- Repeat for heartrate_seconds_2 — both returned 0 duplicates

-- 1.5 Fix naming inconsistency: table and column typo
ALTER TABLE `project-cb138bef-764c-4b96-a64.fitbit_data.houly_steps_2`
RENAME TO hourly_steps_2;

ALTER TABLE `project-cb138bef-764c-4b96-a64.fitbit_data.hourly_steps_2`
RENAME COLUMN AcitvityHour TO ActivityHour;

-- 1.6 Check for duplicate Id + ActivityHour + StepTotal in hourly steps tables
SELECT Id, ActivityHour, StepTotal, COUNT(*) AS cnt
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.hourly_steps_1`
GROUP BY Id, ActivityHour, StepTotal
HAVING cnt > 1;
-- Repeat for hourly_steps_2 — both returned 0 duplicates

-- 1.7 Combined nulls / outliers / user count / date range check — daily activity
WITH combined AS (
  SELECT *, '1' AS source FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_1`
  UNION ALL
  SELECT *, '2' AS source FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_2`
)
SELECT
  source,
  COUNT(*) AS total_rows,
  COUNT(DISTINCT Id) AS unique_users,
  COUNTIF(TotalSteps IS NULL OR Calories IS NULL) AS null_count,
  COUNTIF(TotalSteps = 0 AND Calories > 0) AS outlier_count,
  MIN(ActivityDate) AS earliest_date,
  MAX(ActivityDate) AS latest_date
FROM combined
GROUP BY source;
-- Result: 0 nulls; 56/73 zero-step days with valid calorie burn (kept, reflects BMR); date ranges overlap on 2016-04-12

-- 1.8 Combined nulls / outliers / user count — heart rate
WITH combined AS (
  SELECT *, '1' AS source FROM `project-cb138bef-764c-4b96-a64.fitbit_data.heartrate_seconds_1`
  UNION ALL
  SELECT *, '2' AS source FROM `project-cb138bef-764c-4b96-a64.fitbit_data.heartrate_seconds_2`
)
SELECT
  source,
  COUNT(*) AS total_rows,
  COUNT(DISTINCT Id) AS unique_users,
  COUNTIF(Value IS NULL) AS null_count,
  COUNTIF(Value < 30 OR Value > 220) AS outlier_count
FROM combined
GROUP BY source;
-- Result: 0 nulls, 0 physiologically-impossible values; only 14-15 of 35 users had heart-rate-capable devices

-- 1.9 Verify duplicate date overlap in daily activity (2016-04-12)
SELECT Id, ActivityDate, COUNT(*)
FROM (
  SELECT Id, ActivityDate FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_1`
  UNION ALL
  SELECT Id, ActivityDate FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_2`
)
WHERE ActivityDate = '2016-04-12'
GROUP BY Id, ActivityDate
HAVING COUNT(*) > 1;
-- Result: every user with data that day appears exactly twice — confirmed systematic overlap

-- 1.10 Combine daily activity tables, excluding the duplicate overlap day
CREATE OR REPLACE TABLE `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_combined` AS
SELECT * FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_1`
UNION ALL
SELECT * FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_2`
WHERE ActivityDate != '2016-04-12';

-- Verify combine
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT Id) AS unique_users
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_combined`;
-- Result: 1,364 rows, 35 unique users

-- 1.11 Verify date overlap exists in heart rate data too (systematic check)
WITH days_1 AS (
  SELECT DISTINCT DATE(PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', Time)) AS day
  FROM `project-cb138bef-764c-4b96-a64.fitbit_data.heartrate_seconds_1`
),
days_2 AS (
  SELECT DISTINCT DATE(PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', Time)) AS day
  FROM `project-cb138bef-764c-4b96-a64.fitbit_data.heartrate_seconds_2`
)
SELECT days_1.day AS overlapping_day
FROM days_1
JOIN days_2 ON days_1.day = days_2.day;
-- Result: 2016-04-12 confirmed overlapping here too

-- 1.12 Combine heart rate tables, excluding the overlap day
CREATE OR REPLACE TABLE `project-cb138bef-764c-4b96-a64.fitbit_data.heartrate_combined` AS
SELECT * FROM `project-cb138bef-764c-4b96-a64.fitbit_data.heartrate_seconds_1`
UNION ALL
SELECT * FROM `project-cb138bef-764c-4b96-a64.fitbit_data.heartrate_seconds_2`
WHERE DATE(PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', Time)) != '2016-04-12';

-- Verify
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT Id) AS unique_users
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.heartrate_combined`;
-- Result: 3,539,190 rows, 15 unique users

-- 1.13 Verify + combine hourly steps tables (same overlap pattern)
WITH days_1 AS (
  SELECT DISTINCT DATE(PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', ActivityHour)) AS day
  FROM `project-cb138bef-764c-4b96-a64.fitbit_data.hourly_steps_1`
),
days_2 AS (
  SELECT DISTINCT DATE(PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', ActivityHour)) AS day
  FROM `project-cb138bef-764c-4b96-a64.fitbit_data.hourly_steps_2`
)
SELECT days_1.day AS overlapping_day
FROM days_1
JOIN days_2 ON days_1.day = days_2.day;
-- Result: 2016-04-12 confirmed overlapping again — systematic across all metrics

CREATE OR REPLACE TABLE `project-cb138bef-764c-4b96-a64.fitbit_data.hourly_steps_combined` AS
SELECT * FROM `project-cb138bef-764c-4b96-a64.fitbit_data.hourly_steps_1`
UNION ALL
SELECT * FROM `project-cb138bef-764c-4b96-a64.fitbit_data.hourly_steps_2`
WHERE DATE(PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', ActivityHour)) != '2016-04-12';

-- Verify
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT Id) AS unique_users
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.hourly_steps_combined`;
-- Result: 45,391 rows, 35 unique users


/* ============================================================
   PHASE 2: ANALYZE — SUMMARY STATISTICS & TRENDS
   ============================================================ */

-- 2.1 Overall activity averages
SELECT
  ROUND(AVG(TotalSteps)) AS avg_steps,
  ROUND(AVG(SedentaryMinutes)) AS avg_sedentary_min,
  ROUND(AVG(VeryActiveMinutes)) AS avg_very_active_min,
  ROUND(AVG(LightlyActiveMinutes)) AS avg_lightly_active_min,
  ROUND(AVG(Calories)) AS avg_calories
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_combined`;
-- Result: 7,258 avg steps | 992 min sedentary | 20 min very active | 185 min lightly active | 2,263 avg calories

-- 2.2 Sleep vs. activity relationship (joined on Id + date)
SELECT
  ROUND(AVG(s.TotalMinutesAsleep)) AS avg_minutes_asleep,
  ROUND(AVG(s.TotalTimeInBed)) AS avg_time_in_bed,
  ROUND(AVG(s.TotalTimeInBed - s.TotalMinutesAsleep)) AS avg_minutes_awake_in_bed,
  ROUND(AVG(a.SedentaryMinutes)) AS avg_sedentary_min_on_sleep_days
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.sleep_day_2_clean` s
JOIN `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_combined` a
  ON s.Id = a.Id
  AND DATE(PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', s.SleepDay)) = a.ActivityDate;
-- Result: 419 min asleep | 459 min in bed | 39 min awake in bed | 699 min sedentary on sleep-logging days (lower than overall avg)

-- 2.3 Average steps by hour of day
SELECT
  EXTRACT(HOUR FROM PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', ActivityHour)) AS hour_of_day,
  ROUND(AVG(StepTotal)) AS avg_steps
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.hourly_steps_combined`
GROUP BY hour_of_day
ORDER BY hour_of_day;
-- Result: peaks at hour 12 (534 steps) and hour 18-19 (~550-554 steps)

-- 2.4 Average steps and sedentary minutes by day of week
SELECT
  FORMAT_DATE('%A', ActivityDate) AS day_of_week,
  ROUND(AVG(TotalSteps)) AS avg_steps,
  ROUND(AVG(SedentaryMinutes)) AS avg_sedentary_min
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_combined`
GROUP BY day_of_week
ORDER BY
  CASE day_of_week
    WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
  END;
-- Result: Saturday highest (~7.7k steps), Sunday lowest (~6.6k steps)

-- 2.5 Correlation: steps vs. sleep, and sedentary minutes vs. sleep
SELECT
  ROUND(CORR(a.TotalSteps, s.TotalMinutesAsleep), 3) AS steps_sleep_correlation,
  ROUND(CORR(a.SedentaryMinutes, s.TotalMinutesAsleep), 3) AS sedentary_sleep_correlation
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_combined` a
JOIN `project-cb138bef-764c-4b96-a64.fitbit_data.sleep_day_2_clean` s
  ON a.Id = s.Id
  AND a.ActivityDate = DATE(PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', s.SleepDay));
-- Result: steps_sleep_correlation = -0.183 (weak) | sedentary_sleep_correlation = -0.54 (moderate, significant)

-- 2.6 Export query used for Tableau scatter plot (row-level, not averaged)
SELECT
  a.Id,
  a.ActivityDate,
  a.SedentaryMinutes,
  s.TotalMinutesAsleep
FROM `project-cb138bef-764c-4b96-a64.fitbit_data.daily_activity_combined` a
JOIN `project-cb138bef-764c-4b96-a64.fitbit_data.sleep_day_2_clean` s
  ON a.Id = s.Id
  AND a.ActivityDate = DATE(PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', s.SleepDay));
-- Exported as CSV and used as the data source for the Tableau "Sedentary vs Sleep" scatter plot
-- (Trend line R model in Tableau confirmed: p = 0.0282, consistent with the correlation above)
