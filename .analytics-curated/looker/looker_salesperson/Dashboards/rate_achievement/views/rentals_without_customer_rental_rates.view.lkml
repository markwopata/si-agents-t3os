view: rentals_without_customer_rental_rates {

    derived_table: {
      sql:
WITH rentals_without_active_crr AS (
    SELECT
        r.RENTAL_ID,
        li.INVOICE_ID,
        c.COMPANY_ID,
        c.NAME AS COMPANY_NAME,
        r.EQUIPMENT_CLASS_ID,
        ec.NAME AS EQUIPMENT_CLASS_NAME,
        m.market_id as branch_id,
        m.name as branch_name,
        r.START_DATE as rental_start_date,
        r.END_DATE as rental_end_date,
        i.BILLING_APPROVED_DATE::DATE as BILLING_APPROVED_DATE,
        li.AMOUNT,
        i.SALESPERSON_USER_ID as Salesperson_ID,
        concat(trim(u.FIRST_NAME), ' ', trim(u.LAST_NAME)) as Salesperson_Name,
        u.EMAIL_ADDRESS as salesperson_email_address
        -- Expected rate active window
--         crr.DATE_CREATED,
--         crr.DATE_VOIDED,
--         crr.END_DATE AS crr_end_date,
--         IFF(
--             crr.DATE_CREATED < crr.END_DATE AND crr.DATE_VOIDED > crr.END_DATE,
--             crr.END_DATE,
--             IFF(
--                 crr.DATE_CREATED > crr.END_DATE,
--                 COALESCE(crr.DATE_VOIDED, '9999-12-31'),
--                 COALESCE(crr.DATE_VOIDED, crr.END_DATE, '9999-12-31')
--             )
--         ) AS RATE_END_DATE,
--         row_number() OVER (PARTITION BY r.RENTAL_ID, EQUIPMENT_CLASS_NAME order by BILLING_APPROVED_DATE desc) as row_num
    FROM ES_WAREHOUSE.PUBLIC.RENTALS r
    JOIN analytics.public.v_LINE_ITEMS li ON r.RENTAL_ID = li.RENTAL_ID
    JOIN es_warehouse.PUBLIC.MARKETS m ON li.branch_ID = m.MARKET_ID
    JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON i.INVOICE_ID = li.INVOICE_ID
    JOIN ES_WAREHOUSE.PUBLIC.COMPANIES c ON i.COMPANY_ID = c.COMPANY_ID
    JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec ON r.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
    left join ES_WAREHOUSE.PUBLIC.USERS u on i.SALESPERSON_USER_ID = u.USER_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_RENTAL_RATES crr
        ON c.COMPANY_ID = crr.COMPANY_ID
       AND r.EQUIPMENT_CLASS_ID = crr.EQUIPMENT_CLASS_ID
       AND i.BILLING_APPROVED_DATE BETWEEN crr.DATE_CREATED AND
           IFF(
               crr.DATE_CREATED < crr.END_DATE AND crr.DATE_VOIDED > crr.END_DATE,
               crr.END_DATE,
               IFF(
                   crr.DATE_CREATED > crr.END_DATE,
                   COALESCE(crr.DATE_VOIDED, '9999-12-31'),
                   COALESCE(crr.DATE_VOIDED, crr.END_DATE, '9999-12-31')
               )
           )
    WHERE li.LINE_ITEM_TYPE_ID = 8
      AND crr.COMPANY_ID IS NULL  -- No active customer rental rate
    AND r.END_DATE::DATE > CURRENT_DATE()
    and m.COMPANY_ID = 1854
)

SELECT *
FROM rentals_without_active_crr
qualify row_number() OVER (PARTITION BY RENTAL_ID, EQUIPMENT_CLASS_NAME order by BILLING_APPROVED_DATE desc) = 1
  ;;
    }

  dimension: amount {
    type: number
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }
  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
  }

  dimension: salesperson_id {
    type: string
    sql: ${TABLE}."SALESPERSON_ID" ;;
  }
  dimension: salesperson_email_address {
    type: string
    sql: ${TABLE}."SALESPERSON_EMAIL_ADDRESS" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: salesperson_name {
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }
  dimension_group: rental_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_START_DATE" ;;
  }
  dimension_group: rental_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  measure: monthly_revenue {
    type: sum
    value_format: "$#,##0"         # Dollars with 2 decimals ($123.00)
    sql: ${TABLE}."AMOUNT" ;;
  }


  }
