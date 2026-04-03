view: retail_sales_asset_detail {
   derived_table: {
     sql:
select ad.*
     , qd.salesperson_user_id
     , qd.salesperson_name
     , qd.salesperson_email
     , qd.parent_market_id
 from analytics.ls_dbt.int_retail_sales_asset_detail ad
 left join analytics.retail_sales.retail_sales_quotes qd on ad.quote_id = qd.quote_id
 where ad.is_current = TRUE;;
   }

  dimension: pk_id {
    type: string
    sql: ${TABLE}."PK_ID" ;;
  }

  dimension: quote_created_at {
    type: date_time
    sql: ${TABLE}."QUOTE_CREATED_AT" ;;
  }

  dimension: quote_completed_at {
    type: date_time
    sql: ${TABLE}."QUOTE_COMPLETED_AT" ;;
  }

  dimension: quote_date_filter {
    label: "Quote Date Filter"
    type: date
    sql: case
          when ${TABLE}."QUOTE_COMPLETED_AT" is not null then date_trunc(month,${TABLE}."QUOTE_COMPLETED_AT"::date)
          when ${TABLE}."STATUS" in ('denied','lost sale') then date_trunc(month,${TABLE}."QUOTE_CREATED_AT"::date)
          else date_trunc(month,CURRENT_DATE)
         end ;;
  }

  dimension: status {
    type: string
    label: "Status"
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: quote_pk_id {
    type: number
    sql: ${TABLE}."QUOTE_PK_ID" ;;
  }

  dimension: quote_id {
    type: number
    label: "QuoteID"
    sql: ${TABLE}."QUOTE_ID" ;;
  }

  dimension: asset_pk_id {
    type: string
    sql: ${TABLE}."ASSET_PK_ID" ;;
  }

  dimension: asset_id {
    type: number
    label: "AssetID"
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: make {
    label: "OEM"
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    label: "Model"
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  measure: rebate_oec {
    label: "Rebate OEC"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."REBATE_OEC" ;;
  }

  measure: sale_price {
    label: "Sale Price"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  measure: oec {
    label: "OEC"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."OEC" ;;
  }

  measure: additional_items_price {
    label: "Additional Items Price"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."ADDITIONAL_ITEMS_PRICE" ;;
  }

  measure: additional_items_cost {
    label: "Additional Items Cost"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."ADDITIONAL_ITEMS_COST" ;;
  }

  measure: total_trade_in_value {
    label: "Total Trade-in Value"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."TOTAL_TRADE_IN_VALUE" ;;
  }

  measure: total_trade_in_value_over_allowance {
    label: "Total Trade-in Over Allowance"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."TOTAL_TRADE_IN_VALUE_OVER_ALLOWANCE" ;;
  }

  measure: total_price {
    label: "Sales Revenue"
    type: sum
    sql: ${TABLE}."TOTAL_ASSET_PRICE" ;;
  }

  measure: total_cost {
    label: "Sales Expense"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."TOTAL_ASSET_COST" ;;
  }

  measure: total_rebate {
    label: "Sales Rebates"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."TOTAL_REBATE" ;;
  }

  measure: total_margin {
    label: "Sales Margin"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."TOTAL_MARGIN" ;;
  }

  measure: row_count {
    label: "Asset Sales Count"
    type: count
  }

  dimension: salesperson_user_id {
    label: "SalespersonID"
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: parent_market_id {
    label: "MarketID"
    type: number
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
  }

  dimension: salesperson_name {
    label: "Salesperson Name"
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }

  dimension: salesperson_email {
    label: "Salesperson Email"
    type: string
    sql: ${TABLE}."SALESPERSON_EMAIL" ;;
  }

}
