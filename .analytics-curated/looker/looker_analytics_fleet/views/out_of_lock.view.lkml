view: out_of_lock {
  sql_table_name: "PUBLIC"."V_OUT_OF_LOCK"
    ;;
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    hidden: yes
  }

  dimension: hours_out_of_lock {
    type: number
    sql: ${TABLE}."HOURS_OUT_OF_LOCK" ;;
    hidden: yes
  }

  dimension_group: out_of_lock_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."OUT_OF_LOCK_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
    hidden: yes
  }

  dimension: over_72_hours_flag {
    type: yesno
    sql: ${TABLE}."OVER_72_HOURS_FLAG" ;;
    hidden: yes
  }

  dimension: unplugged_flag {
    label: "Unplugged"
    type: yesno
    sql: ${TABLE}."UNPLUGGED_FLAG" ;;
  }

  dimension: out_of_lock_reason {
    type: string
    sql: ${TABLE}."OUT_OF_LOCK_REASON" ;;
  }

  # dimension: out_of_lock_reason {
  #   type: string
  #   sql: ${TABLE}."OUT_OF_LOCK_REASON" ;;
  # }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${out_of_lock_timestamp_date}) ;;
    hidden: yes
  }

  measure: summarize_out_of_locks {
    label: "Out of Lock Hours"
    hidden: yes
    type: sum
    sql: ${hours_out_of_lock} ;;
  }

  measure: total_out_of_locks_over_72_hours {
    type: count
    filters: [over_72_hours_flag: "Yes"]
    drill_fields: [detail*]
  }

  measure: total_out_of_locks {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [assets.custom_name, assets.asset_id, assets.make, assets.model, asset_types.asset_type, categories.name, trackers.tracker_information, out_of_lock_reason, asset_last_location.last_contact_time_formatted, asset_last_location.last_location_time_formatted, asset_last_location.address, unplugged_flag]
  }

}
