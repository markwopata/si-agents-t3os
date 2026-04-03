include: "/views/custom_sql/total_inventory_per_store.view.lkml"
view: non_adjustment_transactions {
  derived_table: {
    sql:
    select pit.transaction_id
        , pit.transaction_type_id
        , pit.transaction_type
        , pit.transaction_item_id
        , pit.created_by_user_id
        , pit.created_by_username
        , m.market_name
        , pit.store_id
        , pit.store_name
        , pit.root_part_id as part_id
        , pit.part_number
        , pit.quantity
        , pit.work_order_id
        , pit.cost cost_per_item
        , pit.amount cost
        , po.purchase_order_number
        , pit.invoice_id
        , i.invoice_no
        , il.inventory_location_id as receiving_store_id
        , il.name as receiving_store_name
        , il.branch_id
        , pit.date_completed
        , iff(pit.date_completed >= dateadd(month, -6, date_trunc(month, current_date)), 1, 0) as last_6_months_flag
        , iff(pit.date_completed >= dateadd(month, -12, date_trunc(month, current_date)), 1, 0) as last_12_months_flag
        , iff(transaction_type_id = 6 and pit.quantity < 0, 'remove', 'keep') as remove
        , max(case when pit.transaction_type_id=21 then pit.date_completed end) over (partition by pit.root_part_id) max_po_date
    from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
    left join PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
        on po.purchase_order_id = pit.purchase_order_id
    left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
        on il.inventory_location_id = pit.store_id
    left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
        on m.market_id = il.branch_id
    left join ES_WAREHOUSE.PUBLIC.INVOICES i
        on i.invoice_id = pit.invoice_id
    where --pit.date_completed >= dateadd(month, -12, date_trunc(month, current_date))
         pit.date_cancelled is null
        and pit.transaction_type_id not in (17, 18) --no adjusts
        and remove = 'keep'
        -- and receiving_store_name not ilike '%trailer%'
        -- and pit.store_name not ilike '%trailer%'
        -- and pit.description not ilike '%bulk%'
        ;;
  }
  dimension: transaction_item_id {
    type: number
    primary_key: yes
    value_format_name: id
    sql: ${TABLE}.transaction_item_id ;;
  }
  dimension: transaction_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.transaction_id ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}.transaction_type ;;
  }

  dimension: created_by_user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.created_by_user_id ;;
  }

  dimension: created_by_username {
    type: string
    sql: ${TABLE}.created_by_username ;;
  }

  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.branch_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: store_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.store_id ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}.store_name ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.part_id ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.part_number;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  dimension: purchase_order_number {
    type: number
    value_format_name: id
    sql: ${TABLE}.purchase_order_number ;;
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.invoice_id ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id._value }}" target="_blank">{{ invoice_id._value }}</a></font></u> ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
  }

  dimension: receiving_store_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.receiving_store_id ;;
  }

  dimension: receiving_store_name {
    type: string
    sql: ${TABLE}.receiving_store_name;;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}.date_completed ;;
  }

  dimension: cost {
    type: number
    value_format_name:  usd_0
    sql: ${TABLE}.cost;;
  }

  dimension: cost_per_item {
    type: number
    value_format_name:  usd_0
    sql: ${TABLE}.cost_per_item;;
  }
## Count number of transactions, not the number of assets / month
  measure: count_transaction_id {
    type: count_distinct
    html: {{count_transaction_id._rendered_value}} Transactions |
          {{total_cost._rendered_value}} Total Value |
          {{total_quantity._rendered_value}} Total Parts ;;
    sql: ${TABLE}.transaction_id ;;
    drill_fields: [transaction_id
                  ,market_name
                  ,store_name
                  ,total_quantity
                  ,total_cost
                  ,date_completed_month_name
                  ,created_by_username]
  }
  measure: count_transaction_item_id {
    type: count_distinct
    html: {{total_cost._rendered_value}} Total Value;;
    sql: ${TABLE}.transaction_item_id ;;
    drill_fields: [transaction_id
      ,market_name
      ,store_name
      ,date_completed_month_name
      ,created_by_username]
  }

  measure: total_quantity {
    type: sum
    sql: ${TABLE}.quantity ;;
    drill_fields: [transaction_id
      ,market_name
      ,store_name
      ,part_number
      ,total_quantity
      ,cost_per_item
      ,total_cost
      ,date_completed_month_name
      ,created_by_username]
  }

  measure: total_cost{
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.cost;;
    drill_fields: [transaction_id
      ,market_name
      ,store_name
      ,part_number
      ,total_quantity
      ,cost_per_item
      ,total_cost
      ,date_completed_month_name
      ,created_by_username]
  }

  dimension: transaction_type_id {
    type: number
    sql: ${TABLE}.transaction_type_id ;;
  }

  measure: transactions_last_12_months {
    type: sum
    sql: ${TABLE}.last_12_months_flag ;;
    drill_fields: [last_12_months_drill*]
  }

  measure: transactions_last_12_months_consumption {
    type: sum
    sql: ${TABLE}.last_12_months_flag ;;
    filters: [transaction_type_id: "3, 7, 9, 13"]
    drill_fields: [transaction_detail*]
  }

  measure: transactions_last_12_months_purchases {
    type: sum
    sql: ${TABLE}.last_12_months_flag ;;
    filters: [transaction_type_id: "21, 23"]
    drill_fields: [transaction_detail*]
  }

  measure: transactions_last_12_months_other {
    type: sum
    sql: ${TABLE}.last_12_months_flag ;;
    filters: [transaction_type_id: "1, 2, 4, 5, 6, 8, 10, 11, 12, 14, 15, 16, 19, 20, 22, 24"]
    drill_fields: [transaction_detail*]
  }

  set: last_12_months_drill {
    fields: [
      market_name,
      market_region_xwalk.market_name,
      transactions_last_12_months_consumption,
      transactions_last_12_months_purchases,
      transactions_last_12_months_other,
      total_inventory_per_market.total_in_inventory
    ]
  }

  measure: transactions_last_6_months {
    type: sum
    sql: ${TABLE}.last_6_months_flag ;;
    drill_fields: [last_6_months_drill*]
  }

  measure: transactions_last_6_months_consumption {
    type: sum
    sql: ${TABLE}.last_6_months_flag  ;;
    filters: [transaction_type_id: "3, 7, 9, 13"]
    drill_fields: [transaction_detail*]
  }

  measure: transactions_last_6_months_purchases {
    type: sum
    sql: ${TABLE}.last_6_months_flag  ;;
    filters: [transaction_type_id: "21, 23"]
    drill_fields: [transaction_detail*]
  }

  measure: transactions_last_6_months_other {
    type: sum
    sql: ${TABLE}.last_6_months_flag  ;;
    filters: [transaction_type_id: "1, 2, 4, 5, 6, 8, 10, 11, 12, 14, 15, 16, 19, 20, 22, 24"]
    drill_fields: [transaction_detail*]
  }
  dimension: max_po_date {
    type: date
    sql: ${TABLE}.max_po_date ;;
  }

  set: last_6_months_drill {
    fields: [
      market_name,
      market_region_xwalk.market_name,
      transactions_last_6_months_consumption,
      transactions_last_6_months_purchases,
      transactions_last_6_months_other,
      total_inventory_per_market.total_in_inventory
    ]
  }

  set: transaction_detail {
    fields: [
      market_name
      , store_name
      , transaction_id
      , date_completed_date
      , transaction_type
      , part_number
      , quantity
    ]
  }
}
