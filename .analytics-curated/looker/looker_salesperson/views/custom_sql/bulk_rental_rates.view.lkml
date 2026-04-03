view: bulk_rental_rates {
  derived_table: {
    sql:
  with all_rates as (select p.PART_ID,
                          p.PRODUCT_CLASS_ID,
                          pc.CAT_CLASS,
                          pc.CATEGORY_NAME,
                          pc.CLASSIFICATION,
                          br.branch_id,
                          mrx.MARKET_NAME,
                          mrx.DISTRICT,
                          mrx.REGION_NAME,
                          br.price_per_month,
                          br.price_per_week,
                          br.price_per_day,
                          br.price_per_hour,
                          br.rate_type_id
                   from BULK_RATES.public.bulk_rates br
                            join ES_WAREHOUSE.INVENTORY.PRODUCT_CLASSES pc on br.cat_class = pc.CAT_CLASS
                            join ES_WAREHOUSE.INVENTORY.PARTS p on pc.PRODUCT_CLASS_ID = p.PRODUCT_CLASS_ID
                            left join MARKET_REGION_XWALK mrx on br.branch_id = mrx.MARKET_ID),
     online as (select PART_ID,
                       PRODUCT_CLASS_ID,
                       CAT_CLASS,
                       CATEGORY_NAME,
                       CLASSIFICATION,
                       branch_id,
                       MARKET_NAME,
                       DISTRICT,
                       REGION_NAME,
                       price_per_month as month_online,
                       price_per_week  as week_online,
                       price_per_day   as day_online,
                       price_per_hour  as hour_online
                from all_rates
                where rate_type_id = 1),
     bench as (select PART_ID,
                      PRODUCT_CLASS_ID,
                      CAT_CLASS,
                      CATEGORY_NAME,
                      CLASSIFICATION,
                      branch_id,
                      MARKET_NAME,
                      DISTRICT,
                      REGION_NAME,
                      price_per_month as month_bench,
                      price_per_week  as week_bench,
                      price_per_day   as day_bench,
                      price_per_hour  as hour_bench
               from all_rates
               where rate_type_id = 2)
select b.*, o.month_online, o.week_online, o.day_online, o.hour_online
from bench b
         join online o on b.branch_id = o.branch_id and b.PART_ID = o.PART_ID
    ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: product_class_id {
    type: number
    sql: ${TABLE}."PRODUCT_CLASS_ID" ;;
  }

  dimension: cat_class {
    type: string
    sql: ${TABLE}."CAT_CLASS" ;;
  }

  dimension: category_name {
    type: string
    sql: ${TABLE}."CATEGORY_NAME" ;;
  }

  dimension: classification {
    type: string
    sql: ${TABLE}."CLASSIFICATION" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: month_bench {
    type: number
    sql: ${TABLE}."MONTH_BENCH" ;;
  }

  dimension: week_bench {
    type: number
    sql: ${TABLE}."WEEK_BENCH" ;;
  }

  dimension: day_bench {
    type: number
    sql: ${TABLE}."DAY_BENCH" ;;
  }

  dimension: hour_bench {
    type: number
    sql: ${TABLE}."HOUR_BENCH" ;;
  }

  dimension: month_online {
    type: number
    sql: ${TABLE}."MONTH_ONLINE" ;;
  }

  dimension: week_online {
    type: number
    sql: ${TABLE}."WEEK_ONLINE" ;;
  }

  dimension: day_online {
    type: number
    sql: ${TABLE}."DAY_ONLINE" ;;
  }

  dimension: hour_online {
    type: number
    sql: ${TABLE}."HOUR_ONLINE" ;;
  }

  dimension: benchmark_rates {
    type: string
    sql: concat('$', ${day_bench}, ' / $', ${week_bench}, ' / $', ${month_bench}) ;;
  }

  dimension: online_rates {
    type: string
    sql: concat('$', ${day_online}, ' / $', ${week_online}, ' / $', ${month_online}) ;;
  }
}
