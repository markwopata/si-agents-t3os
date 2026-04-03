view: cc_spend_receipt_google {
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
      ,u.email_address::TEXT as email_address
      ,employee_name::TEXT as employee_name
      ,account_type::TEXT as account_type
      ,additional_notes::TEXT as additional_notes
      ,transaction_date::DATE as transaction_date
      ,employee_email_address::TEXT as employee_email_address
      ,concat(u.first_name ,' ',u.last_name ) as full_name
      from consolidate_receipts c
      left join ES_WAREHOUSE.PUBLIC.users u
      on  correct_email_address =u.email_address
      order by timestamp desc
      )
      select
      *
      from old_receipts
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


    dimension: link_to_receipt {
      type: string
      html: <font color="blue "><u><a href ="{{upload_receipt._value}}"target="_blank">Link to CC Receipt</a></font></u> ;;
      sql: ${upload_receipt} ;;
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

    measure: count {
      type: count
      drill_fields: [employee_name]
    }

  }
