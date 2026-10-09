# TransitPulse — Public Transport Schedule Analytics

TransitPulse is a data analytics portfolio project that explores Chicago Transit Authority (CTA) public transport schedules using GTFS data, Python, SQL, and data visualization.

The goal is to understand scheduled service patterns across bus and rail routes, identify peak service hours, compare weekday and weekend schedules, and analyze changes in scheduled service on special dates.

## Project Objectives

- Analyze CTA bus and rail routes.
- Explore scheduled trip volumes by route and date.
- Identify weekday and hourly service patterns.
- Calculate rolling averages to understand schedule trends.
- Compare scheduled service on special dates.
- Establish a foundation for future real-time delay analysis.

## Tech Stack

| Technology | Purpose |
|---|---|
| Python | Data processing and analysis |
| Pandas | Data manipulation |
| DuckDB and SQL | Analytical queries |
| Matplotlib | Visualizations |
| Jupyter Notebook | Exploratory analysis |
| GTFS | Transit schedule data |
| Git and GitHub | Version control |

## Repository Structure

```text
TransitPulse/
├── data/
│   └── processed/
├── notebooks/
│   └── 01_data_exploration.ipynb
├── reports/
│   └── figures/
├── src/
├── .gitignore
└── README.md
```

Raw GTFS source files are excluded from Git because of their large size. Download the CTA static GTFS feed and extract the files into `data/raw/GTFS/` to reproduce the analysis.

## Key Findings

The current analysis of the processed schedule data found:

- **133 routes** in the route catalog.
- **88 service dates** in the analyzed period, August 5 to October 31, 2026.
- **Tuesday** had the highest average daily scheduled trip count among weekdays, at approximately 21,050.
- **Sunday** had the lowest average, at approximately 13,540 scheduled trips.
- **4 PM** had the highest hourly count of scheduled stop-time records across bus and rail in the analyzed feed.

These results describe the processed GTFS schedule data, not actual vehicle movements or completed trips.

## Visualizations

### Scheduled Trips by Weekday

![Scheduled trips by weekday](reports/figures/scheduled_trips_by_weekday.png)

### Average Scheduled Trips by Weekday

![Average scheduled trips by weekday](reports/figures/average_scheduled_trips_by_weekday.png)

### Hourly Schedule: Bus vs Rail

![Hourly schedule bus versus rail](reports/figures/hourly_schedule_bus_vs_rail.png)

### Network Scheduled Trips Over Time

![Network scheduled trips over time](reports/figures/network_scheduled_trips_by_date.png)

## Data and Methodology

This project uses static GTFS data published by the Chicago Transit Authority.

The analysis includes route and trip exploration, service-calendar processing, daily route aggregations, hourly stop-time counts, rolling averages, and visual comparisons.

GTFS service times can exceed 24:00:00 to represent service continuing past midnight. For the hourly profile, times are folded into the 0–23 clock-hour range.

## Limitations

- Scheduled trips are not proof that a vehicle operated or arrived on time.
- Stop-time record counts are not passenger counts or verified departure counts.
- Zero scheduled trips for a route on a date do not automatically indicate a disruption.
- Real-time arrival and delay collection has not yet been verified as operational.

## Future Enhancements

- Integrate a verified CTA Train Tracker API feed.
- Compare scheduled and observed arrival times.
- Calculate delay distributions and on-time performance.
- Build an interactive dashboard.
- Develop route-level service reliability metrics.

## Data Sources

- [CTA Transit Data](https://transitdata.transitchicago.com/)
- [CTA Train Tracker Developer Resources](https://www.transitchicago.com/developers/traintracker/)

## Author

Developed as a public transportation data analytics portfolio project.