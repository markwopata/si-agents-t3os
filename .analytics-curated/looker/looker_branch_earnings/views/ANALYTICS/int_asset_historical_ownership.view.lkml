view: int_asset_historical_ownership {
  derived_table: {
    sql:
    select *
    from analytics.assets.int_asset_historical_ownership
    where date_trunc('month', month_end_date) between
      date_trunc(
        'month',
        dateadd(
          month, -11,
          (select min(trunc::date)
           from analytics.gs.plexi_periods
           where {% condition period_name %} display {% endcondition %})
        )
      )
      and
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

  dimension: asset_company_id {
    type: number
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_inv_status_seq {
    type: number
    sql: ${TABLE}."ASSET_INV_STATUS_SEQ" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  dimension_group: daily_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DAILY_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: days_in_status {
    type: number
    sql: ${TABLE}."DAYS_IN_STATUS" ;;
  }
  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }
  dimension: inventory_branch_name {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH_NAME" ;;
  }
  dimension: inventory_status_duration_days {
    type: number
    sql: ${TABLE}."INVENTORY_STATUS_DURATION_DAYS" ;;
  }
  dimension: is_managed_by_es_owned_market {
    type: yesno
    sql: ${TABLE}."IS_MANAGED_BY_ES_OWNED_MARKET" ;;
  }
  dimension: is_rerent_asset {
    type: yesno
    sql: ${TABLE}."IS_RERENT_ASSET" ;;
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
  dimension_group: month_end {
    type: time
    timeframes: [date, month, quarter, year]
    sql: ${TABLE}."MONTH_END_DATE"::date ;;
  }
  dimension: owning_company_name {
    type: string
    sql: ${TABLE}."OWNING_COMPANY_NAME" ;;
  }
  dimension: pk_asset_daily_timestamp_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."PK_ASSET_DAILY_TIMESTAMP_ID" ;;
  }
  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }
  dimension: rental_branch_name {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_NAME" ;;
  }
  dimension: service_branch_id {
    type: number
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }
  dimension: service_branch_name {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH_NAME" ;;
  }

  measure: oec {
    label: "Total OEC (USD$)"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."OEC" ;;
  }

  measure: unavailable_oec {
    label: "Total Unavailable OEC (USD$)"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql:
    case
      when ${asset_inventory_status} in ('Needs Inspection','Hard Down','Soft Down','Make Ready','Pending Return')
      then ${TABLE}."OEC"
      else 0
    end ;;
  }

  dimension: ordered_unavailable_asset_inventory_status_types {
    description: "Ordered categories for asset_inventory_status types to be used in formatting."
    type: string
    sql:
      CASE
        WHEN ${asset_inventory_status} = 'Hard Down' THEN '1'
        WHEN ${asset_inventory_status} = 'Soft Down' THEN '2'
        WHEN ${asset_inventory_status} = 'Needs Inspection' THEN '3'
        WHEN ${asset_inventory_status} = 'Make Ready' THEN '4'
        ELSE '5'
      END ;;
  }

  measure: oec_pct_of_month_by_status {
    label: "OEC % of Month (by Inventory Status)"
    type: number
    value_format: "0.0%"

    # Numerator: OEC for the row's group (e.g., month + inventory status)
    # Denominator: total OEC across ALL inventory statuses in the same month
    sql:
      ${oec} / NULLIF(
        SUM(${oec}) OVER (PARTITION BY ${month_end_month}),
        0
      ) ;;
    drill_fields: [asset_inventory_status, month_end_month, oec]
  }


  measure: oec_on_rent {
    label: "Total OEC on Rent (USD$)"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql:
    case
      when ${asset_inventory_status} = 'On Rent'
      then ${TABLE}."OEC"
      else 0
    end ;;
  }


  measure: count {
    type: count
    drill_fields: [market_name, owning_company_name, inventory_branch_name, service_branch_name, rental_branch_name]
  }
}
