
-- TransitPulse: Route Service Consistency and Variability

-- Query 1: Identify routes with the most variable daily service.
-- Uses the calendar-complete dataset, including zero-service dates.

WITH route_stats AS (
    SELECT
        route_id,
        route_name,
        COUNT(*) AS number_of_dates,
        ROUND(AVG(scheduled_trips), 2) AS avg_daily_trips,
        ROUND(STDDEV_POP(scheduled_trips), 2) AS stddev_daily_trips,
        MIN(scheduled_trips) AS min_daily_trips,
        MAX(scheduled_trips) AS max_daily_trips
    FROM read_csv_auto(
        'data/processed/route_7day_rolling_average.csv'
    )
    GROUP BY route_id, route_name
)
SELECT
    route_id,
    route_name,
    number_of_dates,
    avg_daily_trips,
    stddev_daily_trips,
    min_daily_trips,
    max_daily_trips,
    ROUND(
        stddev_daily_trips / NULLIF(avg_daily_trips, 0),
        3
    ) AS coefficient_of_variation
FROM route_stats
ORDER BY coefficient_of_variation DESC NULLS LAST
LIMIT 20;


-- Query 2: Identify routes with the most consistent daily service.
WITH route_stats AS (
    SELECT
        route_id,
        route_name,
        COUNT(*) AS number_of_dates,
        ROUND(AVG(scheduled_trips), 2) AS avg_daily_trips,
        ROUND(STDDEV_POP(scheduled_trips), 2) AS stddev_daily_trips
    FROM read_csv_auto(
        'data/processed/route_7day_rolling_average.csv'
    )
    GROUP BY route_id, route_name
)
SELECT
    route_id,
    route_name,
    number_of_dates,
    avg_daily_trips,
    stddev_daily_trips
FROM route_stats
WHERE avg_daily_trips > 0
ORDER BY stddev_daily_trips ASC
LIMIT 20;
