view: retail_asset_inventory {
  derived_table: {
    sql:
      select (case when rm.retail_territory is not null then rm.retail_territory else 'Other' end) as retail_territory
     , m.region_name
     , m.district
     , iah.service_branch_id as market_id
     , iah.service_branch_name as market_name
     , iah.asset_id
     , iah.month_end_date::date as month
     , iah.asset_company_id
     , c.name as company_name
     , (case when c.name = 'IES - Fleet Trade In' then 'Yes' else 'No' end) as trade_in_asset
     , iah.oec
     , 1 as asset_count
     , (case
         when iah.category ilike '%attachment%' then 'Attachment'
         else 'Main Mover'
        end) as asset_type
     , iah.make
     , iah.model
     , iah.year
     , iah.category as asset_category
     , iah.equipment_class as asset_class
     , iah.finance_status
 from analytics.assets.int_asset_historical iah
 join es_warehouse.public.companies c on iah.asset_company_id = c.company_id
 left join analytics.branch_earnings.market m on iah.service_branch_id = m.child_market_id
 left join analytics.dbt_seeds.seed_retail_market_map rm on m.market_id = rm.market_id
 where iah.month_end_date::date <= date_trunc(month,current_date)
  and c.name ilike 'ies%'
        ;;
    }

  dimension: retail_territory {
    label: "Retail Territory"
    type: string
    sql: ${TABLE}."RETAIL_TERRITORY" ;;
  }

  dimension: region_name {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    label: "MarketID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: asset_id {
    label: "AssetID"
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: month {
    type: date
    sql: ${TABLE}."MONTH" ;;
  }

  dimension_group: month_year {
    type: time
    timeframes: [raw, month, year]
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: asset_company_id {
    label: "CompanyID"
    type: string
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }

  dimension: company_name {
    label: "Company"
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: trade_in_asset {
    label: "Trade-In Asset?"
    type: string
    sql: ${TABLE}."TRADE_IN_ASSET" ;;
  }

  measure: oec {
    label: "OEC"
    type: sum
    sql: ${TABLE}."OEC" ;;
  }

  measure: asset_count {
    label: "Asset Count"
    type: sum
    sql: ${TABLE}."ASSET_COUNT" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: asset_category {
    type: string
    sql: ${TABLE}."ASSET_CATEGORY" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }

}
