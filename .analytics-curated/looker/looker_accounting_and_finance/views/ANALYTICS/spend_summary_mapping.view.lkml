view: spend_summary_mapping {
  sql_table_name: "ANALYTICS"."TREASURY"."SPEND_SUMMARY_MAPPING" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  #dimension: mapping_lv_1 {
  #  type: string
  #  sql:
  #  case when  ${ap_payments_no_filter.account}  = '1307' and  ${ap_payments_no_filter.sold_assets} = 'yes' then 'Sold Asset Payoffs'
  #  else ${TABLE}."MAPPING_LV_1" end ;;
  #}

  dimension: mapping_lv_1 {
    type: string
    sql: ${TABLE}."MAPPING_LV_1" ;;
    }

  dimension: mapping_lv_2 {
    type: string
    sql: ${TABLE}."MAPPING_LV_2" ;;
  }

  dimension: mapping_lv_3 {
    type: string
    sql: ${TABLE}."MAPPING_LV_3" ;;
  }

}
