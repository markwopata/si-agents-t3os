view: cc_spend_receipt_upload {
  derived_table: {
    publish_as_db_view: yes
    sql:
    with consolidate_receipts as(
select
*
,CASE WHEN TRIM(LOWER(employee_email_address)) NOT LIKE '%equipmentshare.com%' THEN email_address else employee_email_address end as correct_email_address
,ROW_NUMBER() OVER (PARTITION BY receipt_amount,employee_name,transaction_date, additional_notes  ORDER BY timestamp  DESC) AS rn
from analytics.gs.cc_spend_receipt_upload csru
order by timestamp
)
, old_receipts as(
select
timestamp::DATE as timestamp
,receipt_amount
,upload_receipt
,1 as receipt_page
,'Google_Form' as receipt_source
,u.email_address::TEXT as email_address
,employee_name::TEXT as employee_name
,account_type::TEXT as account_type
,additional_notes::TEXT as additional_notes
,transaction_date::DATE as transaction_date
,employee_email_address::TEXT as employee_email_address
,concat(u.first_name ,' ',u.last_name ) as full_name
,cd.employee_id as user_id
,null as card_type
from consolidate_receipts c
left join ES_WAREHOUSE.PUBLIC.users u
on  correct_email_address =u.email_address
left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
on u.email_address = cd.work_email
order by timestamp desc
)
, new_receipts as(
   SELECT
  p.submitted_at::DATE as timestamp
  ,p.grand_total as receipt_amount
  ,replace(replace(replace(c.value::string,'[',''),']',''),'"','') as upload_receipt
  ,(c.index + 1) as receipt_page
  ,'Cost_Capture' as receipt_source
  ,su.email_address as email_address
  ,concat(u.first_name ,' ',u.last_name ) as employee_name
  ,p.account_type::TEXT as account_type
  ,p.notes::TEXT as additional_notes
  ,p.purchased_at::DATE as transaction_date
  ,u.email_address as employee_email_address
  ,concat(u.first_name ,' ',u.last_name ) as full_name
  ,u.user_id as user_id
  ,p.account_type as card_type
  FROM PROCUREMENT.PUBLIC.PURCHASES p
  LEFT JOIN ES_WAREHOUSE.PUBLIC.users u
  on p.user_id=u.user_id
  LEFT JOIN ES_WAREHOUSE.PUBLIC.users su
  on p.submitted_by_user_id=su.user_id,
  lateral flatten(input=>split(IMAGE_URLS::STRING, ',')) c
)
select
*
from old_receipts
union all
select
*
from new_receipts
      ;;
  }

  dimension: additional_notes {
    type: string
    sql: ${TABLE}."ADDITIONAL_NOTES" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_name {
    type: string
    sql: TRIM(UPPER(${TABLE}."EMPLOYEE_NAME")) ;;
  }

  dimension: full_name {
    type: string
    sql: UPPER(TRIM(${TABLE}."FULL_NAME")) ;;
  }

  dimension: employee_email_address {
    type: string
    sql: CASE WHEN TRIM(LOWER(${TABLE}."EMPLOYEE_EMAIL_ADDRESS")) NOT LIKE '%equipmentshare.com%'
        THEN ${email_address}
        ELSE ${TABLE}."EMPLOYEE_EMAIL_ADDRESS" END ;;
  }

  dimension: receipt_amount {
    type: number
    sql: ${TABLE}."RECEIPT_AMOUNT"::NUMERIC(20,2) ;;
  }

  dimension_group: timestamp {
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
    sql: ${TABLE}."TIMESTAMP"::DATE;;
  }


  dimension: upload_receipt {
    type: string
    sql: ${TABLE}."UPLOAD_RECEIPT" ;;
  }

  dimension: receipt_page {
    type: number
    sql: ${TABLE}."RECEIPT_PAGE" ;;
  }

  dimension: receipt_source {
    type: string
    sql: ${TABLE}."RECEIPT_SOURCE" ;;
  }

  dimension: link_to_receipt {
    type: string
    html: <font color="blue "><u><a href ="{{upload_receipt._value}}"target="_blank">Link to CC Receipt</a></font></u> ;;
    sql: ${upload_receipt} ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }


  dimension_group: transaction_date {
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
    sql: ${TABLE}."TRANSACTION_DATE" ;;
  }

  dimension: card_type {
    type: string
    sql: CASE WHEN ${TABLE}."CARD_TYPE" is null then null
              WHEN ${TABLE}."CARD_TYPE" = 'CENTRAL' then 'central_bank'
              WHEN ${TABLE}."CARD_TYPE" = 'FUEL' then 'fuel_card'
              ELSE LOWER(LEFT(${TABLE}."CARD_TYPE", 4))
         END ;;
  }

  measure: count {
    type: count
    drill_fields: [employee_name]
  }

}
