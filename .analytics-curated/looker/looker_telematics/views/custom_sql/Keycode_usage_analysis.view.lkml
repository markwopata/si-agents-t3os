view: Keycode_usage_analysis {
    derived_table: {
      sql: SELECT AKE.ASSET_KEYPAD_ENTRY_ID,
       CONVERT_TIMEZONE('America/Chicago', AKE.KEYPAD_TIMESTAMP) AS KEYPAD_TIMESTAMP,
       AKE.ASSET_ID,
       AKE.KEYPAD_CODE                                           AS KEYPAD_CODE_ENTERED,
       AKE.IS_SUCCESSFUL                                         AS ENTRY_SUCCESSFUL,
       TM.COMPANY_ID                                             AS OWNING_COMPANY_ID,
       TM.COMPANY_NAME                                           AS OWNING_COMPANY_NAME,
       TM.OWNERSHIP,
       TM.MARKET_ID                                              AS ASSET_MARKET_ID,
       TM.MARKET_NAME                                            AS ASSET_MARKET_NAME,
       C.COMPANY_ID                                              AS RENTING_COMPANY_ID,
       IFNULL(C.NAME, 'NOT ON RENT')                             AS RENTING_COMPANY_NAME,
       CKC.COMPANY_ID                                            AS COMPANY_KEYCODE_ID,
       CKC.NAME                                                  AS COMPANY_KEYCODE_NAME,
       APH.INVOICE_PURCHASE_DATE                                 AS ASSET_PURCHASE_DATE,
       CASE
           WHEN AKE.KEYPAD_CODE LIKE '125690' AND
                DATEADD(MONTH, -2, CURRENT_TIMESTAMP) >= APH.INVOICE_PURCHASE_DATE
               THEN 'MANUFACTURER CODE > 2 MONTHS'
           WHEN AKE.KEYPAD_CODE ILIKE ANY ('9090', '1234', '5050', '1776', '125690')
               THEN 'FORBIDDEN CODE'
           WHEN CKC.COMPANY_ID = 1854
               --AND RENTING_COMPANY_NAME <> 'NOT ON RENT'
               AND C.COMPANY_ID <> 1854
               THEN 'BRANCH CODE BY CUSTOMER'
           ELSE 'OKAY'
           END                                                   AS KEYCODE_USAGE_ANALYSIS,
       1                                                         AS COUNT
FROM ES_WAREHOUSE.PUBLIC.ASSET_KEYPAD_ENTRIES AKE
         LEFT JOIN BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__TELEMATICS_HEALTH TM
                   ON AKE.ASSET_ID = TM.ASSET_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY APH
                   ON AKE.ASSET_ID = APH.ASSET_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.RENTALS R
                   ON AKE.ASSET_ID = R.ASSET_ID
                       AND AKE.KEYPAD_TIMESTAMP BETWEEN R.START_DATE AND R.END_DATE
         LEFT JOIN ES_WAREHOUSE.PUBLIC.ORDERS O
                   ON R.ORDER_ID = O.ORDER_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS U
                   ON O.USER_ID = U.USER_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES C
                   ON TRY_TO_NUMBER(U.COMPANY_ID) = C.COMPANY_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_KEYPAD_CODES CKC
                   ON AKE.COMPANY_KEYPAD_CODE_ID = CKC.COMPANY_KEYPAD_CODE_ID
         LEFT JOIN ES_WAREHOUSE.PUBLIC.KEYPAD_CODES KC
                   ON CKC.KEYPAD_CODE_ID = KC.KEYPAD_CODE_ID
WHERE AKE.KEYPAD_TIMESTAMP >= DATEADD(YEAR, -1, CURRENT_TIMESTAMP)
  AND AKE.ASSET_ID IS NOT NULL
ORDER BY AKE.KEYPAD_TIMESTAMP DESC ;;
    }

    dimension: asset_keypad_entry_id {
      type: number
      sql: ${TABLE}."ASSET_KEYPAD_ENTRY_ID" ;;
    }

    dimension_group: keypad_timestamp {
      type: time
      sql: ${TABLE}."KEYPAD_TIMESTAMP" ;;
    }

    dimension: asset_id {
      type: string
      value_format_name: id
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: keypad_code {
      type: string
      sql: ${TABLE}."KEYPAD_CODE_ENTERED" ;;
    }

    dimension: entry_successful {
      type: yesno
      sql: ${TABLE}."ENTRY_SUCCESSFUL" ;;
    }

    dimension: owning_company_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."OWNING_COMPANY_ID" ;;
    }

    dimension: owning_company_name {
      type: string
      sql: ${TABLE}."OWNING_COMPANY_NAME" ;;
    }
    dimension: ownership {
      type: string
      sql: ${TABLE}."OWNERSHIP" ;;
    }
    dimension: asset_market_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."ASSET_MARKET_ID" ;;
    }

    dimension: asset_market_name {
      type: string
      sql: ${TABLE}."ASSET_MARKET_NAME" ;;
    }

    dimension: renting_company_id {
      type: number
      value_format_name: id
      sql: ${TABLE}."RENTING_COMPANY_ID" ;;
    }

    dimension: renting_company_name {
      type: string
      sql: ${TABLE}."RENTING_COMPANY_NAME" ;;
    }

  dimension: company_keycode_id {
    type: string
    sql: ${TABLE}."COMPANY_KEYCODE_ID" ;;
  }

  dimension: company_keycode_name {
    type: string
    sql: ${TABLE}."COMPANY_KEYCODE_NAME" ;;
  }

  dimension: ASSET_PURCHASE_DATE {
    type: string
    sql: ${TABLE}."ASSET_PURCHASE_DATE" ;;
  }

  dimension: keycode_usage_analysis {
    type: string
    sql: ${TABLE}."KEYCODE_USAGE_ANALYSIS" ;;
  }

    measure: count {
      type: sum
      sql: ${TABLE}."COUNT" ;;
      drill_fields: [detail*]
    }

    set: detail {
      fields: [
        asset_keypad_entry_id,
        keypad_timestamp_time,
        asset_id,
        keypad_code,
        entry_successful,
        owning_company_id,
        owning_company_name,
        asset_market_id,
        asset_market_name,
        renting_company_id,
        renting_company_name,
        company_keycode_id,
        company_keycode_name,
        count
      ]
    }
  }
