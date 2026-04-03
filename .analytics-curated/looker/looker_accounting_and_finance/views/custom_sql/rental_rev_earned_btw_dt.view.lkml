view: rental_rev_earned_btw_dt {
  parameter: first_date {
    type: date
  }
  parameter: second_date {
    type: date
  }
  derived_table: {
    sql:select
       LI.ASSET_ID,
--        invoices.BILLING_APPROVED_DATE,
       round(sum(li.amount),2) as rental_rev_earned
from "ES_WAREHOUSE"."PUBLIC"."LINE_ITEMS" LI
left join ES_WAREHOUSE.PUBLIC.INVOICES invoices
on LI.INVOICE_ID = invoices.INVOICE_ID
where
--       LI.INVOICE_ID = 3203062 and
      LI.ASSET_ID is not null
  and li.LINE_ITEM_TYPE_ID in (6,8)
and BILLING_APPROVED_DATE between {% parameter first_date %} and {% parameter second_date %}
group by li.ASSET_ID
                  ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }
  dimension: rental_rev_earned {
    type: number
    sql: ${TABLE}.rental_rev_earned ;;
  }
  measure: display_first_date {
    description: "rental revenue earned by asset on or after this date"
    label: "on or after"
    type: date
    label_from_parameter: first_date
    sql:  {% parameter first_date %}
          ;;
  }
  measure: display_second_date {
    description: "rental revenue earned by asset before this date"
    label: "before"
    type: date
    label_from_parameter: second_date
    sql:  {% parameter second_date %}
      ;;
  }
}
