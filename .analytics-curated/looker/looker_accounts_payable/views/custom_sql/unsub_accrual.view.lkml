view: unsub_accrual {
  derived_table: {
    sql: WITH POD_CTE AS (
    SELECT DISTINCT DOCNO, DELIVERTO_CONTACTNAME
    FROM ANALYTICS.INTACCT.PODOCUMENT AS POD
    WHERE POD.T3_PR_CREATED_BY IS NULL
    AND POD.DOCPARID = 'Purchase Order'
    AND POD.PONUMBER NOT IN ('TBD','5')
),
DEDUPLICATED_POH AS (
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY PURCHASE_ORDER_NUMBER
            ORDER BY
                CASE
                    WHEN STATUS = 'Open' THEN 1
                    WHEN STATUS = 'Pending Approval' THEN 2
                    WHEN STATUS = 'Closed' THEN 3
                    ELSE 4
                END
        ) as status_priority
    FROM PROCUREMENT.PUBLIC.PURCHASE_ORDERS
),
-- This updated CTE ensures one row per DOCNO to prevent row duplication
PO_STATE_CTE AS (
    SELECT DOCNO, STATE
    FROM (
        SELECT
            DOCNO,
            STATE,
            -- Ranks the states for each document and prepares to select only one
            ROW_NUMBER() OVER(PARTITION BY DOCNO ORDER BY STATE) as rn
        FROM ANALYTICS.INTACCT.PODOCUMENT
    )
    -- Only keeps the #1 ranked row for each DOCNO
    WHERE rn = 1
),
main AS (
    SELECT UI.*, DAYNAME(COGNOS_DATE::DATE) AS DAYOFWEEK,POH.REQUESTING_BRANCH_ID::varchar AS BRANCH_ID ,MKT.NAME AS BRANCH_NAME
    FROM ANALYTICS.CONCUR.UNSUBMITTED_INVOICES_DB AS UI
    LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDERS AS POH ON UI.PURCHASE_ORDER_NUMBER::VARCHAR = POH.PURCHASE_ORDER_NUMBER::VARCHAR
    LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT ON POH.REQUESTING_BRANCH_ID::varchar = MKT.MARKET_ID::varchar
    WHERE UI.COGNOS_DATE IS NOT NULL
    AND MKT.NAME IS NOT NULL
    AND (POH.PURCHASE_ORDER_NUMBER >= 300000 OR POH.PURCHASE_ORDER_NUMBER IS NULL)

    UNION ALL

    SELECT UI.*, DAYNAME(COGNOS_DATE::DATE) AS DAYOFWEEK,POH.REQUESTING_BRANCH_ID::varchar AS BRANCH_ID ,MKT.NAME AS BRANCH_NAME
    FROM ANALYTICS.CONCUR.UNSUBMITTED_INVOICES_DB AS UI
    LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDERS AS POH ON UI.PURCHASE_ORDER_NUMBER::VARCHAR = POH.PURCHASE_ORDER_NUMBER::VARCHAR
    LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT ON POH.REQUESTING_BRANCH_ID::varchar = MKT.MARKET_ID::varchar
    LEFT JOIN POD_CTE AS POD ON UI.PURCHASE_ORDER_NUMBER::VARCHAR = POD.DOCNO::VARCHAR
    LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT AS D ON POD.DELIVERTO_CONTACTNAME = D.UD_ASSOCIATED_DELIVER_TO_CONTACT
    LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT2 ON D.DEPARTMENTID::VARCHAR = MKT2.MARKET_ID::VARCHAR
    WHERE UI.COGNOS_DATE IS NOT NULL
    AND MKT.NAME IS NULL
    AND MKT2.NAME IS NOT NULL
    AND (POH.PURCHASE_ORDER_NUMBER >= 300000 OR POH.PURCHASE_ORDER_NUMBER IS NULL)

    UNION ALL

    SELECT UI.*, DAYNAME(COGNOS_DATE::DATE) AS DAYOFWEEK,D.DEPARTMENTID::varchar AS BRANCH_ID ,MKT2.NAME AS BRANCH_NAME
    FROM ANALYTICS.CONCUR.UNSUBMITTED_INVOICES_DB AS UI
    LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDERS AS POH ON UI.PURCHASE_ORDER_NUMBER::VARCHAR = POH.PURCHASE_ORDER_NUMBER::VARCHAR
    LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT ON POH.REQUESTING_BRANCH_ID::varchar = MKT.MARKET_ID::varchar
    LEFT JOIN POD_CTE AS POD ON UI.PURCHASE_ORDER_NUMBER::VARCHAR = POD.DOCNO::VARCHAR
    LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT AS D ON POD.DELIVERTO_CONTACTNAME = D.UD_ASSOCIATED_DELIVER_TO_CONTACT
    LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT2 ON D.DEPARTMENTID::VARCHAR = MKT2.MARKET_ID::VARCHAR
    WHERE UI.COGNOS_DATE IS NOT NULL
    AND MKT.NAME IS NULL
    AND MKT2.NAME IS NULL
    AND (POH.PURCHASE_ORDER_NUMBER >= 300000 OR POH.PURCHASE_ORDER_NUMBER IS NULL)

    UNION ALL

    SELECT DISTINCT UI.*, DAYNAME(COGNOS_DATE::DATE) AS DAYOFWEEK, NULL AS BRANCH_ID , NULL AS BRANCH_NAME
    FROM ANALYTICS.CONCUR.UNSUBMITTED_INVOICES_DB AS UI
    LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDERS AS POH ON UI.PURCHASE_ORDER_number::VARCHAR = POH.PURCHASE_ORDER_NUMBER::VARCHAR
    LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MKT ON POH.REQUESTING_BRANCH_ID::varchar = MKT.MARKET_ID::varchar
    WHERE UI.COGNOS_DATE IS NOT NULL
    AND MKT.NAME IS NOT NULL
    AND POH.PURCHASE_ORDER_NUMBER < 300000
),
RAW_DATA_WITH_RN AS (
    SELECT
        CONCAT(CPT.PREFIX,'PO',POL.COMPANY_PURCHASE_ORDER_ID,'-',POL.COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER) AS ORDER_NUMBER,
        C1.NAME AS VENDOR_NAME,
        BS.NAME AS BUSINESS_SEGMENT,
        ASSETS.ASSET_CLASS AS CLASS,
        ASSETS.MAKE,
        ASSETS.MODEL,
        POL.YEAR,
        POL.FACTORY_BUILD_SPECIFICATIONS,
        POL.ATTACHMENTS,
        ROUND(POL.NET_PRICE, 2) AS NET_PRICE,
        POL.QUANTITY,
        ROUND(POL.NET_PRICE * POL.QUANTITY, 2) AS EXTENDED_PRICE,
        MK.NAME AS MARKET,
        NBV.COMPANY_NAME AS OWNER,
        POL.RELEASE_DATE,
        POL.ORDER_STATUS,
        POL.ORIGINAL_PROMISE_DATE,
        POL.CURRENT_PROMISE_DATE,
        POL.ASSET_ID AS ASSET_ID,
        POL.SERIAL,
        ROUND(POL.FREIGHT_COST, 2) AS FREIGHT_COST,
        POL.REBATE,
        POL.SALES_TAX,
        POL.AFTERMARKET_OEC,
        COALESCE(POL.NET_PRICE, 0) + COALESCE(POL.FREIGHT_COST, 0) + COALESCE(POL.SALES_TAX, 0) - COALESCE(POL.REBATE, 0) AS TOTAL_OEC,
        ROUND(NBV.NBV, 2) AS NET_BOOK_VALUE,
        POL.INVOICE_NUMBER,
        POL.INVOICE_DATE,
        POL.DUE_DATE,
        POL.INVOICE_DUE_DATE,
        CASE
            WHEN POL.PAID_DATE IS NOT NULL THEN DATEDIFF(DAY, POL.PAID_DATE, POL.DUE_DATE)
            ELSE DATEDIFF(DAY, CURRENT_DATE(), POL.DUE_DATE)
        END AS DAYS_TIL_DUE,
        POL.PENDING_SCHEDULE,
        NBV.SCHEDULE AS FINANCIAL_SCHEDULE,
        POL.FINANCE_STATUS,
        POL.RECONCILIATION_STATUS,
        POL.RECONCILIATION_STATUS_DATE,
        POL.NOTE,
        POL.SAGE_RECORD_ID,
        POL.PAID_DATE,
        TO_CHAR(POL.PAID_DATE, 'Mon-YYYY') AS MONTH_YEAR_PAID,
        'Week of ' || TO_CHAR(DATEADD(DAY, -4, POL.WEEK_TO_BE_PAID), 'Mon DD') AS WEEK_TO_BE_PAID_ON,
        POL.PAYMENT_TYPE,
        ROW_NUMBER() OVER (
            PARTITION BY POL.ASSET_ID, CONCAT(CPT.PREFIX, 'PO', POL.COMPANY_PURCHASE_ORDER_ID, '-', POL.COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER)
            ORDER BY POL.COMPANY_PURCHASE_ORDER_ID
        ) AS rn
    FROM
        ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS AS POL
    LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS AS PO ON POL.COMPANY_PURCHASE_ORDER_ID = PO.COMPANY_PURCHASE_ORDER_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_TYPES AS CPT ON PO.COMPANY_PURCHASE_ORDER_TYPE_ID = CPT.COMPANY_PURCHASE_ORDER_TYPE_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C1 ON PO.VENDOR_ID = C1.COMPANY_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS AS ASSETS ON POL.ASSET_ID = ASSETS.ASSET_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_MODELS AS MODELS ON POL.EQUIPMENT_MODEL_ID = MODELS.EQUIPMENT_MODEL_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES_MODELS_XREF AS MXREF ON MODELS.EQUIPMENT_MODEL_ID = MXREF.EQUIPMENT_MODEL_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES AS EC ON COALESCE(MXREF.EQUIPMENT_CLASS_ID, POL.EQUIPMENT_CLASS_ID) = EC.EQUIPMENT_CLASS_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS AS BS ON EC.BUSINESS_SEGMENT_ID = BS.BUSINESS_SEGMENT_ID
    LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MK ON POL.MARKET_ID = MK.MARKET_ID
    LEFT JOIN ANALYTICS.DEBT.ASSET_NBV_ALL_OWNERS AS NBV ON POL.ASSET_ID = NBV.ASSET_ID
),
ft_lines AS (
    SELECT
        ORDER_NUMBER,
        SUBSTR(ORDER_NUMBER, 4) AS purchase_order_number,
        VENDOR_NAME,
        BUSINESS_SEGMENT,
        CLASS,
        MAKE,
        MODEL,
        YEAR,
        FACTORY_BUILD_SPECIFICATIONS,
        ATTACHMENTS,
        NET_PRICE,
        QUANTITY,
        EXTENDED_PRICE,
        MARKET,
        OWNER,
        RELEASE_DATE,
        ORDER_STATUS,
        ORIGINAL_PROMISE_DATE,
        CURRENT_PROMISE_DATE,
        ASSET_ID,
        SERIAL,
        FREIGHT_COST,
        REBATE,
        SALES_TAX,
        AFTERMARKET_OEC,
        TOTAL_OEC,
        NET_BOOK_VALUE,
        INVOICE_NUMBER,
        INVOICE_DATE,
        DUE_DATE,
        INVOICE_DUE_DATE,
        DAYS_TIL_DUE,
        PENDING_SCHEDULE,
        FINANCIAL_SCHEDULE,
        FINANCE_STATUS,
        RECONCILIATION_STATUS,
        RECONCILIATION_STATUS_DATE,
        NOTE,
        SAGE_RECORD_ID,
        PAID_DATE,
        MONTH_YEAR_PAID,
        WEEK_TO_BE_PAID_ON,
        PAYMENT_TYPE
    FROM RAW_DATA_WITH_RN
    WHERE rn = 1
),
ft_lines_to_flag AS (
    SELECT *
    FROM main
    WHERE CAST(cognos_date AS DATE) = CURRENT_DATE()
    AND purchase_order_number IN (SELECT purchase_order_number FROM ft_lines)
),
main_plus_flag_and_status as (
    SELECT
        m.*,
        CASE
            WHEN ftf.PURCHASE_ORDER_NUMBER IS NULL THEN FALSE
            ELSE TRUE
        END AS po_exists_in_fleet_track,
        poh.STATUS AS PURCHASE_ORDER_STATUS,
        pos.STATE
    FROM main AS m
    LEFT JOIN ft_lines_to_flag AS ftf
        ON m.PURCHASE_ORDER_NUMBER = ftf.PURCHASE_ORDER_NUMBER
    LEFT JOIN DEDUPLICATED_POH as poh
        ON m.PURCHASE_ORDER_NUMBER::VARCHAR = poh.PURCHASE_ORDER_NUMBER::VARCHAR
        AND poh.status_priority = 1
    LEFT JOIN PO_STATE_CTE as pos
        ON m.PURCHASE_ORDER_NUMBER::VARCHAR = pos.DOCNO::VARCHAR
    WHERE
        CAST(m.COGNOS_DATE AS DATE) = CURRENT_DATE()
)
-- Final SELECT statement
SELECT DISTINCT * FROM main_plus_flag_and_status
    ;;
  }

  dimension: request_name {
    type: string
    sql: ${TABLE}.REQUEST_NAME ;;
  }

  dimension: employee_last_name {
    type: string
    sql: ${TABLE}.EMPLOYEE_LAST_NAME ;;
  }

  dimension: supplier_name{
    type: string
    sql: ${TABLE}.SUPPLIER_NAME ;;
  }

  dimension: invoice_received {
    type: string
    sql: ${TABLE}.INVOICE_RECEIVED ;;
  }

  dimension: origin_source {
    type: string
    sql: ${TABLE}.ORIGIN_SOURCE ;;
  }

  dimension: approval_status {
    type: string
    sql: ${TABLE}.APPROVAL_STATUS ;;
  }

  dimension: payment_status {
    type: string
    sql: ${TABLE}.PAYMENT_STATUS ;;
  }

  dimension: request_total {
    type: number
    sql: ${TABLE}.REQUEST_TOTAL ;;
  }

  dimension: supplier_invoice_number {
    type: string
    sql: ${TABLE}.SUPPLIER_INVOICE_NUMBER ;;
  }

  dimension: submit_date {
    type: date
    sql: ${TABLE}.SUBMIT_DATE ;;
  }

  dimension: policy {
    type: string
    sql: ${TABLE}.POLICY ;;
  }

  dimension: invoice_received_date {
    type: date
    sql: ${TABLE}.INVOICE_RECEIVED_DATE ;;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}.PURCHASE_ORDER_NUMBER ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}.INVOICE_DATE ;;
  }

  dimension: custom_1_name {
    type: string
    sql: ${TABLE}.CUSTOM_1_NAME ;;
  }

  dimension: non_inventory {
    type: string
    sql: ${TABLE}.NON_INVENTORY ;;
  }

  dimension: supplier_code {
    type: string
    sql: ${TABLE}.SUPPLIER_CODE ;;
    }

  dimension: custom_1_location {
    type: string
    sql: ${TABLE}.CUSTOM_1_LOCATION ;;
  }

  dimension: cognos_date {
    type: date
    sql: ${TABLE}.COGNOS_DATE ;;
  }

  dimension: employee_email_address {
    type: string
    sql: ${TABLE}.EMPLOYEE_EMAIL_ADDRESS ;;
  }

  dimension: _es_update_timestamp {
    type: date
    sql: ${TABLE}._ES_UPDATE_TIMESTAMP ;;
  }

  dimension: service_type {
    type: string
    sql: ${TABLE}.SERVICE_TYPE ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}.TERMS ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.VENDOR_NAME ;;
  }

  dimension: revised_terms {
    type: string
    sql: ${TABLE}.REVISED_TERMS ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}.DUE_DATE ;;
  }

  dimension: days_past_due {
    type: string
    sql: ${TABLE}.DAYS_PAST_DUE ;;
  }

  dimension: past_due_bucket {
    type: string
    sql: ${TABLE}.PAST_DUE_BUCKET ;;
  }

  dimension: inventory_reporting_category {
    type: string
    sql: ${TABLE}.INVENTORY_REPORTING_CATEGORY ;;
  }

  dimension: dayofweek {
    type: string
    sql: ${TABLE}.DAYOFWEEK ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}.BRANCH_ID ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}.BRANCH_NAME ;;
  }

  dimension: po_exists_in_fleet_track {
    type: string
    sql: ${TABLE}.PO_EXISTS_IN_FLEET_TRACK ;;
    }

  dimension: t3_status {
    type: string
    sql: ${TABLE}.PURCHASE_ORDER_STATUS ;;
  }

  dimension: PO_State{
    type: string
    sql: ${TABLE}.STATE ;;
  }

  dimension_group: bill {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.invoice_date ;;
  }

  measure : bill_amount {
    type: number
    drill_fields: [drill_details*]
    value_format: "$#,##0"
    sql: sum(${TABLE}.REQUEST_TOTAL) ;;
  }

    set: drill_details {
      fields: [branch_id, branch_name, employee_last_name, supplier_code, supplier_name, supplier_invoice_number, origin_source, approval_status, payment_status, invoice_received_date, purchase_order_number, invoice_date, inventory_reporting_category, revised_terms, due_date, request_total, po_exists_in_fleet_track
        , p2p_entry_que_any_status.status, t3_status, PO_State
        ]
    }
  }
