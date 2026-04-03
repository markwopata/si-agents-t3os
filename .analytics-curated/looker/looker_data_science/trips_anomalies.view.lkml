view: trip_anomalies {
  derived_table: {
    sql:
      select
          esdb_tracker_id,
          market_name,
          company_name,
          asset_id,
          make,
          model,
          firmware_version,
          tracker_type,
          accumulated_time_count as short_time_flags,
          accumulated_distance_count as small_distance_flags,
          accumulated_combination_count as time_and_distance,
          intertrip_time_diff_med,
          intratrip_dist_diff_med
      -- This commens is to see if this shows up without a commit
      from data_science.public.accumulated_trips_anomalies
      where accumulation_date is null
      ;;
  }
  dimension: asset_id {}
  dimension: make {}
  dimension: model {}
  dimension: company_name {}
  dimension: market_name {}
  dimension: tracker_type {}
  dimension: firmware_version {}
  dimension: short_time_flags {description:"Counts of intertrip latency less than 10 seconds"}
  dimension: small_distance_flags {description:"Counts of trip distance less than 1 meter"}
  dimension: time_and_distance {description:"Combination of short intertrip latency and small trip distance"}
}
