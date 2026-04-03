view: asset_category_utilization_metrics {
    derived_table: {
      sql:
with invoice_rental_rev as(
select asset_id
     , gl_date::date as gl_date
     , invoice_id
     , (case
         when rental_cheapest_period_hour_count = 1 then 'Hourly'
         when rental_cheapest_period_day_count = 1 then 'Daily'
         when rental_cheapest_period_week_count = 1 then 'Weekly'
         when rental_cheapest_period_four_week_count = 1 then 'Four Week'
         when rental_cheapest_period_month_count = 1 then 'Monthly'
        end) as rental_period
     , sum(amount) as rental_revenue
 from analytics.intacct_models.int_admin_invoice_and_credit_line_detail
 where is_rental_revenue = true
  and is_billing_approved = true
  and is_intercompany = false
 group by all)

, daily_rental_rev as(
select ld.asset_id
     , dd.date
     , ld.invoice_id
     , (case
         when ld.rental_cheapest_period_hour_count > 0 then 'Hourly'
         when ld.rental_cheapest_period_day_count > 0 then 'Daily'
         when ld.rental_cheapest_period_week_count > 0 then 'Weekly'
         when ld.rental_cheapest_period_four_week_count > 0 then 'Four Week'
         when ld.rental_cheapest_period_month_count > 0 then 'Monthly'
         else 'None'
        end) as rental_period
     , ld.amount/datediff(day,ld.invoice_cycle_start_date,ld.invoice_cycle_end_date) as daily_rental_revenue
 from analytics.branch_earnings.dim_date dd
 left join analytics.intacct_models.int_admin_invoice_and_credit_line_detail ld on dd.date >= ld.invoice_cycle_start_date::date
                                                                                 and dd.date < invoice_cycle_end_date::date
 where ld.asset_id is not null
  and ld.amount <> 0
  and ld.is_rental_revenue = true
  and ld.is_billing_approved = true
  and ld.is_intercompany = false)

, daily_data as(
select m.region_name
     , m.district
     , m.market_id
     , m.market_name
     , m.market_type
     , ah.asset_id
     , ah.daily_timestamp::date as date
     , ah.category as asset_category
     , ah.rental_fleet_units
     , ah.rental_fleet_oec
     , ah.unavailable_oec
     , ah.unavailable_units
     , ah.oec_on_rent
     , ah.units_on_rent
     , ah.pending_return_oec
     , ah.pending_return_units
     , r.invoice_id as invoice_id
     , coalesce(r.rental_revenue,0) as rental_revenue
     , dr.invoice_id as daily_invoice_id
     , coalesce(dr.daily_rental_revenue,0) as daily_rental_revenue
     , dr.rental_period
 from analytics.assets.int_asset_historical ah
 left join invoice_rental_rev r on ah.asset_id = r.asset_id and ah.daily_timestamp::date = r.gl_date
 left join daily_rental_rev dr on ah.asset_id = dr.asset_id and ah.daily_timestamp::date = dr.date
 join analytics.branch_earnings.market m on ah.market_id = m.child_market_id
 where ah.daily_timestamp::date between dateadd(month,-6,current_date) and current_date
  and coalesce(rental_fleet_oec,0) <> 0)

, max_date as(
select max(date) as max_date
 from daily_data)

, max_date_category_oec as(
select market_id
     , asset_category
     , sum(rental_fleet_oec) as category_rental_fleet_oec
 from daily_data
 where date = (select max_date from max_date)
 group by all)

, max_date_market_oec as(
select market_id
     , sum(rental_fleet_oec) as market_rental_fleet_oec
 from daily_data
 where date = (select max_date from max_date)
 group by all)

select dd.*
     , (case
         when dd.date = (select max_date from max_date) then 1
         else 0
        end) as max_date
     , a.asset_type
     , a.parent_category_name as parent_category
     , a.make
     , a.model
     , a.year
     , a.equipment_class
     , a.oec as current_oec
     , ais.asset_inventory_status
     , (case
         when dd.market_id = a.market_id then 1
         else 0
        end) as is_current_market
     , datediff('day',coalesce(least(a.last_rental_date,(select max_date from max_date)),a.purchase_date),(select max_date from max_date)) as days_since_last_rental
     , datediff('day',rsp.date_start,least((select max_date from max_date),rsp.date_end)) as days_in_market
     , datediff('day',ais.date_start,least((select max_date from max_date),ais.date_end)) as days_in_status
     , coalesce(co.category_rental_fleet_oec/nullif(mo.market_rental_fleet_oec,0),0) as category_pct_oec
 from daily_data dd
 join analytics.assets.int_assets a on dd.asset_id = a.asset_id
 left join es_warehouse.scd.scd_asset_rsp rsp on dd.asset_id = rsp.asset_id and rsp.current_flag = TRUE
 left join es_warehouse.scd.scd_asset_inventory_status ais on dd.asset_id = ais.asset_id and ais.current_flag = 1
 join max_date_category_oec co on dd.market_id = co.market_id and dd.asset_category = co.asset_category
 join max_date_market_oec mo on dd.market_id = mo.market_id
;;
    }

    parameter: asset_granularity {
      description: "Group data at varying levels of assetID granularity"
      allowed_value: {
        label: "Equipment Category"
        value: "equipment_category"
      }

      allowed_value: {
        label: "Equipment Category Class"
        value: "equipment_category_class"
      }
    }

    dimension: equipment_grouping {
      type: string
      label: "Equipment Type"
      sql: case
            when {% parameter asset_granularity %} = 'equipment_category' then ${equipment_category}
            when {% parameter asset_granularity %} = 'equipment_category_class' then ${equipment_category_class}
           end;;
    }

    parameter: geographic_granularity {
      description: "Group data at varying levels of geographic granularity"
      allowed_value: {
        label: "Region"
        value: "region_name"
      }

      allowed_value: {
        label: "District"
        value: "district"
      }

      allowed_value: {
        label: "Market"
        value: "market_name"
      }
    }

    dimension: geographic_grouping {
      type: string
      label: "Geographic Grain"
      sql: case
            when {% parameter geographic_granularity %} = 'region_name' then ${region_name}
            when {% parameter geographic_granularity %} = 'district' then ${district}
            when {% parameter geographic_granularity %} = 'market_name' then ${market_name}
           end;;
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

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

    dimension: asset_id {
      label: "AssetID"
      type: string
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension_group: date{
      type: time
      timeframes: [raw, date, week, month, quarter, year]
      sql: ${TABLE}."DATE" ;;
    }

    dimension: max_date {
      type: number
      sql: ${TABLE}."MAX_DATE" ;;
    }

    dimension: asset_inventory_status {
      type: string
      sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
    }

    dimension: days_in_status {
      type: string
      sql: ${TABLE}."DAYS_IN_STATUS" ;;
    }

    dimension: days_since_last_rental {
      type: string
      sql: ${TABLE}."DAYS_SINCE_LAST_RENTAL" ;;
    }

    dimension: asset_type {
      type: string
      sql: ${TABLE}."ASSET_TYPE" ;;
    }

  dimension: parent_category {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY" ;;
  }

    dimension: equipment_category {
      type: string
      sql: ${TABLE}."ASSET_CATEGORY" ;;
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

    dimension: equipment_category_class {
      type: string
      sql: ${TABLE}."EQUIPMENT_CLASS" ;;
    }

    dimension: equipment_oec{
      label: "Equipment OEC"
      type: number
      sql: ${TABLE}."CURRENT_OEC" ;;
    }

    dimension: days_in_market{
      label: "Days in Market"
      type: number
      sql: ${TABLE}."DAYS_IN_MARKET" ;;
    }

    dimension: is_current_market{
      type: number
      sql: ${TABLE}."IS_CURRENT_MARKET" ;;
    }

    dimension: rental_period {
      type: string
      sql: ${TABLE}."RENTAL_PERIOD" ;;
    }

    measure: asset_count {
      type: count
    }

    measure: rental_fleet_oec {
      label: "OEC"
      type: sum
      sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
    }

    measure: rental_revenue {
      label: "Invoiced Revenue"
      type: sum
      sql: ${TABLE}."RENTAL_REVENUE" ;;
    }

  measure: daily_rental_revenue {
    label: "Rental Revenue"
    type: sum
    sql: ${TABLE}."DAILY_RENTAL_REVENUE" ;;
  }

    measure: financial_utilization {
      type: number
      value_format_name: percent_2
      sql: (sum(${TABLE}."RENTAL_REVENUE")*365)/nullif(sum(${TABLE}."RENTAL_FLEET_OEC"),0);;
    }

    measure: oec_on_rent {
      type: sum
      sql: ${TABLE}."OEC_ON_RENT" ;;
    }

    measure: oec_on_rent_pct {
      label: "OEC On Rent %"
      type: number
      value_format_name: percent_2
      sql: sum(${TABLE}."OEC_ON_RENT")/nullif(sum(${TABLE}."RENTAL_FLEET_OEC"),0) ;;
    }

    measure: units_on_rent {
      label: "Days on Rent"
      type: sum
      sql: ${TABLE}."UNITS_ON_RENT" ;;
    }

  measure: avg_daily_rate {
    type: number
    value_format_name: decimal_2
    sql: ${daily_rental_revenue}/nullif(${units_on_rent},0) ;;
  }

    measure: rental_fleet_units {
      type: sum
      sql: ${TABLE}."RENTAL_FLEET_UNITS" ;;
    }

    measure: units_on_rent_pct {
      label: "Units on Rent %"
      type: number
      value_format_name: percent_2
      sql: sum(${TABLE}."UNITS_ON_RENT")/nullif(sum(${TABLE}."RENTAL_FLEET_UNITS"),0) ;;
    }

    dimension: category_pct_oec {
      label: "Current OEC as % of Total"
      type: number
      value_format_name: percent_2
      sql: ${TABLE}."CATEGORY_PCT_OEC" ;;
    }

    dimension: current {
      type: yesno
      sql: ${TABLE}."MAX_DATE" = 1 ;;
    }

    dimension: last_30_days {
      type: yesno
      sql: ${TABLE}."DATE" between dateadd('day',-30,current_date) and current_date ;;
    }

    dimension: last_60_days {
      type: yesno
      sql: ${TABLE}."DATE" between dateadd('day',-60,current_date) and current_date ;;
    }

    dimension: last_90_days {
      type: yesno
      sql: ${TABLE}."DATE" between dateadd('day',-90,current_date) and current_date ;;
    }

    measure: days_on_rent_last_30 {
      type: sum
      filters: [last_30_days: "Yes"]
      sql: ${TABLE}."UNITS_ON_RENT" ;;
    }

    measure: available_days_last_30 {
      type: sum
      filters: [last_30_days: "Yes"]
      sql: ${TABLE}."RENTAL_FLEET_UNITS" ;;
    }

    measure: time_utilization_last_30{
      type: number
      value_format_name: percent_2
      sql: ${days_on_rent_last_30}/nullif(${available_days_last_30},0) ;;
    }

    measure: days_on_rent_last_60 {
      type: sum
      filters: [last_60_days: "Yes"]
      sql: ${TABLE}."UNITS_ON_RENT" ;;
    }

    measure: available_days_last_60 {
      type: sum
      filters: [last_60_days: "Yes"]
      sql: ${TABLE}."RENTAL_FLEET_UNITS" ;;
    }

    measure: time_utilization_last_60{
      type: number
      value_format_name: percent_2
      sql: ${days_on_rent_last_60}/nullif(${available_days_last_60},0) ;;
    }

    measure: days_on_rent_last_90 {
      type: sum
      filters: [last_90_days: "Yes"]
      sql: ${TABLE}."UNITS_ON_RENT" ;;
    }

    measure: available_days_last_90 {
      type: sum
      filters: [last_90_days: "Yes"]
      sql: ${TABLE}."RENTAL_FLEET_UNITS" ;;
    }

    measure: time_utilization_last_90{
      type: number
      value_format_name: percent_2
      sql: ${days_on_rent_last_90}/nullif(${available_days_last_90},0) ;;
    }

    measure: revenue_last_30 {
      label: "Invoiced Revenue Last 30"
      type: sum
      value_format_name: usd
      filters: [last_30_days: "Yes"]
      sql: ${TABLE}."RENTAL_REVENUE" ;;
    }

    measure: revenue_last_60 {
      label: "Invoiced Revenue Last 60"
      type: sum
      value_format_name: usd
      filters: [last_60_days: "Yes"]
      sql: ${TABLE}."RENTAL_REVENUE" ;;
    }

    measure: revenue_last_90 {
      label: "Invoiced Revenue Last 90"
      type: sum
      value_format_name: usd
      filters: [last_90_days: "Yes"]
      sql: ${TABLE}."RENTAL_REVENUE" ;;
    }

  measure: oec_last_30 {
    type: sum
    value_format_name: usd
    filters: [last_30_days: "Yes"]
    sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
  }

  measure: oec_last_60 {
    type: sum
    value_format_name: usd
    filters: [last_60_days: "Yes"]
    sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
  }

  measure: oec_last_90 {
    type: sum
    value_format_name: usd
    filters: [last_90_days: "Yes"]
    sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
  }

  measure: oec_on_rent_last_30 {
    type: sum
    value_format_name: usd
    filters: [last_30_days: "Yes"]
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  measure: oec_on_rent_last_60 {
    type: sum
    value_format_name: usd
    filters: [last_60_days: "Yes"]
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  measure: oec_on_rent_last_90 {
    type: sum
    value_format_name: usd
    filters: [last_90_days: "Yes"]
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  measure: on_rent_oec_pct_last_30 {
    type: number
    value_format_name: percent_2
    sql: ${oec_on_rent_last_30}/nullif(${oec_last_30},0) ;;
  }

  measure: on_rent_oec_pct_last_60 {
    type: number
    value_format_name: percent_2
    sql: ${oec_on_rent_last_60}/nullif(${oec_last_60},0) ;;
  }

  measure: on_rent_oec_pct_last_90 {
    type: number
    value_format_name: percent_2
    sql: ${oec_on_rent_last_90}/nullif(${oec_last_90},0) ;;
  }

    measure: oec_current {
      label: "Current OEC"
      type: sum
      filters: [current: "Yes"]
      sql: ${TABLE}."RENTAL_FLEET_OEC" ;;
    }

    measure: asset_count_current {
      label: "Current Asset Count"
      type: sum
      filters: [current: "Yes"]
      sql: ${TABLE}."RENTAL_FLEET_UNITS" ;;
    }

  measure: on_rent_assets {
    label: "On Rent/Assigned Assets"
    type: sum
    filters: [current: "Yes"]
    sql: case when ${TABLE}."ASSET_INVENTORY_STATUS" in('On Rent','Pre-Delivered','Assigned','On RPO') then ${TABLE}."RENTAL_FLEET_UNITS" end;;
  }

  measure: available_assets {
    label: "Available Assets"
    type: sum
    filters: [current: "Yes"]
    sql: case when ${TABLE}."ASSET_INVENTORY_STATUS" in('Ready To Rent') then ${TABLE}."RENTAL_FLEET_UNITS" end;;
  }

  measure: unavailable_assets {
    label: "Unavailable Assets"
    type: sum
    filters: [current: "Yes"]
    sql: case when ${TABLE}."ASSET_INVENTORY_STATUS" in('Pending Return','Needs Inspection','Make Ready','Soft Down','Hard Down') then ${TABLE}."RENTAL_FLEET_UNITS" end;;
  }



  measure: daily_revenue_last_30 {
    label: "Rental Revenue Last 30"
    type: sum
    value_format_name: usd
    filters: [last_30_days: "Yes"]
    sql: ${TABLE}."DAILY_RENTAL_REVENUE" ;;
  }

  measure: daily_revenue_last_60 {
    label: "Rental Revenue Last 60"
    type: sum
    value_format_name: usd
    filters: [last_60_days: "Yes"]
    sql: ${TABLE}."DAILY_RENTAL_REVENUE" ;;
  }

  measure: daily_revenue_last_90 {
    label: "Rental Revenue Last 90"
    type: sum
    value_format_name: usd
    filters: [last_90_days: "Yes"]
    sql: ${TABLE}."DAILY_RENTAL_REVENUE" ;;
  }

    measure: avg_daily_rate_last_30{
      type: number
      value_format_name: decimal_2
      sql: ${daily_revenue_last_30}/nullif(${days_on_rent_last_30},0) ;;
    }

    measure: avg_daily_rate_last_60{
      type: number
      value_format_name: decimal_2
      sql: ${daily_revenue_last_60}/nullif(${days_on_rent_last_60},0) ;;
    }

    measure: avg_daily_rate_last_90{
      type: number
      value_format_name: decimal_2
      sql: ${daily_revenue_last_90}/nullif(${days_on_rent_last_90},0) ;;
    }

  measure: revenue_change_mom{
    label: "Revenue Change MoM"
    type: number
    value_format_name: decimal_2
    sql: ${daily_revenue_last_30} - (${daily_revenue_last_60} - ${daily_revenue_last_30}) ;;
  }

  measure: days_rented_change_mom{
    label: "Days Rented Change MoM"
    type: number
    value_format_name: decimal_2
    sql: ${days_on_rent_last_30} - (${days_on_rent_last_60} - ${days_on_rent_last_30}) ;;
  }

  measure: avg_daily_rate_change_mom{
    label: "Avg Daily Rate Change MoM"
    type: number
    value_format_name: decimal_2
    sql: (${daily_revenue_last_30}/nullif(${days_on_rent_last_30},0)) - ((${daily_revenue_last_60} - ${daily_revenue_last_30})/nullif(${days_on_rent_last_60} - ${days_on_rent_last_30},0));;
  }

  }
