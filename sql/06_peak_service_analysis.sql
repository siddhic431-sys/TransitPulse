
-- TransitPulse: Peak Service Analysis

-- Query 1: Busiest scheduled service hours across modes
SELECT
    hour,
    mode,
    scheduled_stop_departures
FROM read_csv_auto(
    'data/processed/hourly_departures_by_mode.csv'
)
ORDER BY scheduled_stop_departures DESC
LIMIT 20;


-- Query 2: Peak scheduled service hour for each mode
WITH hourly AS (
    SELECT
        hour,
        mode,
        scheduled_stop_departures
    FROM read_csv_auto(
        'data/processed/hourly_departures_by_mode.csv'
    )
),
ranked_hours AS (
    SELECT
        hour,
        mode,
        scheduled_stop_departures,
        RANK() OVER (
            PARTITION BY mode
            ORDER BY scheduled_stop_departures DESC
        ) AS peak_rank
    FROM hourly
)
SELECT
    mode,
    hour AS peak_hour,
    scheduled_stop_departures
FROM ranked_hours
WHERE peak_rank = 1
ORDER BY mode;


-- Query 3: Compare peak-hour service with average hourly service
WITH hourly AS (
    SELECT
        hour,
        mode,
        scheduled_stop_departures
    FROM read_csv_auto(
        'data/processed/hourly_departures_by_mode.csv'
    )
)
SELECT
    mode,
    ROUND(AVG(scheduled_stop_departures), 2)
        AS average_hourly_service,
    MAX(scheduled_stop_departures)
        AS peak_hour_service,
    ROUND(
        MAX(scheduled_stop_departures) /
        NULLIF(AVG(scheduled_stop_departures), 0),
        2
    ) AS peak_to_average_ratio
FROM hourly
GROUP BY mode
ORDER BY peak_hour_service DESC;
