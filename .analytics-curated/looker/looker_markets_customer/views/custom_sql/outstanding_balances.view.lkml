view: outstanding_balances {
  derived_table: {
    sql:select COMPANY_ID,
       ROUND(sum(case when DUE_DATE_OUTSTANDING < 1 then OWED_AMOUNT else 0 end),
             2)   as DUE_0,
       ROUND(
               sum(case when DUE_DATE_OUTSTANDING BETWEEN 1 AND 30 then OWED_AMOUNT else 0 end),
               2) as DUE_1_30,
       ROUND(
               sum(case when DUE_DATE_OUTSTANDING BETWEEN 31 AND 60 then OWED_AMOUNT else 0 end),
               2) as DUE_31_60,
       ROUND(
               sum(case when DUE_DATE_OUTSTANDING BETWEEN 61 AND 90 then OWED_AMOUNT else 0 end),
               2) AS DUE_61_90,
       ROUND(sum(case
                     when DUE_DATE_OUTSTANDING BETWEEN 91 AND 120 then OWED_AMOUNT
                     else 0 end),
             2)   AS DUE_91_120,
       ROUND(sum(case when DUE_DATE_OUTSTANDING > 120 then OWED_AMOUNT else 0 end),
             2)   AS DUE_120_PLUS
from ES_WAREHOUSE.PUBLIC.INVOICES
GROUP BY COMPANY_ID;;}


  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  measure: DUE_0 {
    type: sum
    sql: ${TABLE}."DUE_0";;
  }

  measure: DUE_1_30 {
    type: sum
    sql: ${TABLE}."DUE_1_30";;
  }

  measure: DUE_31_60 {
    type: sum
    sql: ${TABLE}."DUE_31_60";;
  }

  measure: DUE_61_90 {
    type: sum
    sql: ${TABLE}."DUE_61_90";;
  }

  measure: DUE_91_120 {
    type: sum
    sql: ${TABLE}."DUE_91_120";;
  }

  measure: DUE_120_PLUS {
    type: sum
    sql:${TABLE}."DUE_120_PLUS";;
  }

}
