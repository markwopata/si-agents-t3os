# access_grant: can_view_nbv_role {
#   user_attribute: job_role
#   allowed_values: [ "'leadership'", "'developer'" ]
# }

access_grant: can_view_nbv {
  user_attribute: department
  allowed_values: [ "'god view'", "'developer'"]
}

view: dim_assets_fleet_opt {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_ASSETS_FLEET_OPT" ;;

  dimension: asset_abl_flag {
    type: yesno
    sql: ${TABLE}."ASSET_ABL_FLAG" ;;
  }
  dimension: asset_abs_flag {
    type: yesno
    sql: ${TABLE}."ASSET_ABS_FLAG" ;;
  }
  dimension: asset_active {
    type: yesno
    sql: ${TABLE}."ASSET_ACTIVE" ;;
  }
  dimension: asset_bench_target_price {
    type: number
    sql: ${TABLE}."ASSET_BENCH_TARGET_PRICE" ;;
  }
  dimension: asset_company_id {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }
  dimension: asset_company_key {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_KEY" ;;
  }
  dimension: asset_current_finance_status {
    type: string
    sql: ${TABLE}."ASSET_CURRENT_FINANCE_STATUS" ;;
  }
  dimension: asset_current_net_book_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}."ASSET_CURRENT_NET_BOOK_VALUE" ;;
    required_access_grants: [can_view_nbv]
  }
  dimension: asset_current_oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."ASSET_CURRENT_OEC" ;;
  }
  dimension: asset_deal_sales_flag {
    type: yesno
    sql: ${TABLE}."ASSET_DEAL_SALES_FLAG" ;;
  }
  dimension: asset_description {
    type: string
    sql: ${TABLE}."ASSET_DESCRIPTION" ;;
  }
  dimension: asset_equipment_category_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CATEGORY_NAME" ;;
  }
  dimension: asset_equipment_class_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CLASS_NAME" ;;
  }
  dimension: asset_equipment_contractor_owned {
    type: yesno
    sql: ${TABLE}."ASSET_EQUIPMENT_CONTRACTOR_OWNED" ;;
  }
  dimension: asset_equipment_make {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE" ;;
  }
  dimension: asset_equipment_make_and_model {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE_AND_MODEL" ;;
  }
  dimension: asset_equipment_make_id {
    type: number
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE_ID" ;;
  }
  dimension: asset_equipment_model_id {
    type: number
    sql: ${TABLE}."ASSET_EQUIPMENT_MODEL_ID" ;;
  }
  dimension: asset_equipment_model_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MODEL_NAME" ;;
  }
  dimension: asset_equipment_subcategory_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_SUBCATEGORY_NAME" ;;
  }
  dimension: asset_equipment_type {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_TYPE" ;;
  }
  dimension_group: asset_first_rental_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_FIRST_RENTAL_START_DATE" ;;
  }
  dimension: asset_floor_target_price {
    type: number
    sql: ${TABLE}."ASSET_FLOOR_TARGET_PRICE" ;;
  }
  dimension: asset_has_operational_lease {
    type: yesno
    sql: ${TABLE}."ASSET_HAS_OPERATIONAL_LEASE" ;;
  }
  dimension: asset_has_subsidy {
    type: yesno
    sql: ${TABLE}."ASSET_HAS_SUBSIDY" ;;
  }
  dimension: asset_hours {
    type: number
    sql: ${TABLE}."ASSET_HOURS" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_id_link {
    label: "Asset ID"
    type: string
    sql: ${asset_id} ;;
    html: <a href="https://app.estrack.com/#/assets/all/asset/{{asset_id._value}}/edit" target="new" style="color: #0063f3; text-decoration: underline;">{{ asset_id._value }}</a> ;;
  }
  dimension: asset_inventory_market_id {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_MARKET_ID" ;;
  }
  dimension: asset_inventory_market_key {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_MARKET_KEY" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  dimension_group: asset_inventory_status {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_INVENTORY_STATUS_DATE" ;;
  }
  dimension: asset_key {
    type: string
    sql: ${TABLE}."ASSET_KEY" ;;
  }
  dimension: asset_maintenance_service_provider_market_id {
    type: string
    sql: ${TABLE}."ASSET_MAINTENANCE_SERVICE_PROVIDER_MARKET_ID" ;;
  }
  dimension: asset_maintenance_service_provider_market_key {
    type: string
    sql: ${TABLE}."ASSET_MAINTENANCE_SERVICE_PROVIDER_MARKET_KEY" ;;
  }
  dimension: asset_market_id {
    type: string
    sql: ${TABLE}."ASSET_MARKET_ID" ;;
  }
  dimension: asset_market_key {
    type: string
    sql: ${TABLE}."ASSET_MARKET_KEY" ;;
  }
  dimension_group: asset_most_recent_on_rent {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_MOST_RECENT_ON_RENT_DATE" ;;
  }
  dimension_group: asset_most_recent_pricing {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ASSET_MOST_RECENT_PRICING_DATE" ;;
  }
  dimension: asset_net_book_value_descriptive {
    type: number
    sql: ${TABLE}."ASSET_NET_BOOK_VALUE_DESCRIPTIVE" ;;
    required_access_grants: [can_view_nbv]
  }
  dimension: asset_never_rented {
    type: yesno
    sql: ${TABLE}."ASSET_NEVER_RENTED" ;;
  }
  dimension: asset_odometer {
    type: number
    sql: ${TABLE}."ASSET_ODOMETER" ;;
  }
  dimension: asset_oef_deal_flag {
    type: yesno
    sql: ${TABLE}."ASSET_OEF_DEAL_FLAG" ;;
  }
  dimension: asset_oem_deal_flag {
    type: yesno
    sql: ${TABLE}."ASSET_OEM_DEAL_FLAG" ;;
  }
  dimension_group: asset_oem_delivery {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_OEM_DELIVERY_DATE" ;;
  }
  dimension: asset_online_target_price {
    type: number
    sql: ${TABLE}."ASSET_ONLINE_TARGET_PRICE" ;;
  }
  dimension: asset_own_flag {
    type: yesno
    sql: ${TABLE}."ASSET_OWN_FLAG" ;;
  }
  dimension: asset_payout_program {
    type: string
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM" ;;
  }
  dimension: asset_payout_program_billing_type {
    type: string
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM_BILLING_TYPE" ;;
  }
  dimension: asset_payout_program_percentage {
    type: number
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM_PERCENTAGE" ;;
  }
  dimension: asset_payout_program_type {
    type: string
    sql: ${TABLE}."ASSET_PAYOUT_PROGRAM_TYPE" ;;
  }
  dimension_group: asset_purchase {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ASSET_PURCHASE_DATE" ;;
  }
  dimension_group: asset_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ASSET_RECORDTIMESTAMP" ;;
  }
  dimension: asset_rentable {
    type: yesno
    sql: ${TABLE}."ASSET_RENTABLE" ;;
  }
  dimension: asset_rental_market_id {
    type: string
    sql: ${TABLE}."ASSET_RENTAL_MARKET_ID" ;;
  }
  dimension: asset_market_coalesce { #adding this for easier joins in places we normally would coalesce(rental,inventory)
    type: string
    sql: iff(${asset_rental_market_id}='-1',${asset_inventory_market_id},${asset_rental_market_id});;
  }
  dimension: asset_rental_market_key {
    type: string
    sql: ${TABLE}."ASSET_RENTAL_MARKET_KEY" ;;
  }
  dimension: asset_serial_number {
    type: string
    sql: ${TABLE}."ASSET_SERIAL_NUMBER" ;;
  }
  dimension: asset_source {
    type: string
    sql: ${TABLE}."ASSET_SOURCE" ;;
  }
  dimension: asset_subsidy_value {
    type: number
    sql: ${TABLE}."ASSET_SUBSIDY_VALUE" ;;
  }
  dimension: asset_underperforming_flag {
    type: yesno
    sql: ${TABLE}."ASSET_UNDERPERFORMING_FLAG" ;;
  }
  dimension: asset_vin {
    type: string
    sql: ${TABLE}."ASSET_VIN" ;;
  }
  dimension: asset_year {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_YEAR" ;;
  }
  # Adding this for residual value forecasting joining
  dimension: asset_age_from_purchase_in_months {
    type: number
    sql: DATEDIFF(MONTH, ${asset_purchase_date}, ${asset_recordtimestamp_date});;
  }
  dimension: equipment_class_id {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: equipment_class_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_KEY" ;;
  }
  measure: count {
    type: count
    drill_fields: [asset_equipment_category_name, asset_equipment_subcategory_name, asset_equipment_model_name, asset_equipment_class_name]
  }
  measure: total_oec {
    value_format_name: usd
    type: sum
    sql: ${asset_current_oec} ;;
    drill_fields: [
                  asset_id,
                  asset_equipment_category_name,
                  equipment_class_id,
                  oec_asset.vendor_name,
                  top_vendor_mapping.vendor_name,
                  top_vendor_mapping.mapped_vendor_name
                  ]
  }
}

view: asset_scoring {
  derived_table: {
    sql:
-- Query Rewritten to use asset_most_recent_on_rent_date rather than asset_inventory_status to determine last rental date
SELECT
    a.asset_id,
    a.asset_serial_number AS serial_number,
    a.asset_year AS year,
    a.asset_equipment_make AS make,
    a.asset_equipment_model_name AS model,
    market.MARKET_ID,
    market.MARKET_NAME AS market,
    CASE
        WHEN a.asset_first_rental_start_date > '2015-01-01'
        THEN DATEDIFF('MONTH', a.asset_first_rental_start_date, CURRENT_DATE) / 12.0
    END AS asset_age_years,
    CASE
        WHEN a.asset_first_rental_start_date > '2015-01-01'
        THEN DATEDIFF('MONTH', a.asset_first_rental_start_date, CURRENT_DATE)
    END AS asset_age_month,
    a.asset_hours,
    a.asset_current_oec AS oec,
    a.asset_current_net_book_value AS nbv,
    coalesce(a.asset_current_net_book_value, fev.estimated_valuation_number) AS combined_valuation,
/*
    CASE
        WHEN coalesce(combined_valuation, 0) < 0
            THEN coalesce(anbv.oec, 0) * 0.10
        WHEN COALESCE(combined_valuation, 0) >= 100000
          THEN COALESCE(combined_valuation, 0) * 0.50

        WHEN COALESCE(combined_valuation, 0) >= 50000 AND COALESCE(combined_valuation, 0) < 100000
            THEN CASE
              WHEN COALESCE(asset_age_month,999) <= 36
                  THEN COALESCE(combined_valuation, 0) * 0.35
              WHEN COALESCE(asset_age_month,999) > 84
                  THEN COALESCE(combined_valuation, 0) * 0.25
              ELSE COALESCE(combined_valuation, 0) * 0.30
              END
          WHEN COALESCE(combined_valuation, 0) >= 20000 AND COALESCE(combined_valuation, 0) < 50000
              THEN CASE
                  WHEN COALESCE(asset_age_month,999) <= 84
                      THEN COALESCE(combined_valuation, 0) * 0.30
                  ELSE COALESCE(combined_valuation, 0) * 0.25
                  END
          ELSE COALESCE(combined_valuation, 0) * 0.20
    END as max_repair_threshold,
*/
    iff(coalesce(combined_valuation, 0) < 0,
      coalesce(anbv.oec, 0) * 0.10,

      iff(coalesce(combined_valuation, 0) >= 100000,
        coalesce(combined_valuation, 0) * 0.50,

        iff(coalesce(combined_valuation, 0) >= 50000
           AND coalesce(combined_valuation, 0) < 100000,
          iff(coalesce(asset_age_month, 999) <= 36,
            coalesce(combined_valuation, 0) * 0.35,
            iff(coalesce(asset_age_month, 999) > 84,
              coalesce(combined_valuation, 0) * 0.25,
              coalesce(combined_valuation, 0) * 0.30
            )
          ),

          iff(coalesce(combined_valuation, 0) >= 20000
             AND coalesce(combined_valuation, 0) < 50000,
            iff(coalesce(asset_age_month, 999) <= 84,
              coalesce(combined_valuation, 0) * 0.30,
              coalesce(combined_valuation, 0) * 0.25
            ),

            coalesce(combined_valuation, 0) * 0.20
          )
        )
      )
    ) AS max_repair_threshold,
    a.asset_most_recent_on_rent_date,
    -- Days since last rental
    CASE
        WHEN a.asset_most_recent_on_rent_date IS NULL THEN NULL
        WHEN a.asset_most_recent_on_rent_date > CURRENT_DATE THEN 0
        ELSE GREATEST(DATEDIFF('day', a.asset_most_recent_on_rent_date::DATE, CURRENT_DATE), 0)
    END AS days_since_last_rental,
    -- Score using most recent on-rent date
    LEAST(GREATEST(
        ((CASE
            WHEN a.asset_first_rental_start_date > '2015-01-01'
            THEN DATEDIFF('MONTH', a.asset_first_rental_start_date, CURRENT_DATE) / 12.0 / 10
            ELSE 0
         END) * 25)
         + ((a.asset_hours / 6000) * 25)
         + ((1 - (a.asset_current_net_book_value / NULLIFZERO(a.asset_current_oec))) * 25)
         + (((0.015 * a.asset_current_oec / 30)
             * GREATEST(DATEDIFF('day', a.asset_most_recent_on_rent_date::DATE, CURRENT_DATE), 0)
             / 50000) * 25),
    0), 100) AS score
FROM FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT AS a
LEFT JOIN FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT market
    ON a.asset_rental_market_id = market.MARKET_ID
LEFT JOIN FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT dc
    ON dc.company_key = a.asset_company_key
   AND dc.company_is_equipmentshare_company
LEFT JOIN ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS vpp
    ON vpp.asset_id = a.asset_id
   AND vpp.end_date IS NULL
LEFT JOIN FLEET_OPTIMIZATION.GOLD.fact_estimated_valuation fev
    ON fev.asset_key = a.asset_key
      AND year(fev.date_month_end) = year(current_date())
      AND month(fev.date_month_end) = month(current_date())
LEFT JOIN ANALYTICS.DEBT.ASSET_NBV_ALL_OWNERS anbv
    ON a.asset_id = anbv.asset_id
WHERE
    COALESCE(dc.company_id, vpp.asset_id) IS NOT NULL
    AND asset_most_recent_on_rent_date != '0001-01-01';;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.asset_id ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}.serial_number  ;;
  }
  dimension: year {
    type: number
    value_format_name: id
    sql: ${TABLE}.year ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}.make  ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }
  dimension: max_repair_threshold {
    type: number
    value_format_name: usd
    sql: ${TABLE}.max_repair_threshold ;;
  }
  dimension: score {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.score ;;
  }
  dimension: age {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.asset_age_years ;;
  }
  dimension: asset_hours {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.asset_hours ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id  ;;
  }
  dimension: market {
    type: string
    sql: ${TABLE}.market  ;;
  }
  dimension: oec {
    type: number
    value_format_name: usd
    sql: ${TABLE}.oec ;;
  }
  dimension: nbv {
    type: number
    value_format_name: usd
    sql: ${TABLE}.nbv ;;
  }
  dimension: days_since_last_rental {
    type:  number
    sql: ${TABLE}.days_since_last_rental;;
  }
  dimension: asset_most_recent_on_rent_date {
    type:  number
    sql: ${TABLE}.asset_most_recent_on_rent_date;;
  }
}

view: accumulated_depreciation_since_last_rental {
  derived_table: {
    sql:
      select a.asset_id,
               a.days_since_last_rental,
               (a.days_since_last_rental * ((0.015 / (365 / 12)) * aa.oec)) as accumulated_depreciation_since_last_rental
        from ${asset_scoring.SQL_TABLE_NAME} AS a
        join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
          on aa.asset_id = a.asset_id;;
  }
    dimension:  asset_id{
      type: number
      value_format_name: id
      primary_key: yes
      sql: ${TABLE}.asset_id;;
    }
    dimension:  days_since_last_rental{
      type: number
      sql: ${TABLE}.days_since_last_rental;;
    }
    dimension:  accumulated_depreciation_since_last_rental{
      type: number
      value_format_name: usd
      sql: ${TABLE}.accumulated_depreciation_since_last_rental ;;
    }
  }

view: expected_lost_revenue {
  sql_table_name: ANALYTICS.SERVICE.ESTIMATED_LOST_REVENUE;;

  dimension: work_order_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.work_order_id ;;
  }

  dimension :  asset_most_recent_on_rent_date {
    type:  date
    sql: ${TABLE}.asset_most_recent_on_rent_date ;;
  }

  dimension:  market_id {
    type:  number
    value_format_name: id
    sql:  ${TABLE}.market_id ;;
  }

  dimension: asset_class {
    type:  string
    value_format_name: id
    sql:  ${TABLE}.asset_class ;;
  }

  dimension: days_since_last_rental {
    type: number
    sql:  ${TABLE}.days_since_last_rental ;;
  }

  dimension: avg_daily_revenue_per_asset {
    type:  number
    value_format_name: usd_0
    sql:  ${TABLE}.avg_daily_revenue_per_asset ;;
  }

  dimension: district_class_expected_lost_revenue {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.district_class_expected_lost_revenue ;;
  }

  dimension: rank {
    type: number
    value_format_name: id
    sql: ${TABLE}.rank ;;
  }
}


view: market_service_oec {
  derived_table: {
    sql:
select --concat(dm.market_id, da.asset_equipment_make_id, da.asset_equipment_class_name) as primary_key
    dm.market_id
    --, da.asset_equipment_make_id
    --, da.asset_equipment_class_name
    , count(da.asset_id) as asset_count
    , sum(da.asset_current_oec) as oec
from FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT da
join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
    on dm.market_key = iff(da.asset_maintenance_service_provider_market_id <> -1, da.asset_maintenance_service_provider_market_key, da.asset_rental_market_key)
          and dm.reporting_market
          and dm.market_company_id in (select company_id from FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT where COMPANY_IS_EQUIPMENTSHARE_COMPANY)
group by 1;;
  }

  # dimension: primary_key {
  #   type: string
  #   primary_key: yes
  #   sql: ${TABLE}.primary_key ;;
  # }
  dimension: market_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.market_id ;;
  }
  # dimension: asset_equipment_make_id {
  #   type: number
  #   value_format_name: id
  #   sql: ${TABLE}.asset_equipment_make_id ;;
  # }
  # dimension: asset_equipment_class_name {
  #   type: string
  #   sql: ${TABLE}.asset_equipment_class_name ;;
  # }
  measure: asset_count {
    type: sum_distinct
    sql_distinct_key: ${market_id};;
    sql: ${TABLE}.asset_count ;;
  }
  measure: oec {
    type: sum_distinct
    sql_distinct_key: ${market_id} ;;
    value_format_name: usd_0
    sql: ${TABLE}.oec ;;
  }
}
