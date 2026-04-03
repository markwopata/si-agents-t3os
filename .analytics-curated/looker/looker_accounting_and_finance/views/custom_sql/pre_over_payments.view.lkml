view: pre_over_payments {

  derived_table: {
    sql:
SELECT P.COMPANY_ID, SUM(IFNULL(P.AMOUNT_REMAINING,0)) AS PRE_OVER_PAYMENTS
FROM ES_WAREHOUSE.PUBLIC.PAYMENTS AS P
WHERE P.STATUS = 0
GROUP BY P.COMPANY_ID
          ;;
  }

  dimension: company_id {
    type: number
    primary_key: yes
    value_format_name: id
    sql: ${TABLE}.COMPANY_ID ;;
  }



  measure: pre_over_payments {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.PRE_OVER_PAYMENTS ;;
  }

}
