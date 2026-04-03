view: morey_vbus_records_wip {
derived_table: {
  sql:
        select
          equipment_make_id,
          equipment_model_id,
          equipment_model_name,
          equipment_make_name,
          tracker_type_name,
          firmware_version,
          total_morey_asset_count,
          j1939_count,
          j1939_reporting_proportion,
          j1939_missing_proportion,
          can_count,
          can_reporting_proportion,
          can_missing_proportion
      -- This commens is to see if this shows up without a commit
      from data_science.public.amber_morey_vbus_records_wip
      where j1939_count > 0
      ;;
}
dimension: equipment_make_id {}
dimension: equipment_model_id {}
dimension: equipment_model_name {}
dimension: equipment_make_name {}
dimension: tracker_type_name {}
dimension: firmware_version {}
dimension: total_morey_asset_count {}
dimension: j1939_count {}
dimension: j1939_reporting_proportion {}
dimension: j1939_missing_proportion {}
dimension: can_count {}
dimension: can_reporting_proportion {}
dimension: can_missing_proportion {}

# dimension: asset_id {}
# dimension: make {}
# dimension: model {}
# dimension: company_name {}
# dimension: market_name {}
# dimension: tracker_type {}
# dimension: firmware_version {}
# dimension: short_time_flags {description:"Counts of intertrip latency less than 10 seconds"}
# dimension: small_distance_flags {description:"Counts of trip distance less than 1 meter"}
# dimension: time_and_distance {description:"Combination of short intertrip latency and small trip distance"}
}
