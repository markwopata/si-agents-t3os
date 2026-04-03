view: t3_saas_IBR_submissions {

  derived_table: {
    sql:
--IBR SUBMISSIONS FROM G-SHEET--
with ibr_submissions_date_unformatted as (
select
    INSTALL_FINAL_AMOUNT,
    _OF_DEVICES as INSTALL_DEVICE_COUNT,
    TO_VARCHAR(HS_DEAL_RECORD_ID) as SALES_REF_ID,
    CUSTOMER_TYPE,
    DATE(DATE_SUBMITTED) as DATE_INSTALL_BILLING_SUBMISSION,
    COMPANY_NAME,
    IBR_SHEET_LINK_ as IBR_SHEET_LINK
from
    ANALYTICS.T3_SAAS_BILLING.IBR_SUBMISSIONS
order by
    _row
)

, ibr_submissions_formatted as (
select
    INSTALL_FINAL_AMOUNT,
    INSTALL_DEVICE_COUNT,
    SALES_REF_ID as SALES_REF_ID,
    CUSTOMER_TYPE,
    case
        when DATE_INSTALL_BILLING_SUBMISSION like '00%%' then REPLACE(DATE_INSTALL_BILLING_SUBMISSION, '00', '20')
        when DATE_INSTALL_BILLING_SUBMISSION like '20%%' then DATE_INSTALL_BILLING_SUBMISSION
    end as DATE_INSTALL_BILLING_SUBMISSION,
    COMPANY_NAME as COMPANY_NAME,
    IBR_SHEET_LINK as IBR_SHEET_LINK
from
    ibr_submissions_date_unformatted
where
    SALES_REF_ID REGEXP '^[0-9]{9,12}$'
)

, ibr_submissions_sums as (
select
    sum(INSTALL_FINAL_AMOUNT) as INSTALL_FINAL_AMOUNT,
    sum(INSTALL_DEVICE_COUNT) as INSTALL_DEVICE_COUNT,
    SALES_REF_ID
from
    ibr_submissions_formatted
group by
    SALES_REF_ID
)

select
    INSTALL_FINAL_AMOUNT,
    INSTALL_DEVICE_COUNT,
    DIV0NULL(INSTALL_FINAL_AMOUNT, INSTALL_DEVICE_COUNT) as INSTALL_COST_PER_DEVICE,
    SALES_REF_ID
from
    ibr_submissions_sums
      ;;
  }

  dimension: INSTALL_FINAL_AMOUNT {
    type: number
    sql: ${TABLE}.INSTALL_FINAL_AMOUNT ;;
  }

  dimension: INSTALL_DEVICE_COUNT {
    type: number
    sql:  ${TABLE}.INSTALL_DEVICE_COUNT ;;
  }

  dimension: INSTALL_COST_PER_DEVICE {
    type: number
    sql:  ${TABLE}.INSTALL_COST_PER_DEVICE ;;
  }

  dimension: SALES_REF_ID {
    type: string
    sql: ${TABLE}.SALES_REF_ID ;;
  }

}
