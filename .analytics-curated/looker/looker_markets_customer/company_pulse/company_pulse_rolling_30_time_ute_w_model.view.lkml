view: company_pulse_rolling_30_time_ute_w_model {
derived_table: {
  sql:
    with region_selection as (
          select
            distinct region_name as region
          from
            analytics.public.market_region_xwalk
          where
            {% condition region_name_filter %} region_name {% endcondition %}
            --region_name IN ('Midwest', 'Mountain West')
        )

    , region_selection_count as (
    select
    count(region) as total_regions_selected
    from
    region_selection
    )

    , assigned_region as (
    select
    IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'Corp', 'Midwest',
    IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'R2 Mountain West', 'Mountain West',
    IFF(
    split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2) = ''
    ,'Midwest'
    ,split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2)
    )
    )
    ) as region
    from
    analytics.payroll.company_directory
    where
    lower(work_email) = '{{ _user_attributes['email'] }}'
    )

    select
    m.*,
    xw.market_type,
    IFF( IFF(rsc.total_regions_selected = 1, rs.region ,ar.region) = xw.region_name,TRUE,FALSE) as is_selected_region,

    vmt.IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE
    FROM analytics.bi_ops.rolling_30_time_ute_model m
    join analytics.public.market_region_xwalk xw on m.market_id = xw.market_id
    left join (
    select market_id, is_current_months_open_greater_than_twelve
    from analytics.public.v_market_t3_analytics
    group by market_id, is_current_months_open_greater_than_twelve) vmt on vmt.market_id = m.market_id
    cross join region_selection_count rsc
    left join region_selection rs on rsc.total_regions_selected = 1
    cross join assigned_region ar


    ;;
}




dimension: timeframe {
  type: date
  sql:  ${TABLE}."TIMEFRAME" ;;
}

dimension: market_id {
  group_label: "Location Info"
  type: string
  sql: ${TABLE}."MARKET_ID" ;;
}

dimension: market_name {
  group_label: "Location Info"
  type: string
  sql: ${TABLE}."MARKET_NAME" ;;
}
dimension: market_type {
  type: string
  sql: ${TABLE}."MARKET_TYPE" ;;
}
dimension: district {
  group_label: "Location Info"
  type: string
  sql: ${TABLE}."DISTRICT" ;;
}
dimension: region {
  group_label: "Location Info"
  type: string
  sql: ${TABLE}."REGION" ;;
}
dimension: is_current_months_open_greater_than_twelve {
  type: yesno
  sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
}


dimension: rental_oec {
  type:  number
  sql: ${TABLE}."RENTAL_OEC" ;;
  value_format_name: usd_0

}

measure: rental_oec_sum {
  type:  sum
  sql: ${rental_oec} ;;
  value_format_name: usd_0
}


dimension: in_fleet_oec {
  type:  number
  sql: ${TABLE}."IN_FLEET_OEC" ;;
  value_format_name: usd_0
}

measure: in_fleet_oec_sum {
  type:  sum
  sql: ${in_fleet_oec} ;;
  value_format_name: usd_0
}

measure: time_ute {
  type: number
  sql:  DIV0NULL(${rental_oec_sum},${in_fleet_oec_sum});;
  value_format_name: percent_1
}

  measure: total_rental_oec_selected {
    group_label: "Rental OEC Selected"
    type: sum
    label: "Total Rental OEC"
    sql: ${rental_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [is_selected_region: "YES"]
  }

  measure: total_rental_oec_unselected {
    group_label: "Rental OEC Unselected"
    type: sum
    label: "Total Rental OEC"
    sql: ${rental_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [is_selected_region: "NO"]
  }

  measure: total_in_fleet_oec_selected {
    group_label: "Fleet OEC Selected"
    type: sum
    label: "Total Fleet OEC"
    sql: ${in_fleet_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [is_selected_region: "YES"]
  }

  measure: total_in_fleet_oec_unselected {
    group_label: "Fleet OEC Unselected"
    type: sum
    label: "Total Fleet OEC"
    sql: ${in_fleet_oec} ;;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    filters: [is_selected_region: "NO"]
  }

  measure: time_ute_percentage_selected {
    group_label: "Time Ute Selected"
    label: "Time Utilization %"
    type: number
    sql:case when ${total_rental_oec_selected} = 0 then 0
              when ${total_in_fleet_oec_selected} = 0 OR ${total_rental_oec_selected} IS NULL then 0
              else DIV0NULL(${total_rental_oec_selected},${total_in_fleet_oec_selected}) end;;
    value_format_name: percent_1
  }

  measure: time_ute_percentage_unselected {
    group_label: "Time Ute Unselected"
    label: "Time Utilization %"
    type: number
    sql:case when ${total_rental_oec_unselected} = 0 then 0
              when ${total_in_fleet_oec_unselected} = 0 OR ${total_rental_oec_unselected} IS NULL then 0
              else DIV0NULL(${total_rental_oec_unselected},${total_in_fleet_oec_unselected}) end;;
    value_format_name: percent_1
  }

  measure: percent_bar {
    type: number
    sql: 1 ;;
    value_format_name: percent_0
  }

  measure: time_ute_percent_bar {
    type: number
    sql: ${percent_bar} - ${time_ute};;
    value_format_name: percent_1
  }



dimension: is_selected_region {
  type: yesno
  sql: ${TABLE}."IS_SELECTED_REGION" ;;
}

dimension: selected_region_name {
  type: string
  sql: case when ${is_selected_region} = 'Yes' then 'Highlighted' else ' ' end ;;
}

filter: region_name_filter {
  type: string
}









}
