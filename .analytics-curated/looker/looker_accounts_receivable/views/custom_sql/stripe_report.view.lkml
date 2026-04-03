view: stripe_report {
  derived_table: {
    sql: select o.ORDER_ID,
       concat('https://admin.equipmentshare.com/#/home/orders/', o.ORDER_ID) as LINK,
       c.COMPANY_ID,
       c.NAME as company_name,
       p.UNAPPLIED_PAYMENTS,
       p.PAYMENT_DATE,
       ioa.INVOICE_ID,
       ioa.OWED_AMOUNT
from ES_WAREHOUSE.PUBLIC.ORDERS O
         join (select ORDER_ID,
                        max(CREATED) as PAYMENT_DATE,
                       sum(AMOUNT_REMAINING) as UNAPPLIED_PAYMENTS
                from ES_WAREHOUSE.PUBLIC.PAYMENTS
                join STRIPE.PAYMENT_INTENT
                    on PAYMENTS.STRIPE_ID = PAYMENT_INTENT.ID
                where AMOUNT_REMAINING > 0
                and ORDER_ID is not null
                and ENTERED_AS_PREPAYMENT
                and PAYMENT_INTENT.DESCRIPTION like '%generated via API%'
                group by ORDER_ID) P
              on O.ORDER_ID = P.ORDER_ID
        join ES_WAREHOUSE.PUBLIC.USERS u
            on o.USER_ID = u.USER_ID
        join ES_WAREHOUSE.PUBLIC.COMPANIES c
            on u.COMPANY_ID = c.COMPANY_ID
        left join (select ORDER_ID,
                           array_agg(INVOICE_ID) as invoice_id,
                           sum(OWED_AMOUNT) as owed_amount
                    from ES_WAREHOUSE.PUBLIC.INVOICES
                    where OWED_AMOUNT <> 0
                    and BILLING_APPROVED
                    group by ORDER_ID) ioa
            on o.ORDER_ID = ioa.ORDER_ID
 ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: link_to_admin {
    type: string
    sql: ${TABLE}."LINK" ;;
    html: <font color="#0063f3"><u><a href="{{value}}" target="_blank">Link to Admin</font></u>
      <img src="https://i.ibb.co/3czBQcM/Gear-447.png" height="15" width="15"></a>;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  measure: unapplied_payments {
    type: sum
    sql: ${TABLE}."UNAPPLIED_PAYMENTS" ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension_group: payment_date {
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
    sql: CAST(${TABLE}."PAYMENT_DATE" AS TIMESTAMP_NTZ) ;;
  }

  measure: owed_amount {
    type: sum
    sql: ${TABLE}."OWED_AMOUNT" ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  set: detail {
    fields: [order_id, invoice_id]
  }
}
