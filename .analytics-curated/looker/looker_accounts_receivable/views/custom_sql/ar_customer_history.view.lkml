view: ar_customer_history {
  derived_table: {
    sql: with inv_cte as (
    select      -- Invoices
        ADI.COMPANY_ID                  customerid,
        'Invoice'                       type,
        ADI.BILLING_APPROVED_DATE::date activity_date,
        ADI.PAID_DATE::date             close_date,
        ADI.INVOICE_NO                  activity,
        ADP.NAME                        po_num,
        ADI.DUE_DATE::date              due_date,
        ADI.BILLED_AMOUNT               amount
    from ES_WAREHOUSE.PUBLIC.INVOICES ADI
    join ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS ADP
        on ADI.PURCHASE_ORDER_ID = ADP.PURCHASE_ORDER_ID
    where activity_date is not null
        {% if asof_date._parameter_value == "''" %}
        and {{ asof_date._parameter_value }} between activity_date and coalesce(close_date, current_date)
        {% endif %}
),

pmt_cte as (
    select      -- Payments
        ADP.COMPANY_ID          customerid,
        'Payment'               type,
        ADP.DATE_CREATED::date  activity_date,
        ADPA.CLOSED             close_date,
        ADI.INVOICE_NO          activity,
        case
            when ADP.PAYMENT_METHOD_TYPE_ID = 1
                then concat('Credit Card payment ID ', coalesce(ADP.STRIPE_ID,''))
            when ADP.PAYMENT_METHOD_TYPE_ID = 2
                then concat('ACH Payment ', coalesce(ADP.REFERENCE,''))
            when ADP.PAYMENT_METHOD_TYPE_ID = 3
                then concat('Check Payment ', coalesce(concat('Check #',ADP.CHECK_NUMBER),''))
            when ADP.PAYMENT_METHOD_TYPE_ID = 4
                then coalesce(concat('Other Payment ', ADP.REFERENCE),'Unspecified')
            when ADP.PAYMENT_METHOD_TYPE_ID = 5
                then concat('Cash Payment ', coalesce(ADP.REFERENCE,''))
            else ADP.REFERENCE
        end                     po_num,
        null                    due_date,
        coalesce(-ADPA.AMOUNT,
            -ADP.AMOUNT_REMAINING) amount
    from ES_WAREHOUSE.PUBLIC.PAYMENTS ADP
    left join (select PAYMENT_ID, INVOICE_ID, AMOUNT, max(DATE::date) closed
          from ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS
          where REVERSED_DATE is null
          group by PAYMENT_ID, INVOICE_ID, AMOUNT) ADPA
        on ADP.PAYMENT_ID = ADPA.PAYMENT_ID
    left join ES_WAREHOUSE.PUBLIC.INVOICES ADI
        on ADPA.INVOICE_ID = ADI.INVOICE_ID
    where ADP.STATUS = 0
),

cr_cte as (
    select      -- Credits & Adjustments
        ADC.COMPANY_ID          customerid,
        'Credit'                type,
        ADC.DATE_CREATED::date  activity_date,
        ADCA.CLOSED             close_date,
        coalesce(ADI.INVOICE_NO,
            ADC.CREDIT_NOTE_NUMBER) activity,
        null                    po_num,
        null                    due_date,
        -ADC.TOTAL_CREDIT_AMOUNT amount
    from ES_WAREHOUSE.PUBLIC.CREDIT_NOTES ADC
    left join   (select CREDIT_NOTE_ID,
                        max(DATE_CREATED::date) closed
                from ES_WAREHOUSE.PUBLIC.CREDIT_NOTE_ALLOCATIONS
                group by CREDIT_NOTE_ID) ADCA
        on ADC.CREDIT_NOTE_ID = ADCA.CREDIT_NOTE_ID
    left join ES_WAREHOUSE.PUBLIC.INVOICES ADI
        on ADC.ORIGINATING_INVOICE_ID = ADI.INVOICE_ID
)

select
       I.*,
       coalesce(P.amount,0)+coalesce(C.amount,0) payments,
       I.amount+payments balance
from inv_cte I
left join (select * from pmt_cte
            {% if asof_date._parameter_value == "''" %}
            where activity_date < {{ asof_date._parameter_value }}
            {% endif %}
            ) P
    on I.activity = P.activity
left join (select * from cr_cte
            {% if asof_date._parameter_value == "''" %}
            where activity_date < {{ asof_date._parameter_value }}
            {% endif %}
            ) C
    on I.activity = C.activity
where I.amount != 0

union all

select
       P.*,
       0 payments,
       P.amount balance
from pmt_cte P
left join inv_cte I
    on P.activity = I.activity
where
    {% if asof_date._parameter_value == "''" %}
    {{ asof_date._parameter_value }} between P.activity_date and coalesce(P.close_date, current_date) and
    {% endif %}
    I.activity is null

union all

select
       C.*,
       0 payments,
       C.amount balance
from cr_cte C
left join inv_cte I
    on C.activity = I.activity
where
    {% if asof_date._parameter_value == "''" %}
    {{ asof_date._parameter_value }} between C.activity_date and coalesce(C.close_date, current_date) and
    {% endif %}
    I.activity is null
 ;;
  }

  parameter: asof_date {
    type: date
    label: "As of Date"
    convert_tz: no
    # allowed_value: {
    #   label: "None"
    #   value: "''"
    # }
  }

  measure: amount {
    type: sum
    label: "Amount"
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: payments {
    type: sum
    label: "Payments"
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."PAYMENTS" ;;
  }

  measure: balance {
    type: sum
    label: "Balance"
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."BALANCE" ;;
  }

  dimension: customerid {
    type: string
    sql: ${TABLE}."CUSTOMERID" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
    order_by_field: type_sort
  }

  dimension: activity_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."ACTIVITY_DATE" ;;
  }

  dimension: close_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."CLOSE_DATE" ;;
  }

  dimension: activity {
    type: string
    sql: ${TABLE}."ACTIVITY" ;;
  }

  dimension: po_num {
    type: string
    sql: ${TABLE}."PO_NUM" ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: type_sort {
    type: number
    hidden: yes
    sql: case when ${type} = 'Invoice' then 1
              when ${type} = 'Payment' then 2
              when ${type} = 'Credit'  then 3
              end ;;
  }

}
