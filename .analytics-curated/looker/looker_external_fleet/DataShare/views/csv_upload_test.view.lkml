view: csv_upload_test {
 derived_table: {
  sql: select
        i.invoice_date::date as invoice_date
      , i.company_id
      , i.paid
      , ai.asset_class
      , coalesce(rsi.vendor, 'EQUIPMENTSHARE.COM INC') as vendor
      , case
          when li.line_item_type_id in (6, 8, 44, 108, 109) then 'Rental Amount'
          when li.line_item_type_id in (9) then  'Rental Protection Plan'
          when li.line_item_type_id in (5, 117) then  'Transport'
          when li.line_item_type_id in (99, 100, 101, 102, 103, 104, 130, 139, 129, 131, 132) then 'Fuel'
          when li.line_item_type_id not in (6, 8, 9, 44, 108, 109, 5, 117, 99, 100, 101, 102, 103, 104, 130, 139, 129, 131, 132) then 'Misc Charges Amount'
          else 'Unknown'
          end as Line_Item_Charge

      , sum(billed_amount) as billed_amount

      from
      es_warehouse.public.invoices i
      left join es_warehouse.public.line_items li on i.invoice_id = li.invoice_id
      left join es_warehouse.public.line_item_types lit on lit.LINE_ITEM_TYPE_ID = li.LINE_ITEM_TYPE_ID
      left join es_warehouse.public.orders o on o.order_id = i.order_id
      left join es_warehouse.public.rentals r on r.order_id = o.order_id
      left join business_intelligence.triage.stg_t3__asset_info ai on ai.asset_id = r.asset_id
      left join business_intelligence.triage.stg_t3__rental_status_info rsi on rsi.rental_id = r.rental_id
      where i.sent = true
      and o.deleted = false
      and i.invoice_date >= '2024-01-01'
      and
      (i.company_id in
      (
      SELECT company_id
      FROM analytics.bi_ops.parent_company_relationships
      where parent_company_id = {{ _user_attributes['company_id'] }}
      or company_id = {{ _user_attributes['company_id'] }}
      )
      or i.company_id = {{ _user_attributes['company_id'] }})
      group by
      i.invoice_date::date
    , i.company_id
    , i.paid
    , ai.asset_class
    , coalesce(rsi.vendor, 'EQUIPMENTSHARE.COM INC')
    , li.line_item_type_id
      ;;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: invoice_date {
  type: date
  sql: ${TABLE}."INVOICE_DATE" ;;
}

dimension: company_id {
  type: number
  sql: ${TABLE}."COMPANY_ID" ;;
}

dimension: paid {
  type: yesno
  sql: ${TABLE}."PAID" ;;
}

dimension: asset_class {
  type: string
  sql: ${TABLE}."ASSET_CLASS" ;;
}

dimension: vendor {
  type: string
  sql: ${TABLE}."VENDOR" ;;
}

dimension: line_item_charge {
  type: string
  sql: ${TABLE}."LINE_ITEM_CHARGE" ;;
}

dimension: billed_amount {
  type: number
  sql: ${TABLE}."BILLED_AMOUNT" ;;
}

set: detail {
  fields: [
    invoice_date,
    company_id,
    paid,
    asset_class,
    vendor,
    line_item_charge,
    billed_amount
  ]
}
}
