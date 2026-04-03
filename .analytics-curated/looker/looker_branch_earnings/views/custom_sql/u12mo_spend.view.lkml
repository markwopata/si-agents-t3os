view: u12mo_spend {
  derived_table: {
    sql:
      select
        pd.vendor_id,
        pd.vendor_name,
        pd.receipt_number,
        pd.date_created,
        pd.gl_date,
        date_trunc(month, pd.gl_date)                                     as period_start_date,
        to_varchar(pd.gl_date, 'MMMM YYYY')                               as period_name,
        pd.department_id,
        pd.t3_po_created_by_name,
        pd.document_status,
        pd.line_description,
        pd.unit_price,
        pd.extended_amount,
        pd.item_type,
        po.status                                                       as po_status,
        pd.url_t3,
        pd.url_sage,
        po.requesting_market_id,
        im.market_name                                                  as requesting_market_name,
        datediff(months, m.branch_earnings_start_month, date_trunc(month, pd.gl_date)) + 1 as months_open,
        case
          when months_open <= 12 and months_open > 0 then '<= 12 months'
          when months_open <= 0                     then 'not open'
          else                                       '> 12 months'
        end                                                             as market_month_category,
        m.district,
        m.region_name,
        po.deliver_to_market_id,
        im2.market_name                                                 as deliver_to_market_name,
        'purchase order'                                                as spend_type
      from analytics.intacct_models.po_detail pd
      join analytics.branch_earnings.market m
        on pd.department_id = m.child_market_id::text
      left join analytics.vm_dbt.stg_procurement_public__purchase_orders po
        on pd.fk_t3_purchase_order_id = po.purchase_order_id
      left join analytics.intacct_models.int_markets im
        on po.requesting_market_id = im.market_id
      left join analytics.intacct_models.int_markets im2
        on po.deliver_to_market_id = im2.market_id
      left join analytics.vm_dbt.stg_procurement_public__purchase_order_line_items poli
        on po.purchase_order_id = poli.purchase_order_id
      left join analytics.vm_dbt.stg_procurement_public__purchase_order_receiver_items pori
        on poli.purchase_order_line_item_id               = pori.purchase_order_line_item_id
        and pori.purchase_order_receiver_item_id          = pd.fk_t3_purchase_order_receiver_item_id
      where pd.gl_date >= '2022-01-01'
        and pd.document_type = 'Purchase Order'
      group by all
      order by period_start_date desc
    ;;
  }

  # Dimensions

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.vendor_id ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  dimension: receipt_number {
    type: string
    sql: ${TABLE}.receipt_number ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}.date_created ;;
  }

  dimension: gl_date {
    type: date
    sql: ${TABLE}.gl_date ;;
  }

  dimension: period_start_date {
    type: date
    sql: ${TABLE}.period_start_date ;;
  }

  dimension: period_name {
    type: string
    sql: ${TABLE}.period_name ;;
  }

  dimension: department_id {
    type: string
    sql: ${TABLE}.department_id ;;
  }

  dimension: t3_po_created_by_name {
    type: string
    sql: ${TABLE}.t3_po_created_by_name ;;
  }

  dimension: document_status {
    type: string
    sql: ${TABLE}.document_status ;;
  }

  dimension: line_description {
    type: string
    sql: ${TABLE}.line_description ;;
  }

  measure: avg_unit_price {
    type: average
    sql: ${TABLE}.unit_price ;;
  }

  measure: extended_amount {
    type: sum
    sql: ${TABLE}.extended_amount ;;
  }

  dimension: item_type {
    type: string
    sql: ${TABLE}.item_type ;;
  }

  dimension: po_status {
    type: string
    sql: ${TABLE}.po_status ;;
  }

  dimension: url_t3 {
    type: string
    sql: ${TABLE}.url_t3 ;;
  }

  dimension: url_sage {
    type: string
    sql: ${TABLE}.url_sage ;;
  }

  dimension: requesting_market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.requesting_market_id ;;
  }

  dimension: requesting_market_name {
    type: string
    sql: ${TABLE}.requesting_market_name ;;
  }

  dimension: months_open {
    type: number
    sql: ${TABLE}.months_open ;;
  }

  dimension: market_month_category {
    type: string
    sql: ${TABLE}.market_month_category ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: deliver_to_market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.deliver_to_market_id ;;
  }

  dimension: deliver_to_market_name {
    type: string
    sql: ${TABLE}.deliver_to_market_name ;;
  }

  dimension: spend_type {
    type: string
    sql: ${TABLE}.spend_type ;;
  }

  dimension: links {
    type: string
    sql: coalesce(${url_sage}, ${url_t3}) ;;
    html:
      {% if u12mo_spend.url_t3._value != null %}
        <a href="{{ u12mo_spend.url_t3._value }}" target="_blank">
          <img src="https://unav.equipmentshare.com/fleet.svg" width="16" height="16"> T3</a>
        &nbsp;
      {% endif %}
      {% if u12mo_spend.url_sage._value != null %}
        <a href="{{ u12mo_spend.url_sage._value }}" target="_blank">
          <img src="https://www.intacct.com/favicon.ico" width="16" height="16"> Sage</a>
        &nbsp;
      {% endif %}
    ;;
  }

  # Measures

  measure: record_count {
    type: count
    description: "Number of line items"
  }

  measure: total_spend {
    type: sum
    sql: ${TABLE}.extended_amount ;;
    value_format_name: "usd"
    description: "Sum of extended amounts"
  }
}
