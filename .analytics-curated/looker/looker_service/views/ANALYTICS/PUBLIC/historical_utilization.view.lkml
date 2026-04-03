view: historical_utilization {
  sql_table_name: "ANALYTICS"."PUBLIC"."HISTORICAL_UTILIZATION"
    ;;
  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
  }
  dimension: aged_out_of_fleet {
    type: yesno
    sql: ${TABLE}."AGED_OUT_OF_FLEET" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  measure: asset_count {
    type: count_distinct
    sql: ${TABLE}."ASSET_ID" ;;
    drill_fields: [ute_detail*]
  }
  measure: asset_count_drill {
    type: count_distinct
    sql: ${TABLE}."ASSET_ID" ;;
    drill_fields: [ute_detail_market*]
  }
  dimension: pkey {
    primary_key: yes
    type: string
    sql: CONCAT(${asset_id}, ${dte_date}) ;;
  }
  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: date_updated {
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
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: day_rate {
    type: number
    value_format_name: usd
    sql: ${TABLE}."DAY_RATE" ;;
  }
  dimension_group: dte {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DTE" ;;
  }
  dimension_group: first_rental {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FIRST_RENTAL" ;;
  }
  dimension: in_rental_fleet {
    type: yesno
    sql: ${TABLE}."IN_RENTAL_FLEET" ;;
  }
  dimension_group: last_rental {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_RENTAL" ;;
  }
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: on_rent {
    type: yesno
    sql: ${TABLE}."ON_RENT" ;;
  }
  dimension: purchase_price {
    type: number
    sql: ${TABLE}."PURCHASE_PRICE" ;;
  }
  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: rerent_indicator {
    type: yesno
    sql: ${TABLE}."RERENT_INDICATOR" ;;
  }
  dimension: asset_removed {
    type: yesno
    sql: ${company_id} in (32367, 31712, 32365, 155) ;;
  }

# - - - - - MEASURES - - - - -

  measure: current_total_assets {
    type: count_distinct
    sql: IFF(${dte_date} = DATEADD('day', -1, CURRENT_DATE()), ${asset_id}, null) ;;
    drill_fields: [asset_id, assets_aggregate.class, unit_utilization_30, unit_utilization_60, unit_utilization_90, unit_utilization_180, unit_utilization_365]
  }
  measure: count_assets_filtered {
    label: "Asset Count"
    type: count_distinct
    sql: ${TABLE}."ASSET_ID" ;;
    drill_fields: [asset_id,
                  assets_aggregate.make,
                  assets_aggregate.model,
                  assets_aggregate.class,
                  market_region_xwalk.market_name,
                  dte_date,
                  day_rate,
                  on_rent,
                  rental_id]
  }
  measure: num_days {
    type: count
    #filters: [on_rent: "true"]
#    sql: ${dte_date};;
    drill_fields: [asset_id,
                  assets_aggregate.make,
                  assets_aggregate.model,
                  assets_aggregate.class,
                  market_region_xwalk.market_name,
                  dte_date,
                  day_rate,
                  on_rent,
                  rental_id]
  }
  measure: total_rate {
    type: sum
    value_format_name: usd
    sql: ${day_rate};;
  }
  measure: achieved_daily_rental_rate {
    description: "The achieved daily rental rate over the last 30 days based on the assets daily utilization"
    type: number
    value_format_name: usd
    sql: ${total_rate} / ${num_days} ;;
    drill_fields: [asset_id,
                  assets_aggregate.make,
                  assets_aggregate.model,
                  assets_aggregate.class,
                  market_region_xwalk.market_name,
                  dte_date,
                  day_rate,
                  on_rent,
                  rental_id]
  }

# -- look into the derived sub-table and use that to aggregate asset_class.  Can do this join inside the new derived view I'm going to make.
# left join to the work orders with parts needed tag on the asset_class and asset_market to the branch_id of work order to the market_id from hist_util

# Tried using a derived table here but as soon as I added this, historical_utilization was inaccessible in the service_parts.model and service_work_orders.model
# Additionally, this view was inaccessible.  Created custom SQL view 'class_30_day_util' for now until I can research this more.
#  view: asset_class_30_day_utilization{
#   sql_table_name: {
#      sql:
#      select aa.ASSET_CLASS,
#              count(hu.dte) as num_days,
#              sum(zeroifnull(hu.day_rate)) as total_rate,
#              total_rate / num_days as achieved_daily_rental_rate
#      from ${historical_utilization.SQL_TABLE_NAME} as hu
#      where dte >= dateadd(day,-30,current_date)
#      group by aa.asset_class
#      order by achieved_daily_rental_rate desc;;
#    }


# - - - - CUSTOM UTILIZATION METRICS - - - - -
# This was built off the historical_utilization table with *custom* logic
# based on Andrew Lowe's requests. Do not use this for other financial reporting
# because this logic ignores certain features of the table, such as the in_rental_fleet flag

  # 30 day range
  measure: asset_total_30 {
    group_label: "30 day Util"
    type: count_distinct
    drill_fields: [period_30_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -30, CURRENT_DATE()), ${asset_id}, NULL) ;;
  }
  measure: oec_total_30 {
    group_label: "30 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_30_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -30, CURRENT_DATE()), ${purchase_price}, NULL) ;;
  }
  measure: days_on_rent_30 {
    group_label: "30 day Util"
    type: sum
    drill_fields: [period_30_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -30, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_in_fleet_30 {
    group_label: "30 day Util"
    type: sum
    drill_fields: [period_30_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -30, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_available_30 {
    group_label: "30 day Util"
    type: sum
    sql: IFF(${on_rent} or (scd_asset_inventory_status.asset_inventory_status='Ready to Rent' and ${dte_date} >= DATEADD('day', -30, CURRENT_DATE())), 1, 0) ;;
  }
  measure: oec_on_rent_30 {
    group_label: "30 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_30_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -30, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: oec_in_fleet_30 {
    group_label: "30 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_30_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -30, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: unit_available_utilization_30 {
    group_label: "30 day Util"
    type: number
    value_format_name: percent_1
    sql: ${days_on_rent_30}/NULLIFZERO(${days_available_30}) ;;
  }
  measure: unit_utilization_30 {
    group_label: "30 day Util"
    type: number
    drill_fields: [period_30_detail*]
    value_format_name: percent_1
    sql: ${days_on_rent_30} / NULLIFZERO(${days_in_fleet_30}) ;;
  }
  measure: unit_utilization_diff_30 {
    group_label: "30 day Util"
    type: number
    value_format_name: percent_1
    sql: ${unit_available_utilization_30}-${unit_utilization_30} ;;
  }
  measure: oec_utilization_30 {
    group_label: "30 day Util"
    type: number
    drill_fields: [period_30_detail*]
    value_format_name: percent_1
    sql: ${oec_on_rent_30} / NULLIFZERO(${oec_in_fleet_30}) ;;
  }

  # 60 day range
  measure: asset_total_60 {
    group_label: "60 day Util"
    type: count_distinct
    drill_fields: [period_60_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -60, CURRENT_DATE()), ${asset_id}, NULL) ;;
  }
  measure: oec_total_60 {
    group_label: "60 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_60_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -60, CURRENT_DATE()), ${purchase_price}, NULL) ;;
  }
  measure: days_on_rent_60 {
    group_label: "60 day Util"
    type: sum
    drill_fields: [period_60_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -60, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_in_fleet_60 {
    group_label: "60 day Util"
    type: sum
    drill_fields: [period_60_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -60, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_available_60 {
    group_label: "60 day Util"
    type: sum
    sql: IFF(${on_rent} or (scd_asset_inventory_status.asset_inventory_status='Ready to Rent' and ${dte_date} >= DATEADD('day', -60, CURRENT_DATE())), 1, 0) ;;
  }
  measure: oec_on_rent_60 {
    group_label: "60 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_60_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -60, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: oec_in_fleet_60 {
    group_label: "60 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_60_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -60, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: unit_available_utilization_60 {
    group_label: "60 day Util"
    type: number
    value_format_name: percent_1
    sql: ${days_on_rent_60}/NULLIFZERO(${days_available_60}) ;;
  }
  measure: unit_utilization_60 {
    group_label: "60 day Util"
    type: number
    drill_fields: [period_60_detail*]
    value_format_name: percent_1
    sql: ${days_on_rent_60} / NULLIFZERO(${days_in_fleet_60}) ;;
  }
  measure: unit_utilization_diff_60 {
    group_label: "60 day Util"
    type: number
    value_format_name: percent_1
    sql: ${unit_available_utilization_60}-${unit_utilization_60} ;;
  }
  measure: oec_utilization_60 {
    group_label: "60 day Util"
    type: number
    drill_fields: [period_60_detail*]
    value_format_name: percent_1
    sql: ${oec_on_rent_60} / NULLIFZERO(${oec_in_fleet_60}) ;;
  }

  # 90 day range
  measure: asset_total_90 {
    group_label: "90 day Util"
    type: count_distinct
    drill_fields: [period_90_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -90, CURRENT_DATE()), ${asset_id}, NULL) ;;
  }
  measure: oec_total_90 {
    group_label: "90 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_90_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -90, CURRENT_DATE()), ${purchase_price}, NULL) ;;
  }
  measure: days_on_rent_90 {
    group_label: "90 day Util"
    type: sum
    drill_fields: [period_90_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -90, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_in_fleet_90 {
    group_label: "90 day Util"
    type: sum
    drill_fields: [period_90_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -90, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_available_90 {
    group_label: "90 day Util"
    type: sum
    sql: IFF(${on_rent} or (scd_asset_inventory_status.asset_inventory_status='Ready to Rent' and ${dte_date} >= DATEADD('day', -90, CURRENT_DATE())), 1, 0) ;;
  }
  measure: oec_on_rent_90 {
    group_label: "90 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_90_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -90, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: oec_in_fleet_90 {
    group_label: "90 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_90_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -90, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: unit_available_utilization_90 {
    group_label: "90 day Util"
    type: number
    value_format_name: percent_1
    sql: ${days_on_rent_90}/NULLIFZERO(${days_available_90}) ;;
  }
  measure: unit_utilization_90 {
    group_label: "90 day Util"
    type: number
    drill_fields: [period_90_detail*]
    value_format_name: percent_1
    sql: ${days_on_rent_90} / NULLIFZERO(${days_in_fleet_90}) ;;
  }
  measure: unit_utilization_diff_90 {
    group_label: "90 day Util"
    type: number
    value_format_name: percent_1
    sql: ${unit_available_utilization_90}-${unit_utilization_90} ;;
  }
  measure: oec_utilization_90 {
    group_label: "90 day Util"
    type: number
    drill_fields: [period_90_detail*]
    value_format_name: percent_1
    sql: ${oec_on_rent_90} / NULLIFZERO(${oec_in_fleet_90}) ;;
  }

  # 120 day range
  measure: asset_total_120 {
    group_label: "120 day Util"
    type: count_distinct
    drill_fields: [period_120_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -120, CURRENT_DATE()), ${asset_id}, NULL) ;;
  }
  measure: oec_total_120 {
    group_label: "120 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_120_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -120, CURRENT_DATE()), ${purchase_price}, NULL) ;;
  }
  measure: days_on_rent_120 {
    group_label: "120 day Util"
    type: sum
    drill_fields: [period_120_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -120, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_in_fleet_120 {
    group_label: "120 day Util"
    type: sum
    drill_fields: [period_120_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -120, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_available_120 {
    group_label: "120 day Util"
    type: sum
    sql: IFF(${on_rent} or (scd_asset_inventory_status.asset_inventory_status='Ready to Rent' and ${dte_date} >= DATEADD('day', -120, CURRENT_DATE())), 1, 0) ;;
  }
  measure: oec_on_rent_120 {
    group_label: "120 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_120_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -120, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: oec_in_fleet_120 {
    group_label: "120 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_120_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -120, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: unit_available_utilization_120 {
    group_label: "120 day Util"
    type: number
    value_format_name: percent_1
    sql: ${days_on_rent_120}/NULLIFZERO(${days_available_120}) ;;
  }
  measure: unit_utilization_120 {
    group_label: "120 day Util"
    type: number
    drill_fields: [period_120_detail*]
    value_format_name: percent_1
    sql: ${days_on_rent_120} / NULLIFZERO(${days_in_fleet_120}) ;;
  }
  measure: unit_utilization_diff_120 {
    group_label: "120 day Util"
    type: number
    value_format_name: percent_1
    sql: ${unit_available_utilization_120}-${unit_utilization_120} ;;
  }
  measure: oec_utilization_120 {
    group_label: "120 day Util"
    type: number
    drill_fields: [period_120_detail*]
    value_format_name: percent_1
    sql: ${oec_on_rent_120} / NULLIFZERO(${oec_in_fleet_120}) ;;
  }

  # 180 day range
  measure: asset_total_180 {
    group_label: "180 day Util"
    type: count_distinct
    drill_fields: [period_180_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -180, CURRENT_DATE()), ${asset_id}, NULL) ;;
  }
  measure: oec_total_180 {
    group_label: "180 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_180_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -180, CURRENT_DATE()), ${purchase_price}, NULL) ;;
  }
  measure: days_on_rent_180 {
    group_label: "180 day Util"
    type: sum
    drill_fields: [period_180_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -180, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_in_fleet_180 {
    group_label: "180 day Util"
    type: sum
    drill_fields: [period_180_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -180, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_available_180 {
    group_label: "180 day Util"
    type: sum
    sql: IFF(${on_rent} or (scd_asset_inventory_status.asset_inventory_status='Ready to Rent' and ${dte_date} >= DATEADD('day', -180, CURRENT_DATE())), 1, 0) ;;
  }
  measure: oec_on_rent_180 {
    group_label: "180 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_180_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -180, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: oec_in_fleet_180 {
    group_label: "180 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_180_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -180, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: unit_available_utilization_180 {
    group_label: "180 day Util"
    type: number
    value_format_name: percent_1
    sql: ${days_on_rent_180}/NULLIFZERO(${days_available_180}) ;;
  }
  measure: unit_utilization_180 {
    group_label: "180 day Util"
    type: number
    drill_fields: [period_180_detail*]
    value_format_name: percent_1
    sql: ${days_on_rent_180} / NULLIFZERO(${days_in_fleet_180}) ;;
  }
  measure: unit_utilization_diff_180 {
    group_label: "180 day Util"
    type: number
    value_format_name: percent_1
    sql: ${unit_available_utilization_180}-${unit_utilization_180} ;;
  }
  measure: oec_utilization_180 {
    group_label: "180 day Util"
    type: number
    drill_fields: [period_180_detail*]
    value_format_name: percent_1
    sql: ${oec_on_rent_180} / NULLIFZERO(${oec_in_fleet_180}) ;;
  }

  # 365 day range
  measure: asset_total_365 {
    group_label: "365 day Util"
    type: count_distinct
    drill_fields: [period_365_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -365, CURRENT_DATE()), ${asset_id}, NULL) ;;
  }
  measure: oec_total_365 {
    group_label: "365 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_365_detail*]
    sql: IFF(${dte_date} = DATEADD('day', -365, CURRENT_DATE()), ${purchase_price}, NULL) ;;
  }
  measure: days_on_rent_365 {
    group_label: "365 day Util"
    type: sum
    drill_fields: [period_365_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -365, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_in_fleet_365 {
    group_label: "365 day Util"
    type: sum
    drill_fields: [period_365_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -365, CURRENT_DATE()), 1, 0) ;;
  }
  measure: days_available_365 {
    group_label: "365 day Util"
    type: sum
    sql: IFF((${on_rent} or scd_asset_inventory_status.asset_inventory_status='Ready To Rent') and ${dte_date} >= DATEADD('day', -365, CURRENT_DATE()), 1, 0) ;;
  }
  measure: oec_on_rent_365 {
    group_label: "365 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_365_detail*]
    sql: IFF(${on_rent} and ${dte_date} >= DATEADD('day', -365, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: oec_in_fleet_365 {
    group_label: "365 day Util"
    type: sum
    value_format_name: usd_0
    drill_fields: [period_365_detail*]
    sql: IFF(${asset_id} is not null and ${dte_date} >= DATEADD('day', -365, CURRENT_DATE()), ${purchase_price}, 0) ;;
  }
  measure: days_down_365 {
    group_label: "365 day Util"
    type: sum
    sql: IFF(${on_rent}=false and scd_asset_inventory_status.asset_inventory_status in('Hard Down','Soft Down')and ${dte_date} >= DATEADD('day', -365, CURRENT_DATE()), 1, 0)  ;;
  }
  measure: days_limbo_365 {
    group_label: "365 day Util"
    type: sum
    sql: IFF(${on_rent}=false and scd_asset_inventory_status.asset_inventory_status in('Pre-Delivered','Pending Return','Assigned')and ${dte_date} >= DATEADD('day', -365, CURRENT_DATE()), 1, 0)  ;;
  }
  measure: days_needs_insp_365 {
    group_label: "365 day Util"
    type: sum
    sql: IFF(${on_rent}=false and scd_asset_inventory_status.asset_inventory_status in('Needs Inspection')and ${dte_date} >= DATEADD('day', -365, CURRENT_DATE()), 1, 0)  ;;
  }
  measure: perc_hard_soft_down_days_365 {
    group_label: "365 day Util"
    type: number
    value_format_name: percent_1
    sql: ${days_down_365}/NULLIFZERO(${days_in_fleet_365}) ;;
  }
  measure: perc_waiting_days_365 {
    group_label: "365 day Util"
    type: number
    value_format_name: percent_1
    sql: ${days_limbo_365}/NULLIFZERO(${days_in_fleet_365}) ;;
  }
  measure: perc_needs_inspection_days_365 {
    group_label: "365 day Util"
    type: number
    value_format_name: percent_1
    sql: ${days_needs_insp_365}/NULLIFZERO(${days_in_fleet_365}) ;;
  }
  measure: perc_available_or_on_rent_days_365 {
    group_label: "365 day Util"
    type: number
    value_format_name: percent_1
    sql: ${days_available_365}/NULLIFZERO(${days_in_fleet_365}) ;;
  }
  measure: unit_available_utilization_365 {
    group_label: "365 day Util"
    type: number
    value_format_name: percent_1
    sql: ${days_on_rent_365}/NULLIFZERO(${days_available_365}) ;;
  }
  measure: unit_utilization_365 {
    group_label: "365 day Util"
    type: number
    drill_fields: [period_365_detail*]
    value_format_name: percent_1
    sql: ${days_on_rent_365} / NULLIFZERO(${days_in_fleet_365}) ;;
  }
  measure: unit_utilization_difference_365 {
    group_label: "365 day Util"
    type: number
    value_format_name: percent_1
    sql: ${unit_available_utilization_365}-${unit_utilization_365} ;;
  }
  measure: oec_utilization_365 {
    group_label: "365 day Util"
    type: number
    drill_fields: [period_365_detail*]
    value_format_name: percent_1
    sql: ${oec_on_rent_365} / NULLIFZERO(${oec_in_fleet_365}) ;;
  }

set: ute_detail {
  fields: [assets_aggregate.class,assets_aggregate.make,assets_aggregate.model,asset_count_drill,perc_hard_soft_down_days_365,perc_needs_inspection_days_365,perc_waiting_days_365,perc_available_or_on_rent_days_365,unit_utilization_365,unit_available_utilization_365]
}
  set: ute_detail_market {
    fields: [assets_aggregate.class,assets_aggregate.make,assets_aggregate.model,market_region_xwalk.market_name,asset_count,perc_hard_soft_down_days_365,perc_needs_inspection_days_365,perc_waiting_days_365,perc_available_or_on_rent_days_365,unit_utilization_365,unit_available_utilization_365]
  }
  set: period_30_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, days_on_rent_30, days_in_fleet_30, unit_utilization_30, oec_utilization_30]
  }
  set: period_60_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, days_on_rent_60, days_in_fleet_60, unit_utilization_60, oec_utilization_60]
  }
  set: period_90_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, days_on_rent_90, days_in_fleet_90, unit_utilization_90, oec_utilization_90]
  }
  set: period_120_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, days_on_rent_120, days_in_fleet_120, unit_utilization_120, oec_utilization_120]
  }
  set: period_180_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, days_on_rent_180, days_in_fleet_180, unit_utilization_180, oec_utilization_180]
  }
  set: period_365_detail {
    fields: [asset_id, assets_aggregate.custom_name, assets_aggregate.make, assets_aggregate.model, days_on_rent_365, days_in_fleet_365, unit_utilization_365, oec_utilization_365]
  }
}
