view: trending_store_to_store_transfers {
  derived_table: {
    sql:
      select pit.market_id as receiving_branch
        , il.branch_id as orig_branch
        , pit.transaction_id
        , pit.created_by_user_id
        , pit.date_completed
        , pit.root_part_id as part_id
        , pit.part_number
        , pit.root_part_description as part_description
        , pit.quantity
        , coalesce(wac_extended_amount, pit.quantity * pit.cost_per_item) as total_cost
      from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
      left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
          on il.inventory_location_id = pit.from_id
      where pit.date_cancelled is null
          and pit.transaction_type_id = 6 --store to store
          and pit.quantity > 0 --receiving store
          and pit.transaction_status ilike 'completed'
          and il.name not ilike '%trailer%'
          and pit.store_name not ilike '%trailer%'
          and il.name not ilike '%televan%'
          and pit.store_name not ilike '%televan%'
          and il.name not ilike '%truck%'
          and pit.store_name not ilike '%truck%'
          and pit.description not ilike '%bulk%';;
  }

  dimension: orig_branch {
    type: number
    value_format_name: id
    sql: ${TABLE}.orig_branch  ;;
  }
 dimension: created_by {
   type: number
  value_format_name: id
  sql: ${TABLE}.created_by_user_id ;;
 }
  dimension: receiving_branch {
    type: number
    value_format_name: id
    sql: ${TABLE}.receiving_branch  ;;
  }

  dimension: transaction_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.transaction_id  ;;
  }

  dimension_group: completed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.date_completed AS TIMESTAMP_NTZ) ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.part_id ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.part_number ;;
  }

  dimension: part_description {
    type: string
    sql: ${TABLE}.part_description  ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }

  measure: sum_of_quantity {
    type: sum
    sql: ${quantity} ;;
  }

  dimension: total_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_cost;;
  }

  measure: sum_of_total_cost {
    type: sum
    value_format_name: usd_0
    sql: ${total_cost} ;;
    html: {{sum_of_quantity._rendered_value}} Parts Transfered at {{sum_of_total_cost._rendered_value}}  ;;
    # drill_fields: [
    #   transaction_id
    #   , completed_date
    #   , market_region_xwalk.selected_hierarchy_dimension
    #   , part_number
    #   , part_description
    #   , quantity
    #   , total_cost
    #   , receiving_branch
    # ]
  }
}
