view: concur_pending_branch_approval {
  derived_table: {
    sql: SELECT DISTINCT
    PBA.COST_OBJECT_APPROVER  AS APPROVER_NAME,
    PBA.EMPLOYEE_ID           AS APPROVER_EMAIL,
    PBA.LATEST_SUBMIT_DATE    AS LAST_SUBMITTED,
    PBA.DAYS_PENDING_APPROVAL AS DAYS_PENDING,
    PBA.VENDOR_ID             AS VENDOR_ID,
    VEND.NAME                 AS VENDOR_NAME,
    PBA.INVOICE_NUMBER        AS BILL_NUMBER,
    PBA.BRANCH_ID             AS BRANCH_ID,
    DEPT.TITLE                AS BRANCH_NAME,
    PBA.REQUEST_TOTAL         AS INVOICE_TOTAL
FROM
    ANALYTICS.CONCUR.PENDING_BRANCH_APPROVAL AS PBA
        LEFT JOIN ANALYTICS.INTACCT.VENDOR AS VEND ON PBA.VENDOR_ID = VEND.VENDORID
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT AS DEPT ON PBA.BRANCH_ID = DEPT.DEPARTMENTID
ORDER BY
    PBA.COST_OBJECT_APPROVER ASC,
    PBA.DAYS_PENDING_APPROVAL DESC,
    PBA.VENDOR_ID ASC,
    PBA.INVOICE_NUMBER ASC
                ;;
  }

  dimension: approver_name {
    type: string
    sql: ${TABLE}.APPROVER_NAME ;;
  }


  dimension: approver_email {
    type: string
    sql: ${TABLE}.APPROVER_EMAIL ;;
  }

  dimension: last_submitted_date {
    type: date
    sql: ${TABLE}.LAST_SUBMITTED ;;
  }

  dimension: days_pending {
    type: number
    sql: ${TABLE}.DAYS_PENDING ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.VENDOR_ID ;;
  }


  dimension: vendor_name {
    type: string
    sql: ${TABLE}.VENDOR_NAME ;;
  }


  dimension: bill_number {
    type: string
    sql: ${TABLE}.BILL_NUMBER ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}.BRANCH_ID ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}.BRANCH_NAME ;;
  }


  measure: invoice_total {
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    sql: ${TABLE}.INVOICE_TOTAL ;;
  }

  measure: max_days_pending {
    type: max
    sql: ${TABLE}.DAYS_PENDING ;;
  }

  measure: avg_days_pending {
    type: average
    sql: ${TABLE}.DAYS_PENDING ;;
  }

  measure: count {
    type:count
  }

  dimension: market_access {
    type: yesno
    sql:  ${branch_id} in ({{ _user_attributes['market_id'] }}) ;;
  }

}
