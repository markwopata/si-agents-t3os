view: cc_spend_receipt_costcapture {
    derived_table: {
      publish_as_db_view: yes
      sql:
          with costcapture_receipts as(
         SELECT
        p.submitted_at::DATE as timestamp
        ,p.grand_total as receipt_amount
        ,replace(replace(replace(c.value::string,'[',''),']',''),'"','') as upload_receipt
        ,su.email_address as email_address
        ,concat(u.first_name ,' ',u.last_name ) as employee_name
        ,p.account_type::TEXT as account_type
        ,p.notes::TEXT as additional_notes
        ,p.purchased_at::DATE as transaction_date
        ,u.email_address as employee_email_address
        ,concat(u.first_name ,' ',u.last_name ) as full_name
        FROM ES_WAREHOUSE.PURCHASES.PURCHASES p
        LEFT JOIN ES_WAREHOUSE.PUBLIC.users u
        on p.user_id=u.user_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.users su
        on p.submitted_by_user_id=su.user_id,
        lateral flatten(input=>split(IMAGE_URLS::STRING, ',')) c
      )
      select
      *
      from costcapture_receipts
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
