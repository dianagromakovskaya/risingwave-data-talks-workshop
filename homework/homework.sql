-- Create a materialized view to compute the average, min and max trip time between each taxi zone.
--
-- Note that we consider the do not consider a->b and b->a as the same trip pair. So as an example, you would consider the following trip pairs as different pairs:
--
-- Yorkville East -> Steinway
-- Steinway -> Yorkville East

CREATE MATERIALIZED VIEW min_max_avg_trip_time AS
SELECT taxi_zone.Zone as pickup_zone, taxi_zone_1.Zone as dropoff_zone,
MIN(tpep_dropoff_datetime - tpep_pickup_datetime) min_trip_time,
MAX(tpep_dropoff_datetime - tpep_pickup_datetime) max_trip_time,
AVG(tpep_dropoff_datetime - tpep_pickup_datetime) avg_trip_time
 FROM trip_data
 JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
 JOIN taxi_zone as taxi_zone_1 ON trip_data.DOLocationID = taxi_zone_1.location_id
 GROUP BY 1, 2;

--  From this MV, find the pair of taxi zones with the highest average trip time. You may need to use the dynamic filter pattern for this.

WITH t AS (
    SELECT MAX(avg_trip_time) AS max_avg_trip_time
    FROM min_max_avg_trip_time
)
SELECT pickup_zone, dropoff_zone
FROM t,
        min_max_avg_trip_time mtt
WHERE mtt.avg_trip_time = max_avg_trip_time;