view: stg_es_warehouse_scd__scd_asset_inventory_status {
  sql_table_name: "INTACCT_MODELS"."STG_ES_WAREHOUSE_SCD__SCD_ASSET_INVENTORY_STATUS" ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: asset_inv_status_seq {
    type: number
    sql: ${TABLE}."ASSET_INV_STATUS_SEQ" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  dimension: current_flag {
    type: yesno
    sql: ${TABLE}."CURRENT_FLAG" ;;
  }
  dimension_group: date_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }
  dimension: inventory_status_duration_days {
    type: number
    sql: ${TABLE}."INVENTORY_STATUS_DURATION_DAYS" ;;
  }

  dimension: asset_inventory_status_date_over_30_days {
    type: yesno
    sql: ${inventory_status_duration_days} > 30 ;;
  }

# Hard Down Measures
  measure: hard_down_assets{
    type: count
    filters: [asset_inventory_status: "Hard Down"]
    drill_fields: [detail*]
  }

  measure: hard_down_oec{
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql:${int_assets.oec_raw}  ;;
    filters: [asset_inventory_status: "Hard Down"]
    drill_fields: [detail*]
  }

  dimension: hard_down_column {
    type: string
    label: "Hard Down"
    sql: 'Hard Down' ;;
    html: Assets: {{hard_down_assets._rendered_value}} | OEC: {{hard_down_oec._rendered_value}} ;;
    drill_fields: [detail*]
  }

  # Soft Down Measures
  measure: severe_soft_down_assets {
    type: count
    filters: [
      asset_inventory_status: "Soft Down",
      asset_inventory_status_date_over_30_days: "yes"
    ]
    drill_fields: [detail*]
  }

  measure: severe_soft_down_oec {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql:${int_assets.oec_raw}  ;;
    filters: [
      asset_inventory_status: "Soft Down",
      asset_inventory_status_date_over_30_days: "yes"
    ]
  }

  dimension: severe_soft_down_column {
    type: string
    label: "Severe Soft Down"
    sql: 'Severe Soft Down' ;;
    html: Assets: {{severe_soft_down_assets._rendered_value}} | OEC: {{severe_soft_down_oec._rendered_value}} ;;
    drill_fields: [detail*]
  }

  measure: hard_down_and_severe_soft_down_oec {
    label: "Total OEC ($)"
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql:
    CASE
      WHEN ${asset_inventory_status} = 'Hard Down'
        OR (
          ${asset_inventory_status} = 'Soft Down'
          AND ${asset_inventory_status_date_over_30_days}
        )
      THEN ${int_assets.oec_raw}
      ELSE 0
    END ;;
    drill_fields: [detail*]
  }


  measure: count {
    type: count
    drill_fields: [asset_id]
  }

  set: detail {
    fields: [
      asset_id,
      asset_inventory_status_date_over_30_days,
      asset_inventory_status,
      inventory_status_duration_days,
      market_region_xwalk.market_id,
      market_region_xwalk.market_name,
      int_assets.oec
    ]
  }
}
