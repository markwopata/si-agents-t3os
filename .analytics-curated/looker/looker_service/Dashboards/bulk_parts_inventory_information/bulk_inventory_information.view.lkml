
view: bulk_inventory_information {
  derived_table: {
    sql: select sp.part_id,
             pc.CATEGORY_NAME as bulk_sub_category,
             pc.CAT_CLASS as bulk_class_number,
             pc.CLASSIFICATION as bulk_class_description,
             xw.MARKET_ID,
             xw.MARKET_NAME,
             xw.DISTRICT,
             xw.REGION_NAME,
             sp.QUANTITY,
             sp.AVAILABLE_QUANTITY,
             online.PRICE_PER_HOUR as price_per_hour_online,
             concat('$', online.PRICE_PER_DAY, ' / ', '$', online.PRICE_PER_WEEK, ' / ', '$', online.PRICE_PER_MONTH) as online_rates,
             benchmark.PRICE_PER_HOUR as price_per_hour_benchmark,
             concat('$', benchmark.PRICE_PER_DAY, ' / ', '$', benchmark.PRICE_PER_WEEK, ' / ', '$', benchmark.PRICE_PER_MONTH) as benchmark_rates
      from ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
      left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il on sp.INVENTORY_LOCATION_ID = il.INVENTORY_LOCATION_ID
      left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw on il.BRANCH_ID = xw.MARKET_ID
      left join ES_WAREHOUSE.INVENTORY.PARTS p on sp.PART_ID = p.PART_ID
      join ES_WAREHOUSE.INVENTORY.PRODUCT_CLASSES pc on p.PRODUCT_CLASS_ID = pc.PRODUCT_CLASS_ID
      left join (select CAT_CLASS,
                        BRANCH_ID,
                        PRICE_PER_HOUR,
                        PRICE_PER_DAY,
                        PRICE_PER_WEEK,
                        PRICE_PER_MONTH
                 from BULK_RATES.PUBLIC.BULK_RATES
                 where RATE_TYPE_ID = 1) as online
                 on pc.CAT_CLASS = online.CAT_CLASS and online.BRANCH_ID = xw.MARKET_ID
      left join (select CAT_CLASS,
                        BRANCH_ID,
                        PRICE_PER_HOUR,
                        PRICE_PER_DAY,
                        PRICE_PER_WEEK,
                        PRICE_PER_MONTH
                 from BULK_RATES.PUBLIC.BULK_RATES
                 where RATE_TYPE_ID = 2) as benchmark
                 on pc.CAT_CLASS = benchmark.CAT_CLASS and benchmark.BRANCH_ID = xw.MARKET_ID;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: bulk_sub_category {
    type: string
    sql: ${TABLE}."BULK_SUB_CATEGORY" ;;
  }

  dimension: bulk_class_number {
    type: string
    sql: ${TABLE}."BULK_CLASS_NUMBER" ;;
  }

  dimension: bulk_class_description {
    type: string
    sql: ${TABLE}."BULK_CLASS_DESCRIPTION" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
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

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: available_quantity {
    type: number
    sql: ${TABLE}."AVAILABLE_QUANTITY" ;;
  }

  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
  }

  dimension: online_rates {
    label: "Online Rates (Day/Week/Month)"
    type: string
    sql: ${TABLE}."ONLINE_RATES" ;;
  }

  dimension: benchmark_rates {
    label: "Benchmark Rates (Day/Week/Month)"
    type: string
    sql: ${TABLE}."BENCHMARK_RATES" ;;
  }

  dimension: price_per_hour_online {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR_ONLINE" ;;
  }

  dimension: price_per_hour_benchmark {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR_BENCHMARK" ;;
  }

  measure: total_quantity {
    type: sum
    sql: ${quantity} ;;
    drill_fields: [detail*]
  }

  measure: total_available_quantity {
    type: sum
    sql: ${available_quantity} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
        part_id,
        bulk_sub_category,
        bulk_class_number,
        bulk_class_description,
        quantity,
        available_quantity
    ]
  }
}
