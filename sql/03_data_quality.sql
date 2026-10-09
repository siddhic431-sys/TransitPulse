-- TransitPulse: Data Quality Checks
-- Source: route_daily
-- Purpose: Validate schedule data before analysis.

-- Query 1: Check for missing values in important columns.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE service_date IS NULL) AS missing_service_dates,
    COUNT(*) FILTER (WHERE route_id IS NULL) AS missing_route_ids,
    COUNT(*) FILTER (WHERE scheduled_trips IS NULL) AS missing_trip_counts,
    COUNT(*) FILTER (WHERE route_name IS NULL) AS missing_route_names
FROM route_daily;


-- Query 2: Check for duplicate route-date records.
SELECT
    route_id,
    service_date,
    COUNT(*) AS duplicate_count
FROM route_daily
GROUP BY route_id, service_date
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- Query 3: Check for invalid negative scheduled-trip counts.
SELECT
    route_id,
    route_name,
    service_date,
    scheduled_trips
FROM route_daily
WHERE scheduled_trips < 0
ORDER BY service_date, route_id;


-- Query 4: Summarize scheduled-trip counts.
SELECT
    MIN(scheduled_trips) AS minimum_scheduled_trips,
    MAX(scheduled_trips) AS maximum_scheduled_trips,
    ROUND(AVG(scheduled_trips), 2) AS average_scheduled_trips,
    COUNT(*) AS route_date_rows
FROM route_daily;