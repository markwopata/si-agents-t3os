view: spend_summary_mapping {
  sql_table_name: "ANALYTICS"."TREASURY"."SPEND_SUMMARY_MAPPING" ;;

  ############## DIMENSIONS ##############

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
    value_format_name: id
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: mapping_lv_1 {
    type: string
    sql:
    case when  ${ap_payments_no_filter.account}  = '1307' and  ${ap_payments_no_filter.sold_assets} = 'yes' then 'Sold Asset Payoffs'
    else ${TABLE}."MAPPING_LV_1" end ;;
  }

  dimension: mapping_lv_1_sort {
    type: string
    sql: case when ${mapping_lv_1} = 'Equipment Purchases' then 1
    when ${mapping_lv_1} = 'Payables' then 2
    when ${mapping_lv_1} = 'Financing' then 3
    when ${mapping_lv_1} = 'Employee Comp' then 4
    when ${mapping_lv_1} = 'Own Program Fee' then 5
    when ${mapping_lv_1} = 'Parts' then 6
    when ${mapping_lv_1} = 'Taxes' then 7
    when ${mapping_lv_1} = 'Property' then 8
    when ${mapping_lv_1} = 'Other' then 9
    when ${mapping_lv_1} = 'Sold Asset Payoffs' then 999
    else 9999 end ;;
  }


  dimension: mapping_lv_2 {
    type: string
    sql: ${TABLE}."MAPPING_LV_2" ;;
  }

  dimension: mapping_lv_3 {
    type: string
    sql: ${TABLE}."MAPPING_LV_3" ;;
  }

  dimension: key {
    type: string
    primary_key: yes
    sql: concat(${account},${mapping_lv_1},${mapping_lv_2}) ;;
  }

  dimension: parts_spend_grouping {
    type: string
    sql: case when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} in ('V32370','V24024') then 'John Deere'
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} in ('V34759','V12603') then 'Sany'
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V12235' then 'Manitou'
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V26183' then 'Wacker'
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V12750' then 'Genie'
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V27903' then 'Terex'
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V12074' then 'JLG'
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V12191' then 'Takeuchi'
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V12154' then 'JCB'
        when ${mapping_lv_1} = 'Parts'and ${ap_payments_no_filter.vendor_id} not in ('V12154','V12074','V12750','V32370','V12191','V12235','V26183','V34759','V12603','V27903') then 'Other Parts'
        else 'Non-Parts' end;;
  }

  dimension: parts_spend_grouping_sort {
    type: string
    sql: case when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} in ('V32370','V24024') then 4
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} in ('V34759','V12603') then 8
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V12235' then 7
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V26183' then 6
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V12750' then 2
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V27903' then 9
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V12074' then 1
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V12191' then 3
    when ${mapping_lv_1} = 'Parts' and ${ap_payments_no_filter.vendor_id} = 'V12154' then 5
        when ${mapping_lv_1} = 'Parts'and ${ap_payments_no_filter.vendor_id} not in ('V12154','V12074','V12750','V32370','V12191','V12235','V26183','V34759','V12603','V27903') then 99
        else 999 end ;;
  }


  dimension: total_spend_category {
    type: string
    sql: 'Total Spend Category' ;;
    html: <p style = background-color: black><font color="white" >{{ value }}</font></p> ;;
  }

  dimension: category_breakdown {
    type: string
    sql: 'Category Breakdown' ;;
    html: <p style = background-color: black><font color="white" >{{ value }}</font></p> ;;
  }







}
