view: cardholder_status {
  derived_table: {
    sql:
select icctu.full_name
     , icctu.employee_id
     , icctu.card_type
     , icctu.corporate_account_number
     , icctu.corporate_account_name
     , case
           when icctu.status in ('Open', 'ACTIVE ACCOUNT', 'Open Account, no block or reclass')
               then 'Open'
           else 'Closed' end  as card_status
     , icctu.transaction_date as last_use
     , cd.work_email          as cardholder_email
     , case
           when cd.employee_status in ('Not in Payroll', 'Never Started', 'Inactive', 'Terminated') then 'Terminated'
           else 'Active' end  as employee_status
from analytics.intacct_models.int_credit_card_transactions_unioned icctu
         left join analytics.payroll.company_directory cd
                   on icctu.employee_id = cd.employee_id
qualify
    row_number() over (partition by icctu.employee_id,icctu.corporate_account_number order by icctu.transaction_date desc) =
    1
order by full_name, card_type, corporate_account_number

      ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: cardholder {
    type: string
    sql:concat(${full_name},' - ',${employee_id}) ;;
  }

  dimension: card_type {
    type: string
    sql: ${TABLE}."CARD_TYPE" ;;
  }

  dimension: corporate_account_number {
    type: string
    sql: ${TABLE}."CORPORATE_ACCOUNT_NUMBER" ;;
  }

  dimension: corporate_account_name {
    type: string
    sql: ${TABLE}."CORPORATE_ACCOUNT_NAME" ;;
  }

  dimension: card_status {
    type: string
    sql: ${TABLE}."CARD_STATUS" ;;
  }

  dimension: cardholder_email {
    type: string
    sql: ${TABLE}."CARDHOLDER_EMAIL" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
    suggest_persist_for: "1 minute"
  }


  dimension_group: last_use {
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
    sql: CAST(${TABLE}."LAST_USE" AS TIMESTAMP_NTZ) ;;
  }

}
