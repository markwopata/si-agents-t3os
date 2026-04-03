view: late_deliveries_test {
  sql_table_name: "BI_OPS"."LATE_DELIVERIES_TEST" ;;

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension_group: completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."COMPLETED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: delivery_id {
    type: number
    sql: ${TABLE}."DELIVERY_ID" ;;
  }
  dimension: hours_late {
    type: number
    sql: ${TABLE}."HOURS_LATE" ;;
  }
  dimension: late_delivery_status {
    type: string
    sql: ${TABLE}."LATE_DELIVERY_STATUS" ;;
  }
  dimension: delivery_time_status {
    type: string
    sql: case when ${late_delivery_status} is null then "On Time"
              else ${late_delivery_status}
              end;;
  }
  measure: late_delivery_perc {
    type: number
    sql: count(${delivery_id})/count(${delivery_timeliness.delivery_id}) ;;
    value_format_name: percent_2
  }
  measure: on_time_ignition_perc {
    type: number
    sql: count(case when ${late_delivery_status} = 'On Time - Ignition Check'
              then ${delivery_id}
              end)
         /
         count(${delivery_timeliness.delivery_id});;
  }

  measure: on_time_perc {
    type: number
    sql: count(case when ${delivery_id} is null then ${delivery_timeliness.delivery_id} else null end)
         /
         count(${delivery_timeliness.delivery_id});;
  }

  measure: late_perc {
    type: number
    sql: count(case when ${late_delivery_status} = 'Late'
    then ${delivery_id}
    end)
    /
    count(${delivery_timeliness.delivery_id});;
  }

  measure: late_delivery_ignition_perc {
    type: number
    sql:
        count(case when ${late_delivery_status} = 'Late' then ${delivery_id} else null end)
        /
        count(${delivery_timeliness.delivery_id})
        --count(case when ${late_delivery_status} = 'On Time - Ignition Check' then ${delivery_id}
          --          when ${delivery_id} is null then ${delivery_timeliness.delivery_id}
            --        else null
              --      end)
                    ;;
    value_format_name: percent_2
  }
  dimension_group: scheduled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."SCHEDULED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
}
