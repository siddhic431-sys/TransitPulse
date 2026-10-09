
-- TransitPulse: Weekday vs Weekend Analysis
-- Uses the calendar-complete route-date dataset.

-- Query 1: Compare average daily network service
-- between weekdays and weekends.
WITH route_dates AS (
    SELECT
        CAST(service_date AS DATE) AS service_date,
        route_id,
        route_name,
        scheduled_trips,
        CASE
            WHEN dayofweek(CAST(service_date AS DATE)) IN (0, 6)
                THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_category
    FROM read_csv_auto(
        'data/processed/route_7day_rolling_average.csv'
    )
),
daily_network AS (
    SELECT
        service_date,
        day_category,
        SUM(scheduled_trips) AS total_scheduled_trips
    FROM route_dates
    GROUP BY service_date, day_category
)
SELECT
    day_category,
    ROUND(AVG(total_scheduled_trips), 2)
        AS average_daily_scheduled_trips,
    MIN(total_scheduled_trips) AS minimum_daily_trips,
    MAX(total_scheduled_trips) AS maximum_daily_trips,
    COUNT(*) AS number_of_dates
FROM daily_network
GROUP BY day_category
ORDER BY average_daily_scheduled_trips DESC;


-- Query 2: Compare average scheduled trips by route
-- for weekdays versus weekends.
WITH route_dates AS (
    SELECT
        route_id,
        route_name,
        scheduled_trips,
        CASE
            WHEN dayofweek(CAST(service_date AS DATE)) IN (0, 6)
                THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_category
    FROM read_csv_auto(
        'data/processed/route_7day_rolling_average.csv'
    )
)
SELECT
    route_id,
    route_name,
    ROUND(AVG(
        CASE WHEN day_category = 'Weekday'
             THEN scheduled_trips END
    ), 2) AS avg_weekday_trips,
    ROUND(AVG(
        CASE WHEN day_category = 'Weekend'
             THEN scheduled_trips END
    ), 2) AS avg_weekend_trips,
    ROUND(
        AVG(CASE WHEN day_category = 'Weekend'
                 THEN scheduled_trips END)
        - AVG(CASE WHEN day_category = 'Weekday'
                   THEN scheduled_trips END),
        2
    ) AS weekend_minus_weekday
FROM route_dates
GROUP BY route_id, route_name
ORDER BY weekend_minus_weekday ASC
LIMIT 20;
