view: int_asset_historical {
  sql_table_name: "ANALYTICS"."ASSETS"."INT_ASSET_HISTORICAL" ;;

  dimension: _non_rental_oec_with_rental_revenue {
    type: number
    sql: ${TABLE}."_NON_RENTAL_OEC_WITH_RENTAL_REVENUE" ;;
  }
  dimension: _non_rental_revenue {
    type: number
    sql: ${TABLE}."_NON_RENTAL_REVENUE" ;;
  }
  dimension: asset_company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
    html: <a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._value }}/service/work-orders" target="new" style="color: #0063f3; text-decoration: underline;">
    {{ asset_id._value }}</a> ;;
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
    sql: CAST(${TABLE}."DAILY_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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
  dimension_group: month_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."MONTH_END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."OEC" ;;
  }
  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }
  dimension: owning_company_name {
    type: string
    sql: ${TABLE}."OWNING_COMPANY_NAME" ;;
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
  dimension: pk_asset_daily_timestamp_id {
    primary_key: yes
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
  dimension: rental_fleet_oec {
    type: number
    sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
  }
  measure: total_rental_fleet_oec {
    type: sum
    value_format_name: usd_0
    filters: [in_rental_fleet: "yes"]
    sql: ${rental_fleet_oec} ;;
    drill_fields: [asset_inventory_status
      , dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.asset_serial_number
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , rental_fleet_oec]
  }
  dimension: rental_fleet_units {
    type: number
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
  measure: sum_rental_revenue {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."RENTAL_REVENUE" ;;
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
  dimension: unavailable_oec {
    type: number
    sql: ${TABLE}."UNAVAILABLE_OEC" ;;
    }
  measure: sum_total_oec {
    type: sum
    value_format_name: usd_0
    sql: ${total_oec} ;;
  }
  measure:  total_unavailable_oec_sol {
    type: sum
    value_format_name: usd
    sql: ${unavailable_oec} ;;
  }
  measure: total_unavailable_oec {
    type: sum
    value_format_name: usd_0
    filters: [is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , total_unavailable_oec_drill
      , total_unavailable_oec_in_make_ready
      , total_unavailable_oec_in_needs_inspection
      , total_unavailable_oec_in_soft_down
      , total_unavailable_oec_in_hard_down]
  }
  measure: total_unavailable_oec_drill {
    type: sum
    label: "Total Unavailable Oec"
    value_format_name: usd_0
    filters: [is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.serial_number
      , category
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , asset_inventory_status
      , days_in_status
      , last_wo_update.update_type
      , asset_location.address
      , asset_location.map_link
      , oec]
  }
  measure: total_unavailable_oec_in_hard_down {
    type: sum
    value_format_name: usd_0
    filters: [asset_inventory_status: "Hard Down", is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.serial_number
      , category
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , asset_inventory_status
      , days_in_status
      , last_wo_update.update_type
      , asset_location.address
      , asset_location.map_link
      , oec]
  }
  measure: total_unavailable_oec_in_soft_down {
    type: sum
    value_format_name: usd_0
    filters: [asset_inventory_status: "Soft Down", is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.serial_number
      , category
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , asset_inventory_status
      , days_in_status
      , last_wo_update.update_type
      , asset_location.address
      , asset_location.map_link
      , oec]
  }
  measure: total_unavailable_oec_in_needs_inspection {
    type: sum
    value_format_name: usd_0
    filters: [asset_inventory_status: "Needs Inspection", is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.serial_number
      , category
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , asset_inventory_status
      , days_in_status
      , last_wo_update.update_type
      , asset_location.address
      , asset_location.map_link
      , oec]
  }
  measure: total_unavailable_oec_in_make_ready {
    type: sum
    value_format_name: usd_0
    filters: [asset_inventory_status: "Make Ready", is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.serial_number
      , category
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , asset_inventory_status
      , days_in_status
      , last_wo_update.update_type
      , asset_location.address
      , asset_location.map_link
      , oec]
  }
  measure: days_in_period {
    type: count_distinct
    sql: ${daily_timestamp_date} ;;
  }
  measure: avg_unavailable_oec {
    type: number
    value_format_name: usd_0
    sql: (${total_unavailable_oec} /  NULLIF(${days_in_period}, 0)) ;;
  }
  measure: avg_total_rental_oec {
    type: number
    value_format_name: usd_0
    sql: (${total_rental_fleet_oec} / ${days_in_period}) ;;
    drill_fields: [
      daily_timestamp_date,
      market_name,
      make,
      unavailable_asset_count,
      total_asset_count,
      unavailable_oec,
      total_oec,
      percent_unavailable_no_html
    ]
  }
  measure: avg_total_oec {
    type: number
    value_format_name: usd_0
    sql: ${sum_total_oec} / ${days_in_period} ;;
  }
  measure: percent_unavailable_sol {
    type: number
    value_format: "0.0\%"
    sql: SUM(${TABLE}."UNAVAILABLE_OEC") / NULLIFZERO(SUM(${TABLE}."RENTAL_FLEET_OEC"));;
  }
  measure: percent_unavailable {
    type: number
    value_format: "0.0\%"
    sql: (${total_unavailable_oec} / nullifzero(${total_rental_fleet_oec})) * 100 ;;
    html: {{percent_unavailable._rendered_value}} | {{avg_unavailable_oec._rendered_value}} Avg Unavailable OEC of {{avg_total_rental_oec._rendered_value}} Avg Total Rental Fleet OEC;;

  }
  measure: percent_unavailable_no_html {
    label: "Percent Unavailable"
    type: number
    value_format: "0.0\%"
    sql: (${total_unavailable_oec} / nullifzero(${total_rental_fleet_oec})) * 100 ;;
    drill_fields: [
                  daily_timestamp_date,
                  market_name,
                  make,
                  unavailable_asset_count,
                  total_asset_count,
                  unavailable_oec,
                  total_oec,
                  percent_unavailable_no_html
                  ]
  }
  dimension: unavailable_units {
    type: number
    sql: ${TABLE}."UNAVAILABLE_UNITS" ;;
  }
  dimension: units_on_rent {
    type: number
    sql: ${TABLE}."UNITS_ON_RENT" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  # measure: avg_asset_year {
  #   type: average
  #   sql: ${TABLE}."YEAR" ;;
  #   value_format_name: decimal_2
  # }
  measure: avg_asset_age {
    type: average
    # sql: ${daily_timestamp_year} - ${avg_asset_year};;
    sql: YEAR(CURRENT_DATE()) -  ${TABLE}."YEAR";;
    value_format_name: decimal_2
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }
  measure: total_asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
  }
  measure: unavailable_asset_count {
    type: count
    filters: [is_asset_unavailable: "yes"]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  rental_branch_name,
  inventory_branch_name,
  lender_name,
  market_name,
  service_branch_name,
  loan_name,
  payout_program_name,
  owning_company_name
  ]
  }
  measure: soft_hard_down_unavailable_oec {
    type: sum
    value_format_name: usd_0
    sql: iff(${asset_inventory_status} in ('Soft Down', 'Hard Down'), ${unavailable_oec}, 0) ;;
  }
  measure: avg_soft_hard_down_unavailable_oec {
    type: number
    value_format_name: usd_0
    sql: ${soft_hard_down_unavailable_oec} / ${days_in_period} ;;
  }
  measure: soft_hard_down_percent {
    type: number
    value_format_name: percent_1
    sql: ${avg_soft_hard_down_unavailable_oec} / ${total_rental_fleet_oec} ;;
  }
  dimension: days_in_status {
    type: number
    sql: ${TABLE}.days_in_status ;;
  }
}

view: vendor_int_asset_historical {
  derived_table: {
    sql:
select v.vendorid
    , v.vendor_name
    , v.mapped_vendor_name
    , v.vendor_type
    , a.*
from ${int_asset_historical.SQL_TABLE_NAME} a
join (
        select vendorid
            , vendor_name
            , mapped_vendor_name
            , vendor_type
            , iff(mapped_vendor_name <> 'Doosan / Bobcat', mapped_vendor_name, 'DOOSAN') as join1
            , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
        from "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
        where primary_vendor ilike 'yes' and mapped_vendor_name is not null
        ) v
    on upper(join1) = a.make or upper(join2) = a.make
;;
  }
  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${asset_id}::STRING, ${daily_timestamp_date}::STRING) ;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }
  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}.mapped_vendor_name ;;
  }
  dimension: vendor_type {
    type: string
    sql: ${TABLE}.vendor_type ;;
  }
  dimension: _non_rental_oec_with_rental_revenue {
    type: number
    sql: ${TABLE}."_NON_RENTAL_OEC_WITH_RENTAL_REVENUE" ;;
  }
  dimension: _non_rental_revenue {
    type: number
    sql: ${TABLE}."_NON_RENTAL_REVENUE" ;;
  }
  dimension: asset_company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
    html: <a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._value }}/service/work-orders" target="new" style="color: #0063f3; text-decoration: underline;">
      {{ asset_id._value }}</a> ;;
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
    sql: CAST(${TABLE}."DAILY_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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
  dimension_group: month_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."MONTH_END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."OEC" ;;
  }
  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }
  dimension: owning_company_name {
    type: string
    sql: ${TABLE}."OWNING_COMPANY_NAME" ;;
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
  dimension: rental_fleet_oec {
    type: number
    sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
  }
  measure: total_rental_fleet_oec {
    type: sum
    value_format_name: usd_0
    filters: [in_rental_fleet: "yes"]
    sql: ${rental_fleet_oec} ;;
    drill_fields: [asset_inventory_status
      , dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.asset_serial_number
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , rental_fleet_oec]
  }
  dimension: rental_fleet_units {
    type: number
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
  measure: sum_rental_revenue {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."RENTAL_REVENUE" ;;
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
  dimension: unavailable_oec {
    type: number
    sql: ${TABLE}."UNAVAILABLE_OEC" ;;
  }
  measure: sum_total_oec {
    type: sum
    value_format_name: usd_0
    sql: ${total_oec} ;;
  }
  measure: total_unavailable_oec {
    type: sum
    value_format_name: usd_0
    filters: [is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , total_unavailable_oec_drill
      , total_unavailable_oec_in_make_ready
      , total_unavailable_oec_in_needs_inspection
      , total_unavailable_oec_in_soft_down
      , total_unavailable_oec_in_hard_down]
  }
  measure: total_unavailable_oec_drill {
    type: sum
    label: "Total Unavailable Oec"
    value_format_name: usd_0
    filters: [is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.serial_number
      , category
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , asset_inventory_status
      , days_in_status
      , last_wo_update.update_type
      , asset_location.address
      , asset_location.map_link
      , oec]
  }
  measure: total_unavailable_oec_in_hard_down {
    type: sum
    value_format_name: usd_0
    filters: [asset_inventory_status: "Hard Down", is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.serial_number
      , category
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , asset_inventory_status
      , days_in_status
      , last_wo_update.update_type
      , asset_location.address
      , asset_location.map_link
      , oec]
  }
  measure: total_unavailable_oec_in_soft_down {
    type: sum
    value_format_name: usd_0
    filters: [asset_inventory_status: "Soft Down", is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.serial_number
      , category
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , asset_inventory_status
      , days_in_status
      , last_wo_update.update_type
      , asset_location.address
      , asset_location.map_link
      , oec]
  }
  measure: total_unavailable_oec_in_needs_inspection {
    type: sum
    value_format_name: usd_0
    filters: [asset_inventory_status: "Needs Inspection", is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.serial_number
      , category
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , asset_inventory_status
      , days_in_status
      , last_wo_update.update_type
      , asset_location.address
      , asset_location.map_link
      , oec]
  }
  measure: total_unavailable_oec_in_make_ready {
    type: sum
    value_format_name: usd_0
    filters: [asset_inventory_status: "Make Ready", is_asset_unavailable: "yes"]
    sql: ${unavailable_oec} ;;
    drill_fields: [dim_markets_fleet_opt.market_name
      , asset_id
      , dim_assets_fleet_opt.serial_number
      , category
      , equipment_class
      , make
      , model
      , asset_company_id
      , asset_company.company_name
      , asset_inventory_status
      , days_in_status
      , last_wo_update.update_type
      , asset_location.address
      , asset_location.map_link
      , oec]
  }
  measure: days_in_period {
    type: count_distinct
    sql: ${daily_timestamp_date} ;;
  }
  measure: avg_unavailable_oec {
    type: number
    value_format_name: usd_0
    sql: (${total_unavailable_oec} /  NULLIF(${days_in_period}, 0)) ;;
  }
  measure: avg_total_rental_oec {
    type: number
    value_format_name: usd_0
    sql: (${total_rental_fleet_oec} / ${days_in_period}) ;;
    drill_fields: [
      daily_timestamp_date,
      market_name,
      make,
      unavailable_asset_count,
      total_asset_count,
      unavailable_oec,
      total_oec,
      percent_unavailable_no_html
    ]
  }
  measure: avg_total_oec {
    type: number
    value_format_name: usd_0
    sql: ${sum_total_oec} / ${days_in_period} ;;
  }
  measure: percent_unavailable {
    type: number
    value_format: "0.0\%"
    sql: (${total_unavailable_oec} / nullifzero(${total_rental_fleet_oec})) * 100 ;;
    html: {{percent_unavailable._rendered_value}} | {{avg_unavailable_oec._rendered_value}} Avg Unavailable OEC of {{avg_total_rental_oec._rendered_value}} Avg Total Rental Fleet OEC;;

  }
  measure: percent_unavailable_no_html {
    label: "Percent Unavailable"
    type: number
    value_format: "0.0\%"
    sql: (${total_unavailable_oec} / nullifzero(${total_rental_fleet_oec})) * 100 ;;
    drill_fields: [
      daily_timestamp_date,
      market_name,
      make,
      unavailable_asset_count,
      total_asset_count,
      unavailable_oec,
      total_oec,
      percent_unavailable_no_html
    ]
  }
  dimension: unavailable_units {
    type: number
    sql: ${TABLE}."UNAVAILABLE_UNITS" ;;
  }
  dimension: units_on_rent {
    type: number
    sql: ${TABLE}."UNITS_ON_RENT" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }
  measure: total_asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
  }
  measure: unavailable_asset_count {
    type: count
    filters: [is_asset_unavailable: "yes"]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      rental_branch_name,
      inventory_branch_name,
      lender_name,
      market_name,
      service_branch_name,
      loan_name,
      payout_program_name,
      owning_company_name
    ]
  }
  measure: soft_hard_down_unavailable_oec {
    type: sum
    value_format_name: usd_0
    sql: iff(${asset_inventory_status} in ('Soft Down', 'Hard Down'), ${unavailable_oec}, 0) ;;
  }
  measure: avg_soft_hard_down_unavailable_oec {
    type: number
    value_format_name: usd_0
    sql: ${soft_hard_down_unavailable_oec} / ${days_in_period} ;;
  }
  measure: soft_hard_down_percent {
    type: number
    value_format_name: percent_1
    sql: ${avg_soft_hard_down_unavailable_oec} / ${total_rental_fleet_oec} ;;
  }
  dimension: days_in_status {
    type: number
    sql: ${TABLE}.days_in_status ;;
  }
  measure: count_hard_down {
    type: count
    filters: [asset_inventory_status: "Hard Down", days_in_status: "1"] #Only counting the first day it went hard down
    # sql: ${asset_id} ;; #Not counting distinct because it was requested to show if asset go hard down multiple times
  }
  measure: hard_down_oec {
    type: sum
    filters: [asset_inventory_status: "Hard Down"]
    sql: ${total_oec} ;;
  }
  dimension: days_in_month {
    type: number
    sql: datediff(day, date_trunc(month, ${daily_timestamp_date}::DATE), date_trunc(month, dateadd(month, 1, ${daily_timestamp_date}::DATE))) ;;
  }
  measure: monthly_hard_down_oec { #Aggregating across 3 months to compare to the aggregate total OEC from each of those months
    type: sum
    filters: [asset_inventory_status: "Hard Down"]
    value_format_name: usd_0
    sql: (${total_oec} / ${days_in_month}) ;;
  }
  measure: perc_oec_hard_down { #Daily average % of OEC hard down
    type: number
    value_format_name: percent_1
    sql: ${hard_down_oec} / nullifzero(${sum_total_oec}) ;;
  }
}

view: vendor_unavailable_score {
  derived_table: {
    sql:
with agg as (
    select v.vendorid
        , v.vendor_type
        , sum(iff(v.asset_inventory_status in ('Soft Down', 'Hard Down'), zeroifnull(v.unavailable_oec), 0)) unavailable_oec
        , sum(zeroifnull(v.rental_fleet_oec)) as rental_fleet_oec
    from ${vendor_int_asset_historical.SQL_TABLE_NAME} v
    where v.daily_timestamp::DATE >= dateadd(month, -12, date_trunc(month, current_date))
    group by 1, 2
)

select a.vendorid
    , (a.unavailable_oec / nullifzero(a.rental_fleet_oec)) as vendor_unavailable
    , sum(pa.unavailable_oec) / nullifzero(sum(pa.rental_fleet_oec)) as peers_unavailable
    , least(coalesce(peers_unavailable, 1), 0.06) as unavailable_target
    , case
        when vendor_unavailable = 0 then (1/14)
        when (unavailable_target / vendor_unavailable) * (1/14) > (1/14) then (1/14)
        else (unavailable_target / vendor_unavailable) * (1/14)
        end as unavailable_score
    , case
        when vendor_unavailable = 0 then 10
        when (unavailable_target / vendor_unavailable) * 10 > 10 then 10
        else (unavailable_target / vendor_unavailable) * 10
        end as unavailable_score10
from agg a
left join agg pa
    on pa.vendorid <> a.vendorid
        and pa.vendor_type = a.vendor_type
group by 1,2
    ;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: vendor_unavailable {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.vendor_unavailable ;;
  }
  dimension: peers_unavailable {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.peers_unavailable ;;
  }
  dimension: unavailable_target {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.unavailable_target ;;
  }
  dimension: unavailable_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.unavailable_score, 0) ;;
  }
  dimension: unavailable_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.unavailable_score10, 0) ;;
  }
}

# created new view because i needed a much larger grain than asset/historical
view: unavailable_by_year {
  derived_table: {
    sql:
      SELECT
        iah.market_id,
        YEAR(iah.daily_timestamp) AS year,
        AVG(iah.year) AS avg_asset_year,
        YEAR(iah.daily_timestamp) - avg_asset_year AS avg_asset_age,
        ROUND(SUM(rental_fleet_oec), 2) as sum_rental_fleet_oec,
        round(sum(unavailable_oec), 2) as sum_unavailable_oec,
        -- round(sum(unavailable_oec) / sum(rental_fleet_oec), 4) AS unavailable_oec_percent
      FROM analytics.assets.int_asset_historical iah
      WHERE iah.rental_fleet_oec > 0
      GROUP BY 1,2 ;;
  }
  dimension: market_year_key {
    primary_key: yes
    type: string
    sql: CONCAT(${market_id}, '-', ${year}) ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}.year ;;
  }
  # dimension_group: daily_timestamp {
  #   type: time
  #   timeframes: [raw, time, date, quarter, year]
  #   sql: CAST(${TABLE}."DAILY_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  # }
  dimension: avg_asset_year {
    type: number
    sql: ${TABLE}.avg_asset_year ;;
  }
  dimension: avg_asset_age {
    type: number
    sql: ${TABLE}.avg_asset_age ;;
  }
  measure: sum_rental_fleet_oec {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.sum_rental_fleet_oec ;;
  }
  measure: sum_unavailable_oec {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.sum_unavailable_oec ;;
  }
  measure: percent_unavailable_oec {
    type: number
    value_format: "0.0%"
    sql: ${unavailable_by_year.sum_unavailable_oec} / NULLIF(${unavailable_by_year.sum_rental_fleet_oec}, 0) ;;
  }
}
