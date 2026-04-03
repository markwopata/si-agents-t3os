view: cost_by_provider {
  derived_table: {
    sql:
        select
        sp.store_part_id
        ,sp.part_id
        ,sp.store_id
        ,mrx.market_id
        ,sp.quantity
        ,coalesce(costs.cost, 0) as part_cost
        ,coalesce(costs.cost, 0) * sp.quantity as total_cost
        ,costs.date_created as cost_date
        ,p.provider_id
        ,pt.description
        ,p.part_number


        from es_warehouse.inventory.store_parts sp
        left join es_warehouse.inventory.store_part_costs costs on sp.store_part_id = costs.store_part_id
        left join es_warehouse.inventory.parts p on sp.part_id = p.part_id
        left join es_warehouse.inventory.part_types pt on pt.part_type_id = p.part_type_id
        left join es_warehouse.inventory.stores s on sp.store_id = s.store_id
        left join analytics.public.market_region_xwalk mrx on s.branch_id = mrx.market_id
         --most recent cost per Brad S
        where costs.date_archived is null
        ;;
  }

  dimension:  store_part_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: store_id {
    type: string
    sql: ${TABLE}."STORE_ID" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: part_cost {
    type: number
    sql: ${TABLE}."PART_COST" ;;
    value_format_name: usd
  }

  dimension: total_cost {
    type: number
    sql: ${TABLE}."TOTAL_COST" ;;
  }

  dimension: cost_date {
    type: date
    sql: ${TABLE}."COST_DATE" ;;
  }

  dimension: provider_id {
    type: number
    sql: ${TABLE}."PROVIDER_ID" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  measure: ttl_cost {
    label: "Total Cost"
    type: sum
    sql: ${total_cost} ;;
    value_format_name: usd
    drill_fields: [description, part_number, quantity, total_cost]
  }

  dimension: total_cost_sp {
    type: number
    sql: coalesce(${weighted_average_cost.weighted_average_cost}, ${part_cost}) * ${store_parts.quantity} ;;
  }

  measure: total_cost_store_parts {
    type: sum
    sql: ${total_cost_sp} ;;
    value_format_name: usd
  }
}
