
-- TransitPulse: Service Calendar and Special-Date Analysis


-- Query 1: Rank service IDs by total scheduled trip-date count
SELECT
    service_id,
    SUM(scheduled_trips) AS total_scheduled_trips,
    COUNT(DISTINCT service_date) AS active_dates,
    ROUND(AVG(scheduled_trips), 2) AS avg_trips_per_active_date
FROM read_csv_auto(
    'data/processed/scheduled_trips_by_service_id_and_date.csv'
)
GROUP BY service_id
ORDER BY total_scheduled_trips DESC
LIMIT 20;



-- Query 2: Find dates with unusually low or high network service
WITH daily_totals AS (
    SELECT
        CAST(service_date AS DATE) AS service_date,
        SUM(scheduled_trips) AS total_scheduled_trips
    FROM read_csv_auto(
        'data/processed/route_7day_rolling_average.csv'
    )
    GROUP BY CAST(service_date AS DATE)
),
network_stats AS (
    SELECT
        AVG(total_scheduled_trips) AS average_trips,
        STDDEV_POP(total_scheduled_trips) AS stddev_trips
    FROM daily_totals
)
SELECT
    d.service_date,
    d.total_scheduled_trips,
    ROUND(s.average_trips, 2) AS overall_average,
    ROUND(
        d.total_scheduled_trips - s.average_trips, 2
    ) AS difference_from_average
FROM daily_totals d
CROSS JOIN network_stats s
WHERE ABS(d.total_scheduled_trips - s.average_trips)
      > 2 * s.stddev_trips
ORDER BY difference_from_average;


-- Query 3: Summarize service levels by date
WITH daily_totals AS (
    SELECT
        CAST(service_date AS DATE) AS service_date,
        SUM(scheduled_trips) AS total_scheduled_trips
    FROM read_csv_auto(
        'data/processed/route_7day_rolling_average.csv'
    )
    GROUP BY CAST(service_date AS DATE)
)
SELECT
    MIN(service_date) AS first_service_date,
    MAX(service_date) AS last_service_date,
    COUNT(*) AS number_of_dates,
    ROUND(AVG(total_scheduled_trips), 2)
        AS average_daily_trips,
    MIN(total_scheduled_trips) AS minimum_daily_trips,
    MAX(total_scheduled_trips) AS maximum_daily_trips
FROM daily_totals;
