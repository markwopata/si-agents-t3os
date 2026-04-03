view: service_expenses_and_rental_revenue_comparison {
  derived_table: {
    # datagroup_trigger: 6AM_update
    # indexes: ["market_id"]
    sql: WITH date_series as
         (
             SELECT month_::timestamp FROM generate_series('2019-12-30', '2026-01-04', INTERVAL '7 days') month_
         ),
     data_cte as
         (
SELECT ds.month_ as start_date,
       (ds.month_ + INTERVAL '7 days' - INTERVAL '.01 second') as end_date,
       gt.entry_date,
       gt.recordno,
       gt.description,
       gt.accountno,
       ram.title,
       (gt.amount * -1 * gt.tr_type::int) as amount,
       gt.department::int as market_id,
       gt.whencreated,
       gt.whenmodified,
       gt.batchtitle,
       'e' as account_type
FROM analytics.gl_table gt
LEFT JOIN analytics.revmodel_account_mapping ram
    ON gt.accountno = ram.accountno::text
JOIN date_series ds
    ON gt.entry_date BETWEEN ds.month_ AND (ds.month_ + INTERVAL '7 days' - INTERVAL '.01 second')
WHERE ram.cost_revenue = 'C'
AND ram.accounttype = 'incomestatement'
AND gt.state = 'Posted'
AND gt.department ~ '^[0-9]'
AND gt.accountno in ('6302','6303','6304','6305','6306','6307','6308','6300','6301','6310','6311')
)
SELECT
*
FROM data_cte
union
select
  date_trunc('month',i.billing_approved_date)::DATE as billing_approved_date_start,
  date_trunc('month',i.billing_approved_date)::DATE as billing_approved_date_end,
  date_trunc('month',i.billing_approved_date)::DATE as billing_approved_date,
  '0' as recordno,
  'rental_revenue' as description,
  '0000' as account_no,
  'rental_revenue' as title,
  sum(li.amount) as amount,
  m.market_id,
  date_trunc('month',i.billing_approved_date)::DATE as whencreated,
  date_trunc('month',i.billing_approved_date)::DATE as whenmodified,
  'revenue' as batchtitle,
  'rr' as account_type
  from
    orders o
    join invoices i on i.order_id = o.order_id
    join line_items li on li.invoice_id = i.invoice_id
    inner join analytics.market_region_xwalk m on m.market_id = o.market_id
  where
    li.line_item_type_id = 8
    and date_trunc('month',i.billing_approved_date::DATE) >= (date_trunc('month',current_date) - interval '11 months')
  group by
  date_trunc('month',i.billing_approved_date),
  m.market_id
union
SELECT ds.month_ as start_date,
       (ds.month_ + INTERVAL '7 days' - INTERVAL '.01 second') as end_date,
       gt.entry_date,
       gt.recordno,
       gt.description,
       gt.accountno,
       ram.title,
       (gt.amount * -1 * gt.tr_type::int) as amount,
       gt.department::int as market_id,
       gt.whencreated,
       gt.whenmodified,
       gt.batchtitle,
       'rr' as account_type
FROM analytics.gl_table gt
LEFT JOIN analytics.revmodel_account_mapping ram
    ON gt.accountno = ram.accountno::text
JOIN date_series ds
    ON gt.entry_date BETWEEN ds.month_ AND (ds.month_ + INTERVAL '7 days' - INTERVAL '.01 second')
WHERE ram.cost_revenue = 'R'
AND ram.accounttype = 'incomestatement'
AND gt.state = 'Posted'
AND gt.department ~ '^[0-9]'
AND gt.accountno in ('5300','5301','5302','5303','5304','5305')
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

#   dimension_group: start_date {
#     type: time
#     sql: ${TABLE}."start_date" ;;
#   }

  dimension_group: start_date {
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
    sql: ${TABLE}."start_date" ;;
  }

  dimension_group: end_date {
    type: time
    sql: ${TABLE}."end_date" ;;
  }

  dimension_group: entry_date {
    type: time
    sql: ${TABLE}."entry_date" ;;
  }

  dimension: recordno {
    type: number
    sql: ${TABLE}."recordno" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."description" ;;
  }

  dimension: accountno {
    type: string
    sql: ${TABLE}."accountno" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."title" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."amount" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."market_id" ;;
  }

  dimension_group: whencreated {
    type: time
    sql: ${TABLE}."whencreated" ;;
  }

  dimension_group: whenmodified {
    type: time
    sql: ${TABLE}."whenmodified" ;;
  }

  dimension: batchtitle {
    type: string
    sql: ${TABLE}."batchtitle" ;;
  }

  dimension: account_type {
    type: string
    sql: ${TABLE}."account_type" ;;
  }

  measure: total_revenue {
    type: sum
    sql: ${amount};;
    value_format_name: usd_0
    filters: [account_type: "rr"]
  }

  measure: total_expenses {
    type: sum
    sql: ${amount}*-1 ;;
    value_format_name: usd_0
    filters: [account_type: "e"]
  }

  measure: total_expenses_drill {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [account_type: "e"]
  }

  measure: percent_of_expenses_vs_rental_rev {
    type: number
    sql: ${total_expenses}/ case when ${total_revenue} = 0 then null else ${total_revenue} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      start_date_month,
      title,
      total_expenses_drill,
      total_revenue
    ]
  }
}
