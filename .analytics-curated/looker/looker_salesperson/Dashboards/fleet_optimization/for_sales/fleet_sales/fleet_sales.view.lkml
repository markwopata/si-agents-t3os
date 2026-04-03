view: fleet_sales {
  derived_table: {
    sql: select
      afs.invoice_line_details_key
    , dates.dt_date             as sales_date
    , afs.sales_amount
    , users.user_id             as salesperson_id
    , users.user_full_name      as salesperson_full_name
    , assets.asset_id
    , assets.asset_equipment_make
    , assets.asset_equipment_model_name
    , assets.asset_description
    , assets.asset_oem_deal_flag
    , assets.asset_own_flag
    , markets.market_id as market_id
    , markets.market_name as market_name
    , markets.market_region_name as market_region_name
    , markets.market_region as market_region
    , markets.market_district as market_district
    , types.sales_type
    , assets.asset_current_oec as oec_dafo
    -- , a4on.asset4000_original_cost as oec_4k
    -- , a4on.asset4000_net_book_value as nbv_4k
from fleet_optimization.gold.all_fleet_sales afs
inner join fleet_optimization.gold.dim_dates_fleet_opt dates
    on afs.date_key_billing_approved_date = dates.dt_key
inner join fleet_optimization.gold.dim_users_fleet_opt users
    on afs.user_key = users.user_key
inner join fleet_optimization.gold.dim_assets_fleet_opt assets
    on afs.asset_key = assets.asset_key
inner join fleet_optimization.gold.dim_markets_fleet_opt markets
    on afs.market_key = markets.market_key
inner join fleet_optimization.gold.dim_line_items_fleet_opt items
    on afs.line_item_key = items.line_item_key
inner join fleet_optimization.gold.seed_equipment_sales_line_item_types types
    on items.line_item_type_id = types.line_item_type_id
-- left join analytics.intacct_models.asset4000_oec_nbv a4on
--     on assets.asset_id = a4on.admin_asset_id
-- where a4on.depreciation_date in (select max(depreciation_date) from analytics.intacct_models.asset4000_oec_nbv a4on)
  ;;
  }

  dimension: sales_date  {
    type: date
    sql: ${TABLE}."SALES_DATE" ;;
  }

  dimension: sales_amount {
    type: number
    sql: ${TABLE}."SALES_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: salesperson_id {
    type: number
    sql: ${TABLE}."SALESPERSON_ID" ;;
    value_format_name: id
  }

  dimension: salesperson_full_name {
    type: string
    sql: ${TABLE}."SALESPERSON_FULL_NAME" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: make {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MODEL_NAME" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."ASSET_DESCRIPTION"  ;;
  }

  dimension: oem_deal_flag {
    type: yesno
    sql: ${TABLE}."ASSET_OEM_DEAL_FLAG" ;;
  }

  dimension: own_flag {
    type: yesno
    sql: ${TABLE}."ASSET_OWN_FLAG";;
  }

  dimension: subsidy_deal_flag {
    type: string
    sql: case
                    when ${make} ilike '%wacker%' then 'Yes'
                    when ${make} ilike '%sany%'
                        and (${model} ilike '%SY135%'
                              or ${model} ilike '%SY155%'
                              or ${model} ilike '%SY215%'
                              or ${model} ilike '%SY225%'
                              or ${model} ilike '%SY235%'
                              or ${model} ilike '%SY265%'
                              or ${model} ilike '%SY365%'
                              or ${model} ilike '%SY500%')
                    then 'Yes'
                    else 'No'
                    end ;;
  }

  dimension: subsidy {
    type: number
    sql: case when ${make} ilike '%wacker%' then 10000
                when (${make} ilike '%SANY%' and ${model} ilike '%SY135%') then 11500
                when (${make} ilike '%SANY%' and ${model} ilike '%SY155%') then 11500
                when (${make} ilike '%SANY%' and ${model} ilike '%SY215%') then 17000
                when (${make} ilike '%SANY%' and ${model} ilike '%SY225%') then 17000
                when (${make} ilike '%SANY%' and ${model} ilike '%SY235%') then 17000
                when (${make} ilike '%SANY%' and ${model} ilike '%SY265%') then 23000
                when (${make} ilike '%SANY%' and ${model} ilike '%SY365%') then 28000
                when (${make} ilike '%SANY%' and ${model} ilike '%SY500%') then 35000
                else 0
           end;;
    value_format_name: usd
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_region_name {
    type: string
    sql: ${TABLE}."MARKET_REGION_NAME" ;;
  }

  dimension: market_region {
    type: string
    sql: ${TABLE}."MARKET_REGION" ;;
  }

  dimension: market_district {
    type: string
    sql: ${TABLE}."MARKET_DISTRICT" ;;
  }

  dimension: sales_type {
    type: string
    sql: ${TABLE}."SALES_TYPE" ;;
  }

  dimension: oec_dafo {
    type: number
    sql: ${TABLE}."OEC_DAFO" ;;
    value_format_name: usd
  }

  # dimension: oec_4k {
  #   type: number
  #   sql: ${TABLE}."OEC_4K" ;;
  #   value_format_name: usd
  # }

  # dimension: nbv_4k {
  #   type: number
  #   sql: ${TABLE}."NBV_4K" ;;
  # }

  measure: row_count {
    type: count
  }

  measure: total_sales {
    type: sum
    sql:${sales_amount}  ;;
    value_format_name: usd
  }

  measure: total_used_sales {
    type: sum
    sql: ${sales_amount} ;;
    filters: [sales_type: "used"]
    value_format_name: usd
  }

  measure: total_new_sales {
    type: sum
    sql: ${sales_amount} ;;
    filters: [sales_type: "new"]
    value_format_name: usd
  }

  measure: total_new_dealership_sales {
    type: sum
    sql: ${sales_amount} ;;
    filters: [sales_type: "new dealership"]
    value_format_name: usd
  }

  measure: total_subsidy {
    type: sum
    sql: ${subsidy} ;;
    value_format_name: usd
  }

  measure: total_used_subsidy {
    type: sum
    sql: ${subsidy} ;;
    filters: [sales_type: "used"]
    value_format_name: usd
  }

  measure: total_new_subsidy {
    type: sum
    sql: ${subsidy} ;;
    filters: [sales_type: "new"]
    value_format_name: usd
  }

  measure: total_new_dealership_subsidy {
    type: sum
    sql: ${subsidy} ;;
    filters: [sales_type: "new dealership"]
    value_format_name: usd
  }

  measure: total_oec {
    type: sum
    sql: ${oec_dafo} ;;
    value_format_name: usd
  }

  measure: total_used_oec {
    type: sum
    sql: ${oec_dafo} ;;
    filters: [sales_type: "used"]
    value_format_name: usd
  }

  measure: total_new_oec {
    type: sum
    sql: ${oec_dafo} ;;
    filters: [sales_type: "new"]
    value_format_name: usd
  }

  measure: total_new_dealership_oec {
    type: sum
    sql: ${oec_dafo} ;;
    filters: [sales_type: "new dealership"]
    value_format_name: usd
  }

  # measure: total_nbv {
  #   type: sum
  #   sql: ${nbv_4k} ;;
  #   value_format_name: usd
  # }

  # measure: total_used_nbv {
  #   type: sum
  #   sql: ${nbv_4k} ;;
  #   filters: [sales_type: "used"]
  #   value_format_name: usd
  # }

  # measure: total_new_nbv {
  #   type: sum
  #   sql: ${nbv_4k} ;;
  #   filters: [sales_type: "new"]
  #   value_format_name: usd
  # }

  # measure: total_new_dealership_nbv {
  #   type: sum
  #   sql: ${nbv_4k} ;;
  #   filters: [sales_type: "new"]
  #   value_format_name: usd
  # }
}
