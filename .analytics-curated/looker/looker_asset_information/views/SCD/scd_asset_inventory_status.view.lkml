view: scd_asset_inventory_status {
  sql_table_name: "ES_WAREHOUSE"."SCD"."SCD_ASSET_INVENTORY_STATUS"
    ;;

  dimension: asset_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_id_wo_link {
    type: number
    value_format_name: id
    sql: ${asset_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: COALESCE(${TABLE}."ASSET_INVENTORY_STATUS", 'Unassigned');;
  }

  dimension: current_flag {
    type: number
    sql: ${TABLE}."CURRENT_FLAG" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${current_flag}) ;;
  }

  dimension_group: date_end {
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
    sql: CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_start {
    label: "Asset Status Start"
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
    sql: CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_inventory_status_date_over_30_days {
    type: yesno
    sql: datediff(day,${date_start_date},current_date()) > 30 ;;
#     current_date() - ${date_start_date} > 30 ;;
  }

  dimension: asset_inventory_status_date_over_3_days {
    type: yesno
    sql: datediff(day,${date_start_date},current_date()) > 3 ;;
#     current_date() - ${date_start_date} > 3 ;;
  }

  dimension: asset_inventory_status_duration {
    type: number
    sql: datediff(day, ${date_start_date}, current_date()) ;;
  }

  measure: count_of_hard_down_assets{
    type: count
    filters: [asset_inventory_status: "Hard Down"]
    drill_fields: [detail*]
  }

  measure: count_of_soft_down_assets{
    type: count
    filters: [asset_inventory_status: "Soft Down"]
    drill_fields: [detail*]
  }

  measure: count_of_needs_inspection_assets{
    type: count
    filters: [asset_inventory_status: "Needs Inspection"]
    drill_fields: [detail*]
  }

  measure: count_of_make_ready_assets{
    type: count
    filters: [asset_inventory_status: "Make Ready"]
    drill_fields: [detail*]
  }

  measure: count_of_pending_return_assets{
    type: count
    filters: [asset_inventory_status: "Pending Return"]
    drill_fields: [detail*]
  }

  measure: count_of_on_rent_assets{
    type: count
    filters: [asset_on_rent: "Yes"]
    # filters: [asset_inventory_status: "On Rent", asset_inventory_status: "On RPO"]
    drill_fields: [detail*]
  }

  measure: count_of_on_rpo_assets{
    type: count
    filters: [asset_inventory_status: "On RPO"]
    drill_fields: [detail*]
  }

  measure: count_of_down_status {
    type: number
    sql: ${count_of_soft_down_assets} + ${count_of_hard_down_assets} ;;
    drill_fields: [detail*]
  }

  dimension: asset_on_rent {
    type: yesno
    sql: ${asset_inventory_status} = 'On Rent' OR ${asset_inventory_status} = 'On RPO' ;;
  }

  measure: count_of_hard_down_assets_over_30_days{
    type: count
    filters: [asset_inventory_status: "Hard Down",asset_inventory_status_date_over_30_days: "Yes"]
    drill_fields: [detail*]
  }

  measure: count_of_soft_down_assets_over_30_days{
    type: count
    filters: [asset_inventory_status: "Soft Down",asset_inventory_status_date_over_30_days: "Yes"]
    drill_fields: [detail*]
  }

  measure: count_of_pick_up_assets_over_3_days{
    type: count
    filters: [asset_inventory_status: "Pending Return",asset_inventory_status_date_over_3_days: "Yes"]
    drill_fields: [detail*]
  }

  measure: count_of_make_ready_assets_over_3_days{
    type: count
    filters: [asset_inventory_status: "Make Ready",asset_inventory_status_date_over_3_days: "Yes"]
    drill_fields: [detail*]
  }

  measure: count_of_needs_inspection_assets_over_3_days{
    type: count
    filters: [asset_inventory_status: "Needs Inspection",asset_inventory_status_date_over_3_days: "Yes"]
    drill_fields: [detail*]
  }

  dimension: severe_status {
    type: string
    sql: case when (${asset_inventory_status} in ('Make Ready', 'Needs Inspection','Pending Return') and ${asset_inventory_status_date_over_3_days}='Yes')
    or (${asset_inventory_status} in ('Hard Down','Soft Down') and ${asset_inventory_status_date_over_30_days}='Yes')
    then 'Severe'
    else 'Other'
    end ;;
  }

  dimension: status_sort {
    type: number
    sql: case when ${asset_inventory_status} = 'Pending Return' then 1
    when ${asset_inventory_status}= 'Make Ready' then 2
    when ${asset_inventory_status}='Needs Inspection' then 3
    when ${asset_inventory_status}= 'Soft Down' then 4
    when ${asset_inventory_status}='Hard Down' then 5
    else null
    end ;;
  }

  dimension: days_in_current_status {
    type: number
    sql: DATEDIFF('day', date_start, current_date()) ;;
  }

  measure: count {
    type: count
    html: {{count._rendered_value}} assets | {{assets_aggregate.total_oec._rendered_value}} OEC ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      market_region_xwalk.market_name,
      assets.serial_number,
      asset_id_wo_link,
      most_recent_rental.days_on_rent,
      assets_aggregate.category,
      assets_aggregate.class,
      assets_inventory.make,
      assets_inventory.model,
      scd_asset_hours_consolidated.hours,
      asset_inventory_status,
      days_in_current_status,
      date_start_date,
      asset_purchase_history_facts_final.OEC,
      wo_updates_latest.work_order_id,
      3c_clusters.complaint,
      3c_clusters.cause,
      3c_clusters.correction,
      wo_updates_latest.update_type,
      asset_location.address,
      asset_location.map_link
    ]
  }
}
