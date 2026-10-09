
-- TransitPulse: Route Schedule Trends Over Time

-- Query 1: Compare each route's first and last available dates.
WITH route_dates AS (
    SELECT
        route_id,
        route_name,
        CAST(service_date AS DATE) AS service_date,
        scheduled_trips
    FROM read_csv_auto(
        'data/processed/route_7day_rolling_average.csv'
    )
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY route_id
            ORDER BY service_date ASC
        ) AS first_rank,
        ROW_NUMBER() OVER (
            PARTITION BY route_id
            ORDER BY service_date DESC
        ) AS last_rank
    FROM route_dates
),
route_change AS (
    SELECT
        route_id,
        route_name,
        MAX(CASE WHEN first_rank = 1
                 THEN service_date END) AS first_date,
        MAX(CASE WHEN last_rank = 1
                 THEN service_date END) AS last_date,
        MAX(CASE WHEN first_rank = 1
                 THEN scheduled_trips END) AS first_day_trips,
        MAX(CASE WHEN last_rank = 1
                 THEN scheduled_trips END) AS last_day_trips
    FROM ranked
    GROUP BY route_id, route_name
)
SELECT
    route_id,
    route_name,
    first_date,
    last_date,
    first_day_trips,
    last_day_trips,
    last_day_trips - first_day_trips AS trip_change,
    ROUND(
        100.0 * (last_day_trips - first_day_trips)
        / NULLIF(first_day_trips, 0),
        2
    ) AS percentage_change
FROM route_change
ORDER BY trip_change DESC
LIMIT 20;


-- Query 2: Compare the first and last 7-day average
-- for each route, reducing the effect of a single unusual date.
WITH route_dates AS (
    SELECT
        route_id,
        route_name,
        CAST(service_date AS DATE) AS service_date,
        scheduled_trips
    FROM read_csv_auto(
        'data/processed/route_7day_rolling_average.csv'
    )
),
route_periods AS (
    SELECT
        route_id,
        route_name,
        service_date,
        scheduled_trips,
        CASE
            WHEN service_date < (
                SELECT MIN(CAST(service_date AS DATE))
                FROM read_csv_auto(
                    'data/processed/route_7day_rolling_average.csv'
                )
            ) + INTERVAL 7 DAY
            THEN 'First 7 Days'
            WHEN service_date >= (
                SELECT MAX(CAST(service_date AS DATE))
                FROM read_csv_auto(
                    'data/processed/route_7day_rolling_average.csv'
                )
            ) - INTERVAL 6 DAY
            THEN 'Last 7 Days'
        END AS period
    FROM route_dates
)
SELECT
    route_id,
    route_name,
    ROUND(AVG(
        CASE WHEN period = 'First 7 Days'
             THEN scheduled_trips END
    ), 2) AS first_7day_avg,
    ROUND(AVG(
        CASE WHEN period = 'Last 7 Days'
             THEN scheduled_trips END
    ), 2) AS last_7day_avg,
    ROUND(
        AVG(CASE WHEN period = 'Last 7 Days'
                 THEN scheduled_trips END)
        - AVG(CASE WHEN period = 'First 7 Days'
                   THEN scheduled_trips END),
        2
    ) AS average_trip_change
FROM route_periods
WHERE period IS NOT NULL
GROUP BY route_id, route_name
ORDER BY average_trip_change DESC
LIMIT 20;
