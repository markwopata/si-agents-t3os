view: max_month_oec_by_asset_inventory_status {
  derived_table: {
    sql:
    select *
    from analytics.assets.int_asset_historical
    where date_trunc('month', daily_timestamp) =
      date_trunc(
        'month',
        (select max(trunc::date)
         from analytics.gs.plexi_periods
         where {% condition period_name %} display {% endcondition %})
      )
    ;;
  }

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: _non_rental_revenue {
    type: number
    sql: ${TABLE}."_NON_RENTAL_REVENUE" ;;
  }
  dimension: asset_company_id {
    type: number
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  dimension: asset_payout_percentage {
    type: number
    sql: ${TABLE}."ASSET_PAYOUT_PERCENTAGE" ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }
  dimension_group: daily_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DAILY_TIMESTAMP"::date ;;
  }
  dimension: days_in_status {
    type: number
    sql: ${TABLE}."DAYS_IN_STATUS" ;;
  }
  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }
  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}."FINANCIAL_SCHEDULE_ID" ;;
  }
  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}."FINANCING_FACILITY_TYPE" ;;
  }
  dimension_group: first_rental {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."FIRST_RENTAL_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: in_rental_fleet {
    type: yesno
    sql: ${TABLE}."IN_RENTAL_FLEET" ;;
  }
  dimension: in_total_fleet {
    type: yesno
    sql: ${TABLE}."IN_TOTAL_FLEET" ;;
  }
  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }
  dimension: inventory_branch_name {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_NAME" ;;
  }
  dimension: is_asset_unavailable {
    type: yesno
    sql: ${TABLE}."IS_ASSET_UNAVAILABLE" ;;
  }
  dimension: is_in_transit {
    type: yesno
    sql: ${TABLE}."IS_IN_TRANSIT" ;;
  }
  dimension: is_last_rental_in_day {
    type: yesno
    sql: ${TABLE}."IS_LAST_RENTAL_IN_DAY" ;;
  }
  dimension: is_managed_by_es_owned_market {
    type: yesno
    sql: ${TABLE}."IS_MANAGED_BY_ES_OWNED_MARKET" ;;
  }
  dimension: is_on_rent {
    type: yesno
    sql: ${TABLE}."IS_ON_RENT" ;;
  }
  dimension: is_own_program_asset {
    type: yesno
    sql: ${TABLE}."IS_OWN_PROGRAM_ASSET" ;;
  }
  dimension: is_payout_program_enrolled {
    type: yesno
    sql: ${TABLE}."IS_PAYOUT_PROGRAM_ENROLLED" ;;
  }
  dimension: is_payout_program_unpaid {
    type: yesno
    sql: ${TABLE}."IS_PAYOUT_PROGRAM_UNPAID" ;;
  }
  dimension: is_rerent_asset {
    type: yesno
    sql: ${TABLE}."IS_RERENT_ASSET" ;;
  }
  dimension: lender_name {
    type: string
    sql: ${TABLE}."LENDER_NAME" ;;
  }
  dimension: loan_name {
    type: string
    sql: ${TABLE}."LOAN_NAME" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: market_company_id {
    type: number
    sql: ${TABLE}."MARKET_COMPANY_ID" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: owning_company_name {
    type: string
    sql: ${TABLE}."OWNING_COMPANY_NAME" ;;
  }

  dimension_group: month_end {
    type: time
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}."MONTH_END_DATE"::date ;;
  }

  dimension: payout_program_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_ID" ;;
  }
  dimension: payout_program_name {
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_NAME" ;;
  }
  dimension: payout_program_type {
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_TYPE" ;;
  }

  measure: oec {
    label: "Total OEC (USD$)"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."OEC" ;;
  }

  measure: oec_on_rent {
    label: "Total OEC on Rent (USD$)"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  dimension: pending_return_oec {
    type: number
    sql: ${TABLE}."PENDING_RETURN_OEC" ;;
  }
  dimension: pending_return_units {
    type: number
    sql: ${TABLE}."PENDING_RETURN_UNITS" ;;
  }
  dimension: pk_asset_daily_timestamp_id {
    type: string
    sql: ${TABLE}."PK_ASSET_DAILY_TIMESTAMP_ID" ;;
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension_group: purchase {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."PURCHASE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }
  dimension: rental_branch_name {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_NAME" ;;
  }
  measure: rental_fleet_oec {
    label: "Rental Fleet OEC (USD$)"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
  }

  measure: rental_fleet_units{
    label: "Rental Fleet Units"
    type: sum
    sql: ${TABLE}."RENTAL_FLEET_UNITS" ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }
  dimension: sage_lender_vendor_id {
    type: string
    sql: ${TABLE}."SAGE_LENDER_VENDOR_ID" ;;
  }
  dimension: schedule_account_number {
    type: string
    sql: ${TABLE}."SCHEDULE_ACCOUNT_NUMBER" ;;
  }
  dimension_group: schedule_commencement {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SCHEDULE_COMMENCEMENT_DATE" ;;
  }
  dimension: schedule_number {
    type: string
    sql: ${TABLE}."SCHEDULE_NUMBER" ;;
  }
  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }
  dimension: service_branch_name {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH_NAME" ;;
  }
  dimension: total_oec {
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
  }
  dimension: total_units {
    type: number
    sql: ${TABLE}."TOTAL_UNITS" ;;
  }
  dimension: transfer_status {
    type: string
    sql: ${TABLE}."TRANSFER_STATUS" ;;
  }
  measure: unavailable_oec {
    label: "Total Unavailable OEC (USD$)"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."UNAVAILABLE_OEC" ;;
  }
  dimension: unavailable_units {
    type: number
    sql: ${TABLE}."UNAVAILABLE_UNITS" ;;
  }
  dimension: units_on_rent {
    type: number
    sql: ${TABLE}."UNITS_ON_RENT" ;;
  }

  measure: oec_pct_of_month_by_status {
    label: "Rental Fleet OEC % of Month (by Inventory Status)"
    type: number
    value_format: "0.0%"

    # Numerator: OEC for the row's group (e.g., month + inventory status)
    # Denominator: total OEC across ALL inventory statuses in the same month
    sql:
      ${rental_fleet_oec} / NULLIF(
        SUM(${rental_fleet_oec}) OVER (PARTITION BY ${month_end_month}),
        0
      ) ;;
    drill_fields: [asset_inventory_status, month_end_month, rental_fleet_oec]
  }

  measure: rental_fleet_oec_on_rent {
    label: "Total Rental Fleet OEC on Rent (USD$)"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql:
    case
      when ${asset_inventory_status} = 'On Rent'
      then ${TABLE}."RENTAL_FLEET_OEC"
      else 0
    end ;;
  }

  measure: oec_total {
    type: sum
    label: "Rental OEC Total ($)"
    sql: ${rental_fleet_oec} ;;
  }

  measure: rental_fleet_needs_inspection {
    label: "Total Rental Fleet Needs Inspection (USD$)"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql:
    case
      when ${asset_inventory_status} = 'Needs Inspection'
      then ${TABLE}."RENTAL_FLEET_OEC"
      else 0
    end ;;
  }

  measure: rental_fleet_pending_return {
    label: "Total Rental Fleet Pending Return (USD$)"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql:
    case
      when ${asset_inventory_status} = 'Pending Return'
      then ${TABLE}."RENTAL_FLEET_OEC"
      else 0
    end ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: asset_id_count{
    type: count
    drill_fields: [asset_id]
  }

  measure: daily_timestamp {
    type: count_distinct
    drill_fields: [daily_timestamp_date]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      asset_inventory_status,
      month_end_month,
      asset_id
    ]
  }

}
