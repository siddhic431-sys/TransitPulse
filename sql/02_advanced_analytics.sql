-- TransitPulse: Advanced SQL Analytics
-- Window functions using DuckDB and route_daily.
-- These queries analyze scheduled trips, not actual delays.

-- Query 1: Rank routes by total scheduled trips.
-- RANK() assigns equal ranks to ties and leaves gaps after ties.
WITH route_totals AS (
    SELECT
        route_name,
        route_long_name,
        SUM(scheduled_trips) AS total_scheduled_trips
    FROM route_daily
    GROUP BY route_name, route_long_name
)
SELECT
    route_name,
    route_long_name,
    total_scheduled_trips,
    RANK() OVER (
        ORDER BY total_scheduled_trips DESC
    ) AS route_rank
FROM route_totals
ORDER BY route_rank, route_name
LIMIT 15;


-- Query 2: Compare RANK() and ROW_NUMBER().
-- ROW_NUMBER() gives each row a unique position.
WITH route_totals AS (
    SELECT
        route_name,
        SUM(scheduled_trips) AS total_scheduled_trips
    FROM route_daily
    GROUP BY route_name
)
SELECT
    route_name,
    total_scheduled_trips,
    RANK() OVER (
        ORDER BY total_scheduled_trips DESC
    ) AS route_rank,
    ROW_NUMBER() OVER (
        ORDER BY total_scheduled_trips DESC, route_name
    ) AS row_number
FROM route_totals
ORDER BY row_number
LIMIT 15;

-- Query 3: Average scheduled trips by route and weekday.
SELECT
    route_name,
    day_of_week,
    ROUND(AVG(scheduled_trips), 2) AS avg_trips_per_active_date
FROM route_daily
GROUP BY route_name, day_of_week
ORDER BY route_name,
    CASE day_of_week
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
        ELSE 8
    END;


-- Query 4: Seven-row rolling average of scheduled trips by route.
-- Important: This uses the previous 6 observed rows plus the current row.
-- It is not necessarily 7 consecutive calendar days if dates are missing.
WITH daily_route_trips AS (
    SELECT
        route_id,
        route_name,
        service_date,
        SUM(scheduled_trips) AS scheduled_trips
    FROM route_daily
    GROUP BY route_id, route_name, service_date
)
SELECT
    route_name,
    service_date,
    scheduled_trips,
    ROUND(
        AVG(scheduled_trips) OVER (
            PARTITION BY route_id
            ORDER BY service_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_7_row_avg
FROM daily_route_trips
ORDER BY route_name, service_date
LIMIT 30;

-- Query 4: Seven-calendar-day rolling average by route.
-- Uses the processed dataset, which fills missing route-date combinations
-- with zero scheduled trips.
SELECT
    route_id,
    route_name,
    service_date,
    scheduled_trips,
    rolling_7_calendar_day_average
FROM read_csv(
    'data/processed/route_7day_rolling_average.csv',
    header = true,
    auto_detect = true
)
ORDER BY route_name, service_date
LIMIT 30;