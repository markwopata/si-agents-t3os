view: t3_companies {
  derived_table: {
    sql:
SELECT i.company_id,
       SUM(li.amount) AS t3_revenue
  FROM es_warehouse.public.invoices i
       INNER JOIN es_warehouse.public.line_items li
                  ON i.invoice_id = li.invoice_id
 WHERE i.billing_approved_date >= DATEADD('month', -2, CURRENT_DATE())
   AND li.line_item_type_id IN (30, 31, 32, 33, 34)
 GROUP BY i.company_id;;
  }

  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: has_t3_revenue {
    type: yesno
    sql: ${TABLE}."T3_REVENUE" > 0 ;;
  }

  measure: t3_revenue {
    type: sum
    sql: ${TABLE}."T3_REVENUE" ;;
  }


}
