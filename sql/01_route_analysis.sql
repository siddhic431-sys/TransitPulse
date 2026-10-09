-- TransitPulse: CTA Schedule Analysis
-- Database table: route_daily
-- Note: scheduled trips, not actual completed trips or delays.

-- 1. Top 10 routes by total scheduled trips
SELECT
    route_name,
    route_long_name,
    SUM(scheduled_trips) AS total_scheduled_trips,
    ROUND(AVG(scheduled_trips), 2) AS avg_daily_scheduled_trips
FROM route_daily
GROUP BY route_name, route_long_name
ORDER BY total_scheduled_trips DESC
LIMIT 10;


-- 2. Average scheduled trips by weekday
SELECT
    day_of_week,
    ROUND(AVG(daily_total), 0) AS avg_network_scheduled_trips
FROM (
    SELECT
        service_date,
        day_of_week,
        SUM(scheduled_trips) AS daily_total
    FROM route_daily
    GROUP BY service_date, day_of_week
) AS daily_network
GROUP BY day_of_week
ORDER BY CASE day_of_week
    WHEN 'Monday' THEN 1
    WHEN 'Tuesday' THEN 2
    WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4
    WHEN 'Friday' THEN 5
    WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
    ELSE 8
END;


-- 3. Daily scheduled trips by route type
-- GTFS route_type 3 = bus; route_type 1 = rail
SELECT
    service_date,
    CASE
        WHEN route_type = 3 THEN 'Bus'
        WHEN route_type = 1 THEN 'Rail'
        ELSE 'Other'
    END AS transport_mode,
    SUM(scheduled_trips) AS scheduled_trips
FROM route_daily
GROUP BY service_date, transport_mode
ORDER BY service_date, transport_mode;


-- 4. Routes with the highest average daily scheduled trips
SELECT
    route_name,
    route_long_name,
    COUNT(DISTINCT service_date) AS active_service_dates,
    SUM(scheduled_trips) AS total_scheduled_trips,
    ROUND(AVG(scheduled_trips), 2) AS avg_trips_per_active_date
FROM route_daily
GROUP BY route_name, route_long_name
ORDER BY avg_trips_per_active_date DESC
LIMIT 10;