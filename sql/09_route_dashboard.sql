
-- TransitPulse: Route Performance Dashboard Dataset

WITH route_metrics AS (
    SELECT
        route_id,
        route_name,
        COUNT(*) AS number_of_dates,
        ROUND(AVG(scheduled_trips), 2) AS avg_daily_trips,
        MIN(scheduled_trips) AS min_daily_trips,
        MAX(scheduled_trips) AS max_daily_trips,
        ROUND(STDDEV_POP(scheduled_trips), 2)
            AS daily_trip_stddev
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
    min_daily_trips,
    max_daily_trips,
    daily_trip_stddev,
    ROUND(
        daily_trip_stddev / NULLIF(avg_daily_trips, 0),
        3
    ) AS coefficient_of_variation
FROM route_metrics
ORDER BY avg_daily_trips DESC;
