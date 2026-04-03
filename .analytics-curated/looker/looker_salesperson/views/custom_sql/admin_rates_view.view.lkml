view: admin_rates_view {
#   # Or, you could make this view a derived table, like this:
  derived_table: {
    sql:
    with rates as (
    select branch_id,
           equipment_class_id,
           price_per_month,
           case when rate_type_id = 1 then 'Online' when rate_type_id = 2 then 'Benchmark' else 'Floor' end rate_type
    from es_warehouse.public.branch_rental_rates
    where active = true
),
     regions as (
         select distinct region, district, market_id branch_id, market_name
         from analytics.public.market_region_xwalk
         where district is not null
     ),
     categories as (
         select distinct equipment_class_id, category_id, CATEGORY
         from es_warehouse.public.assets_aggregate
         where CATEGORY is not null
     ),
     class_names as (
         select cl.equipment_class_id, cl.name equipment_class, cat.category
         from es_warehouse.public.equipment_classes cl
                  left join categories cat on cat.category_id = cl.category_id
         where cl.company_id = 1854
         group by cl.equipment_class_id, cl.name, cat.category
     ),
     floor as (
         select branch_id,
                equipment_class_id,
                price_per_month floor_rate
         from rates
         where rate_type = 'Floor'
     ),
     benchmark as (
         select branch_id,
                equipment_class_id,
                price_per_month benchmark_rate
         from rates
         where rate_type = 'Benchmark'
     ),
     online as (
         select branch_id,
                equipment_class_id,
                price_per_month online_rate
         from rates
         where rate_type = 'Online'
     )
select rg.region,
       rg.district,
       r.branch_id,
       rg.market_name,
       c.category,
       c.equipment_class_id,
       c.equipment_class,
       f.floor_rate,
       b.benchmark_rate,
       o.online_rate
from rates r
         left join regions rg on r.branch_id = rg.branch_id
         left join class_names c on c.equipment_class_id = r.equipment_class_id
         left join floor f on f.equipment_class_id = r.equipment_class_id and f.branch_id = r.branch_id
         left join benchmark b on b.equipment_class_id = r.equipment_class_id and b.branch_id = r.branch_id
         left join online o on o.equipment_class_id = r.equipment_class_id and o.branch_id = r.branch_id
where rg.MARKET_NAME is not null
      ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}.region ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }
  dimension: branch_id {
    type: string
    sql: ${TABLE}.branch_id ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }
  dimension: equipment_class_id {
    type: string
    sql: ${TABLE}.equipment_class_id ;;
  }
  dimension: equipment_class {
    type: string
    sql: ${TABLE}.equipment_class ;;
  }
  dimension: floor_rate {
    type: number
    sql: ${TABLE}.floor_rate ;;
    value_format_name: usd
  }
  dimension: benchmark_rate {
    type: number
    sql: ${TABLE}.benchmark_rate ;;
    value_format_name: usd
  }
  dimension: online_rate {
    type: number
    sql: ${TABLE}.online_rate ;;
    value_format_name: usd
  }
}
