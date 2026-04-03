view: quotes_table_dead_deals {
derived_table: {
  sql: --- you must use DISINCT to count quote_number. Quotes with multiple equipment_class with cause duplication on the join
       select
         q.created_date
       , case
         when q.order_id is not null then 'Converted to Order'
         when q.missed_rental_reason is not null then 'Missed Quote'
         when q.expiry_date <= current_date() and order_id is null and q.missed_rental_reason is null then 'Missed Quote'
         when q.expiry_date > current_date() and order_id is null and q.missed_rental_reason is null then 'Open'
         else 'Unknown'
         end as quote_status
       , case
         when q.expiry_date <= current_date() and order_id is null and q.missed_rental_reason is null then True
         else False
         end as Expired
       , q.expiry_date
       , case
         when quote_status = 'Missed Quote' then coalesce(q.missed_rental_reason, 'No Reason Given')
         else NULL
         end as missed_rental_reason
       , case
         when q.sales_rep_id in (6052, 171481) then 'Amy/Tanner'
         else 'TAMs'
         end as Sales_Person_Group
       , q.missed_rental_reason_other
       , q.quote_number
       , q.order_id
       , q.sales_rep_id
       , et.equipment_class_id
       , et.equipment_class_name
       , q.branch_id
       , m.market_id
       , m.market_name
       , m.district
       , m.region_name
       , m.market_type
       , rt.name as rate_type
       , qp.sale_items_subtotal
       , qp.rpp
       , qp.total
       , qp.equipment_charges
       , qp.sales_tax
       , qp.rental_subtotal
       , qp.rpp_tax
       , si.line_item_type_id
       , lit.name as line_item_name
       , si.sale_item
       , si.quantity
       , si.price
       , si.part_id
       , ss.user_id as secondary_sales_rep_id
       , concat('https://quotes.estrack.com/',q.id) as link_to_quote
       --, q.*
      from
        quotes.quotes.quote q
          left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m on m.market_id = q.branch_id
          left join QUOTES.QUOTES.QUOTE_PRICING qp on qp.quote_id = q.id
          left join QUOTES.QUOTES.SECONDARY_SALES_REP ss on ss.quote_id = q.id
          --- quotes with multiple equipment types causes duplication on the join
          left join QUOTES.QUOTES.EQUIPMENT_TYPE et on et.quote_id = q.id
          left join QUOTES.QUOTES.RATE_TYPE rt on rt.id = et.selected_rate_type_id
          --- quotes with muliple sale items causes duplication on the join
          left join QUOTES.QUOTES.sale_item si on si.quote_id = q.id
          left join ES_WAREHOUSE.PUBLIC.line_item_types lit on lit.line_item_type_id = si.line_item_type_id
          --where q.sales_rep_id in (6052, 171481)
          --and q.created_date >= '2025-02-01'
          --and q.created_date <= DATEADD(day, -7, CURRENT_DATE())
         -- order by q.missed_rental_reason, q.created_date desc
           ;;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension_group: created_date {
  type: time
  sql: ${TABLE}."CREATED_DATE" ;;
}

dimension: quote_status {
  type: string
  sql: ${TABLE}."QUOTE_STATUS" ;;
}

dimension: expired {
  type: yesno
  sql: ${TABLE}."EXPIRED" ;;
}

dimension_group: expiry_date {
  type: time
  sql: ${TABLE}."EXPIRY_DATE" ;;
}

dimension: missed_rental_reason {
  type: string
  sql: ${TABLE}."MISSED_RENTAL_REASON" ;;
}

dimension: sales_person_group {
  type: string
  sql: ${TABLE}."SALES_PERSON_GROUP" ;;
}

dimension: missed_rental_reason_other {
  type: string
  sql: ${TABLE}."MISSED_RENTAL_REASON_OTHER" ;;
}

dimension: quote_number {
  type: string
  sql: ${TABLE}."QUOTE_NUMBER" ;;
}

  measure: dead_deal_count {
    type: count_distinct
    sql: CASE WHEN ${quote_status} = 'Missed Quote' THEN ${quote_number} ELSE NULL END ;;
    drill_fields: [detail*]
  }

  measure: all_requests_count {
    type: count_distinct
    sql: ${quote_number} ;;
    drill_fields: [detail*]
  }

dimension: order_id {
  type: number
  sql: ${TABLE}."ORDER_ID" ;;
}

dimension: sales_rep_id {
  type: number
  sql: ${TABLE}."SALES_REP_ID" ;;
}

dimension: equipment_class_id {
  type: number
  sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
}

dimension: equipment_class_name {
  type: string
  sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
}

dimension: branch_id {
  type: number
  sql: ${TABLE}."BRANCH_ID" ;;
}

dimension: market_id {
  type: number
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

dimension: market_type {
  type: string
  sql: ${TABLE}."MARKET_TYPE" ;;
}

dimension: rate_type {
  type: string
  sql: ${TABLE}."RATE_TYPE" ;;
}

dimension: sale_items_subtotal {
  type: number
  sql: ${TABLE}."SALE_ITEMS_SUBTOTAL" ;;
}

dimension: rpp {
  type: number
  sql: ${TABLE}."RPP" ;;
}

dimension: total {
  type: number
  sql: ${TABLE}."TOTAL" ;;
}

  measure: total_revenue {
    type: number
    sql: div0(sum(${total}),count(distinct ${quote_number}))  ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

dimension: equipment_charges {
  type: number
  sql: ${TABLE}."EQUIPMENT_CHARGES" ;;
}

  measure: equipment_revenue {
    type: number
    sql: div0(sum(${equipment_charges}),count(distinct ${quote_number}))  ;;
    value_format_name: usd
  }

dimension: sales_tax {
  type: number
  sql: ${TABLE}."SALES_TAX" ;;
}

dimension: rental_subtotal {
  type: number
  sql: ${TABLE}."RENTAL_SUBTOTAL" ;;
}

dimension: rpp_tax {
  type: number
  sql: ${TABLE}."RPP_TAX" ;;
}

dimension: line_item_type_id {
  type: number
  sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
}

dimension: line_item_name {
  type: string
  sql: ${TABLE}."LINE_ITEM_NAME" ;;
}

dimension: sale_item {
  type: string
  sql: ${TABLE}."SALE_ITEM" ;;
}

dimension: quantity {
  type: number
  sql: ${TABLE}."QUANTITY" ;;
}

dimension: price {
  type: number
  sql: ${TABLE}."PRICE" ;;
}

dimension: part_id {
  type: number
  sql: ${TABLE}."PART_ID" ;;
}

dimension: secondary_sales_rep_id {
  type: number
  sql: ${TABLE}."SECONDARY_SALES_REP_ID" ;;
}

dimension: link_to_quote {
  type: string
  sql: ${TABLE}."LINK_TO_QUOTE" ;;
}

set: detail {
  fields: [
    created_date_time,
    quote_status,
    expired,
    expiry_date_time,
    missed_rental_reason,
    sales_person_group,
    missed_rental_reason_other,
    quote_number,
    order_id,
    sales_rep_id,
    equipment_class_id,
    equipment_class_name,
    branch_id,
    market_id,
    market_name,
    district,
    region_name,
    market_type,
    rate_type,
    sale_items_subtotal,
    rpp,
    total,
    equipment_charges,
    sales_tax,
    rental_subtotal,
    rpp_tax,
    line_item_type_id,
    line_item_name,
    sale_item,
    quantity,
    price,
    part_id,
    secondary_sales_rep_id,
    link_to_quote
  ]
}
}
