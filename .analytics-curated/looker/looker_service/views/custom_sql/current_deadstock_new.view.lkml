view: current_deadstock_new {
  derived_table: {
    sql:
    SELECT
        ds.SNAP_DATE AS SNAP_REFERENCE,
        ds.PART_ID,
        sp.STORE_PART_ID,
        ds.PART_NUMBER,
        ds.DESCRIPTION,
        ds.PROVIDER,
        ds.BIN_LOCATION,
        ds.SUB_PART_NUMBERS AS SUB_PART_NUMBER,
        ds.SUB_PART_IDS,
        CASE
            WHEN ds.INV_HEALTH = 'Alive Sub' THEN 'Alive Sub'
            WHEN ds.SUB_PART_NUMBERS IS NOT NULL THEN 'Dead'
            ELSE 'Dead and No Known Sub'
        END AS SUB_FLAG_NAME,
        ds.INVENTORY_LOCATION_ID,
        ds.LOCATION_NAME,
        xw.MARKET_TYPE,
        COALESCE(ds.MARKET_ID, ma.MARKET_ID) AS THE_MARKET_ID,
        COALESCE(ds.MARKET_NAME, ma.NAME) AS THE_MARKET_NAME,
        COALESCE(xw._ID_DIST, ma.DISTRICT_ID) AS THE_DISTRICT_ID,
        COALESCE(xw.DISTRICT, d.NAME) AS THE_DISTRICT_NAME,
        COALESCE(xw.REGION, d.REGION_ID) AS THE_REGION_ID,
        COALESCE(xw.REGION_NAME, r.NAME) AS THE_REGION_NAME,
        ds.OG_LAST_CONSUMED,
        ds.OVERALL_LAST_CONSUMED,
        ds.TOTAL_IN_INVENTORY,
        ds.AVG_COST,
        ds.INV_DOLLARS AS TOTAL_DOLLARS_IN_INVENTORY,
        ds.DEAD_STOCK AS DEAD_STOCK_QUANTITY,
        ds.DEAD_STOCK AS DEADSTOCK_VALUE
    FROM ANALYTICS.PARTS_INVENTORY.DEADSTOCK_SNAPSHOT ds
    JOIN ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
      ON ds.PART_ID = sp.PART_ID
     AND ds.INVENTORY_LOCATION_ID = sp.STORE_ID
    LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
      ON ds.MARKET_ID = xw.MARKET_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS ma
      ON ds.MARKET_ID = ma.MARKET_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.DISTRICTS d
      ON ma.DISTRICT_ID = d.DISTRICT_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.REGIONS r
      ON d.REGION_ID = r.REGION_ID
    LEFT JOIN ANALYTICS.PARTS_INVENTORY.TELEMATICS_PART_IDS tpi
      ON ds.PART_ID = tpi.PART_ID
    LEFT JOIN ES_WAREHOUSE.INVENTORY.PARTS p
      ON ds.PART_ID = p.PART_ID
    WHERE ds.TOTAL_IN_INVENTORY <> 0
      AND ds.LOCATION_NAME NOT ILIKE '%tele%'
      AND tpi.PART_ID IS NULL
      AND p.PROVIDER_ID NOT IN (SELECT api.PROVIDER_ID
                                FROM ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PROVIDER_IDS api)
      AND ma.COMPANY_ID = 1854
      AND ds.INVENTORY_LOCATION_ID != 400
      AND ds.INV_HEALTH IN ('Dead', 'Dead and No Known Sub')
    ;;
  }

  dimension: snap_reference {
    type: date
    sql: ${TABLE}."SNAP_REFERENCE" ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: store_part_id {
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
    primary_key: yes
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: provider {
    type: string
    sql: ${TABLE}."PROVIDER" ;;
  }

  dimension: bin_location {
    type: string
    sql: ${TABLE}."BIN_LOCATION" ;;
  }

  dimension: sub_part_number {
    type: string
    sql: trim(${TABLE}."SUB_PART_NUMBERS") ;;
    skip_drill_filter: yes
  }

  dimension: sub_part_ids {
    type: string
    sql: ${TABLE}."SUB_PART_IDS" ;;
  }

  dimension: sub_flag_name {
    type: string
    sql: ${TABLE}."SUB_FLAG_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}.market_type ;;
  }

  dimension: inventory_location_id {
    type: number
    sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}."LOCATION_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."THE_MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."THE_MARKET_NAME" ;;
  }

  dimension: district_id {
    type: string
    sql: ${TABLE}."THE_DISTRICT_ID" ;;
  }

  dimension: district_name {
    type: string
    sql: ${TABLE}."THE_DISTRICT_NAME" ;;
  }

  dimension: region_id {
    type: string
    sql: ${TABLE}."THE_REGION_ID" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."THE_REGION_NAME" ;;
  }

  dimension: og_last_consumed {
    type: date
    sql: ${TABLE}."OG_LAST_CONSUMED" ;;
  }

  dimension: overall_last_consumed {
    type: date
    sql: iff(${og_last_consumed} <= coalesce(${TABLE}."OVERALL_LAST_CONSUMED", '1999-01-01'), ${TABLE}."OVERALL_LAST_CONSUMED", ${og_last_consumed})  ;;
  }

  dimension: total_in_inventory {
    type: number
    sql: ${TABLE}."TOTAL_IN_INVENTORY" ;;
  }

  dimension: avg_cost {
    type: number
    sql: ${TABLE}."AVG_COST" ;;
  }

  dimension: total_dollars_in_inventory {
    type: number
    sql: ${TABLE}."TOTAL_DOLLARS_IN_INVENTORY" ;;
  }

  dimension: dead_stock_quantity {
    type: number
    sql: ${TABLE}."DEAD_STOCK_QUANTITY" ;;
  }

  dimension: deadstock_value {
    type: number
    sql: ${TABLE}."DEADSTOCK_VALUE" ;;
  }

  dimension: selected_hierarchy_dimension {
    type: string
    # link: {label:"El ChuPARTcabra Dashboard"
    #   url:"https://equipmentshare.looker.com/dashboards/937?Market+Name=&District+Name=&Region+Name="}
    sql:{% if market_name._in_query %}
          ${store_name}
        {% elsif district_name._in_query %}
          ${market_name}
        {% elsif region_name._in_query %}
          ${district_name}
        {% else %}
          ${region_name}
        {% endif %};;
  }

  dimension: selected_hierarchy_dimension_inverted {
    type: string
    #   # link: {label:"El ChuPARTcabra Dashboard"
    #   #   url:"https://equipmentshare.looker.com/dashboards/937?Market+Name=&District+Name=&Region+Name="}
    sql:{% if region_name._in_query %}
          ${region_name}
        {% elsif district_name._in_query %}
          ${district_name}
        {% elsif market_name._in_query %}
          ${market_name}
        {% else %}
          null--${market_name}
        {% endif %};;
  }

  measure: total_dead_stock_quantity {
    type: sum
    sql: ${dead_stock_quantity} ;;
    filters: [sub_flag_name: "Dead, Dead and No Known Sub"]
  }

  measure: total_dead_stock_dollars {
    type: sum
    value_format_name: usd
    sql: ${deadstock_value} ;;
    filters: [sub_flag_name: "Dead, Dead and No Known Sub"]
  }

  measure: total_inventory_quantity {
    type: sum
    sql: ${total_in_inventory} ;;
  }

  measure: total_value {
    type: sum
    value_format_name: usd
    sql: ${total_dollars_in_inventory} ;;
  }

  measure: dead_stock_ratio {
    type: number
    value_format_name: percent_2
    sql: ${total_dead_stock_dollars} / ${total_value} ;;
    link: {
      label: "Current Dead Stock Inventory"
      url: "https://equipmentshare.looker.com/dashboards/1113?District+Name={{ _filters['deadstock.district_name'] | url_encode }}&Market+Name={{ _filters['deadstock.market_name'] | url_encode }}&Region+Name={{ _filters['deadstock.region_name'] | url_encode }}&Store+Name={{ _filters['deadstock.store_name'] | url_encode }}&Part+Number="
    }
  }

}
# part_id,
# provider,
# part_number,
# description,

view: market_wide_part_dead_stock {
  derived_table: {
    sql:
      select the_market_id
        , part_number
        , sum(zeroifnull(dead_stock_quantity)) as dead_quantity
        , sum(zeroifnull(deadstock_value)) as dead_value
      from ${current_deadstock.SQL_TABLE_NAME}
      group by 1, 2;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.the_market_id;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.part_number ;;
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${market_id}, ${part_number}) ;;
  }

  dimension: dead_stock_quantity {
    type: number
    sql: ${TABLE}.dead_quantity ;;
  }

  dimension: dead_stock_value {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.dead_value ;;
  }
}

view: company_wide_part_dead_stock {
  derived_table: {
    sql:
      select part_number
        , sum(zeroifnull(dead_stock_quantity)) as dead_quantity
        , sum(zeroifnull(deadstock_value)) as dead_value
      from ${current_deadstock.SQL_TABLE_NAME}
      group by 1;;
  }

  dimension: part_number {
    type: string
    primary_key: yes
    sql: ${TABLE}.part_number ;;
  }

  dimension: dead_stock_quantity {
    type: number
    sql: ${TABLE}.dead_quantity ;;
  }

  dimension: dead_stock_value {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.dead_value ;;
  }
}
