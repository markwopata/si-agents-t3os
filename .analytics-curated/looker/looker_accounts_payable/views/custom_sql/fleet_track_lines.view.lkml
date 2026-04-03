view: fleet_track_lines {
  derived_table: {
    sql:
WITH main AS (
  SELECT DISTINCT
    CPT.PREFIX,
    CONCAT(CPT.PREFIX,'PO',POL.COMPANY_PURCHASE_ORDER_ID,'-',POL.COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER) AS ORDER_NUMBER,
    C1.NAME AS VENDOR_NAME,
    BS.NAME AS BUSINESS_SEGMENT,
    EC.NAME AS CLASS,
    EMA.NAME AS MAKE,
    EMO.NAME AS MODEL,
    POL.YEAR,
    POL.FACTORY_BUILD_SPECIFICATIONS,
    POL.ATTACHMENTS,
    ROUND(POL.NET_PRICE, 2) AS NET_PRICE,
    POL.QUANTITY,
    ROUND(POL.NET_PRICE * POL.QUANTITY, 2) AS EXTENDED_PRICE,
    MK.NAME AS MARKET,
    POL.MARKET_ID,
    POL.RELEASE_DATE,
    POL.ORDER_STATUS,
    PO.SUBMITTED_BY_USER_ID,
    POL.ORIGINAL_PROMISE_DATE,
    POL.CURRENT_PROMISE_DATE,
    POL.ASSET_ID,
    POL.VIN,
    POL.SERIAL,
    ROUND(POL.FREIGHT_COST, 2) AS FREIGHT_COST,
    POL.REBATE,
    POL.SALES_TAX,
    POL.AFTERMARKET_OEC,
    COALESCE(POL.NET_PRICE, 0) + COALESCE(POL.FREIGHT_COST, 0) + COALESCE(POL.SALES_TAX, 0) - COALESCE(POL.REBATE, 0) AS TOTAL_OEC,
    POL.INVOICE_NUMBER,
    POL.INVOICE_DATE,
    DATEDIFF(DAY, POL.INVOICE_DATE, CURRENT_DATE()) AS DAYS_IN_TRANSIT,
    POL.DUE_DATE,
    POL.INVOICE_DUE_DATE,
    CASE
      WHEN POL.PAID_DATE IS NOT NULL THEN DATEDIFF(DAY, POL.PAID_DATE, POL.DUE_DATE)
      ELSE DATEDIFF(DAY, CURRENT_DATE(), POL.DUE_DATE)
    END AS DAYS_TIL_DUE,
    POL.PENDING_SCHEDULE,
    POL.FINANCE_STATUS,
    POL.RECONCILIATION_STATUS,
    POL.RECONCILIATION_STATUS_DATE,
    POL.NOTE,
    POL.SAGE_RECORD_ID,
    POL.PAID_DATE,
    TO_CHAR(POL.PAID_DATE, 'Mon-YYYY') AS MONTH_YEAR_PAID,
    'Week of ' || TO_CHAR(DATEADD(DAY, -4, POL.WEEK_TO_BE_PAID), 'Mon DD') AS WEEK_TO_BE_PAID_ON,
    POL.PAYMENT_TYPE,
    ASSETS.TRACKER_ID IS NOT NULL AS TRACKER_CHECK,
    POL.DELETED_AT
  FROM ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS AS POL
  LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS AS PO
    ON POL.COMPANY_PURCHASE_ORDER_ID = PO.COMPANY_PURCHASE_ORDER_ID
  LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_TYPES AS CPT
    ON PO.COMPANY_PURCHASE_ORDER_TYPE_ID = CPT.COMPANY_PURCHASE_ORDER_TYPE_ID
  LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C1
    ON PO.VENDOR_ID = C1.COMPANY_ID
  LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS AS ASSETS
    ON POL.ASSET_ID = ASSETS.ASSET_ID
  /* models/makes — keep ONE models join */
  LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_MODELS AS EMO
    ON POL.EQUIPMENT_MODEL_ID = EMO.EQUIPMENT_MODEL_ID
  LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_MAKES AS EMA
    ON EMO.EQUIPMENT_MAKE_ID = EMA.EQUIPMENT_MAKE_ID
  /* class/segment — keep ONE xref and ONE classes join, reuse for both CLASS & BUSINESS_SEGMENT */
  LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES_MODELS_XREF AS XREF
    ON POL.EQUIPMENT_MODEL_ID = XREF.EQUIPMENT_MODEL_ID
  LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES AS EC
    ON COALESCE(XREF.EQUIPMENT_CLASS_ID, POL.EQUIPMENT_CLASS_ID) = EC.EQUIPMENT_CLASS_ID
  LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS AS BS
    ON EC.BUSINESS_SEGMENT_ID = BS.BUSINESS_SEGMENT_ID
  LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS AS MK
    ON POL.MARKET_ID = MK.MARKET_ID
  WHERE POL.DELETED_AT IS NULL
)
SELECT main.*, users.username
FROM main
LEFT JOIN es_warehouse.public.users
  ON main.SUBMITTED_BY_USER_ID = users.user_id
    ;;
  }
  dimension: purchase_requester {
    type: string
    sql: ${TABLE}.username ;;
  }
  dimension: prefix {
    type: string
    sql: ${TABLE}.PREFIX ;;
  }

  dimension: order_number {
    type: string
    sql: ${TABLE}.ORDER_NUMBER ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.VENDOR_NAME ;;
  }

  dimension: business_segment {
    type: string
    sql: ${TABLE}.BUSINESS_SEGMENT ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}.CLASS ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.MAKE ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.MODEL ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}.YEAR ;;
  }

  dimension: factory_build_specifications {
    type: string
    sql: ${TABLE}.FACTORY_BUILD_SPECIFICATIONS ;;
  }

  dimension: attachments {
    type: string
    sql: ${TABLE}.ATTACHMENTS ;;
  }

  dimension: net_price {
    type: number
    sql: ${TABLE}.NET_PRICE ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.QUANTITY ;;
  }

  dimension: extended_price {
    type: number
    sql: ${TABLE}.EXTENDED_PRICE ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}.MARKET ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.MARKET_ID ;;
  }

  dimension_group: release {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.RELEASE_DATE ;;
  }

  dimension: order_status {
    type: string
    sql: ${TABLE}.ORDER_STATUS ;;
  }

  dimension: submitted_by_user_id {
    type: number
    sql: ${TABLE}.SUBMITTED_BY_USER_ID ;;
  }

  dimension_group: original_promise {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.ORIGINAL_PROMISE_DATE ;;
  }

  dimension_group: current_promise {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.CURRENT_PROMISE_DATE ;;
  }

  dimension: serial {
    type: string
    sql: ${TABLE}.SERIAL ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}.VIN ;;
  }

  dimension: freight {
    type: number
    sql: ${TABLE}.FREIGHT_COST ;;
  }

  dimension: rebate {
    type: number
    sql: ${TABLE}.REBATE ;;
  }

  dimension: sales_tax {
    type: number
    sql: ${TABLE}.SALES_TAX ;;
  }

  dimension: aftermarket_oec {
    type: number
    sql: ${TABLE}.AFTERMARKET_OEC ;;
  }

  dimension: total_oec {
    type: number
    sql: ${TABLE}.TOTAL_OEC ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}.INVOICE_NUMBER ;;
  }

  dimension_group: invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.INVOICE_DATE ;;
  }

  dimension: days_in_transit {
    type: number
    sql: ${TABLE}.DAYS_IN_TRANSIT ;;
  }

  dimension_group: due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.DUE_DATE ;;
  }

  dimension_group: invoice_due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.INVOICE_DUE_DATE ;;
  }

  dimension: days_til_due {
    type: number
    sql: ${TABLE}.DAYS_TIL_DUE ;;
  }

  dimension: pending_schedule {
    type: string
    sql: ${TABLE}.PENDING_SCHEDULE ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}.FINANCE_STATUS ;;
  }

  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}.RECONCILIATION_STATUS ;;
  }

  dimension_group: reconciliation_status {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.RECONCILIATION_STATUS_DATE ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}.NOTE ;;
  }

  dimension: sage_record_id {
    type: string
    sql: ${TABLE}.SAGE_RECORD_ID ;;
  }

  dimension_group: paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.PAID_DATE ;;
  }

  dimension: month_year_paid {
    type: string
    sql: ${TABLE}.MONTH_YEAR_PAID ;;
  }

  dimension: week_to_be_paid_on {
    type: string
    sql: ${TABLE}.WEEK_TO_BE_PAID_ON ;;
  }

  dimension: payment_type {
    type: string
    sql: ${TABLE}.PAYMENT_TYPE ;;
  }

  dimension: tracker_check {
    type: yesno
    sql: ${TABLE}.TRACKER_CHECK ;;
  }

  dimension: po_class_filter {
    type: string
    label: "PO Class Filter"
    sql:
    CASE
      -- Case A1: SPOs, shipped, due this month
      WHEN ${TABLE}.PREFIX = 'S'
       AND ${TABLE}.ORDER_STATUS = 'Shipped'
       AND DATE_TRUNC('month', ${TABLE}.DUE_DATE) = DATE_TRUNC('month', CURRENT_DATE())
      THEN 'Case A - SPO'
      -- Case A2: VPOs, shipped, due this month (specific vendors only)
      WHEN ${TABLE}.PREFIX = 'V'
       AND ${TABLE}.ORDER_STATUS = 'Shipped'
       AND DATE_TRUNC('month', ${TABLE}.DUE_DATE) = DATE_TRUNC('month', CURRENT_DATE())
       AND ${TABLE}.VENDOR_NAME IN ('Mi-T-M Corporation', 'FNA Group Inc')
      THEN 'Case A - VPO'
      -- Case B1: SPOs, shipped, invoice older than 21 days
      WHEN ${TABLE}.PREFIX = 'S'
       AND ${TABLE}.ORDER_STATUS = 'Shipped'
       AND ${TABLE}.INVOICE_DATE <= DATEADD(day, -21, CURRENT_DATE())
      THEN 'Case B - SPO'
      -- Case B2: VPOs, shipped, invoice older than 21 days (specific vendors only)
      WHEN ${TABLE}.PREFIX = 'V'
       AND ${TABLE}.ORDER_STATUS = 'Shipped'
       AND ${TABLE}.INVOICE_DATE <= DATEADD(day, -21, CURRENT_DATE())
       AND ${TABLE}.VENDOR_NAME IN ('Mi-T-M Corporation', 'FNA Group Inc')
      THEN 'Case B - VPO'
      -- Case C: SPOs missing serial, shipped
      WHEN ${TABLE}.PREFIX = 'S'
       AND ${TABLE}.ORDER_STATUS = 'Shipped'
       AND (${TABLE}.SERIAL IS NULL OR TRIM(${TABLE}.SERIAL) = '')
       AND ${TABLE}.INVOICE_NUMBER IS NOT NULL
      THEN 'Case C'
      -- Case D: VPOs missing VIN, shipped (specific vendors only)
      WHEN ${TABLE}.PREFIX = 'V'
       AND ${TABLE}.ORDER_STATUS = 'Shipped'
       AND (${TABLE}.VIN IS NULL OR TRIM(${TABLE}.VIN) = '')
       AND ${TABLE}.INVOICE_NUMBER IS NOT NULL
       AND ${TABLE}.VENDOR_NAME IN ('Mi-T-M Corporation', 'FNA Group Inc')
      THEN 'Case D'
      -- Case E1: SPOs, shipped, due next month
      WHEN ${TABLE}.PREFIX = 'S'
       AND ${TABLE}.ORDER_STATUS = 'Shipped'
       AND DATE_TRUNC('month', ${TABLE}.DUE_DATE) = DATE_TRUNC('month', DATEADD(month, 1, CURRENT_DATE()))
      THEN 'Case E - SPO'
      -- Case E2: VPOs, shipped, due next month (specific vendors only)
      WHEN ${TABLE}.PREFIX = 'V'
       AND ${TABLE}.ORDER_STATUS = 'Shipped'
       AND DATE_TRUNC('month', ${TABLE}.DUE_DATE) = DATE_TRUNC('month', DATEADD(month, 1, CURRENT_DATE()))
       AND ${TABLE}.VENDOR_NAME IN ('Mi-T-M Corporation', 'FNA Group Inc')
      THEN 'Case E - VPO'
      ELSE NULL
    END ;;
  }

  dimension: po_class_parameters {
    type: string
    label: "Call to Action"
    sql:
   CASE
      WHEN ${po_class_filter} = 'Case A - SPO' THEN 'Needs Serial Plate Photo'
      WHEN ${po_class_filter} = 'Case A - VPO' THEN 'Needs Serial Plate Photo'
      WHEN ${po_class_filter} = 'Case B - SPO' THEN 'Needs Serial Plate Photo'
      WHEN ${po_class_filter} = 'Case B - VPO' THEN 'Needs Serial Plate Photo'
      WHEN ${po_class_filter} = 'Case C' THEN 'Needs Serial Number'
      WHEN ${po_class_filter} = 'Case D' THEN 'Needs Serial Number'
      WHEN ${po_class_filter} = 'Case E - SPO' THEN 'Needs Serial Plate Photo'
      WHEN ${po_class_filter} = 'Case E - VPO' THEN 'Needs Serial Plate Photo'
      ELSE NULL
    END ;;
  }


  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.ASSET_ID ;;
    html:  <u><p style="color:Blue;"><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ value | url_encode }}"target='_blank'>{{rendered_value}}</a></p></u>;;
  }

dimension: serial_vin {
  type: string
  sql:
    CASE
      WHEN ${TABLE}.PREFIX = 'S' THEN ${TABLE}.SERIAL
      WHEN ${TABLE}.PREFIX = 'V' THEN ${TABLE}.VIN
      ELSE NULL
    END ;;
}

  dimension: CPE_VLP_Contact {
    type: string
    sql:
    CASE
      WHEN ${TABLE}.market IN ('KC VLP - Retail Branch', 'Wichita, KS - Retail Yard', 'Garden City, KS - Core Solutions', 'Joplin, MO - Core Solutions', 'Topeka, KS - Core Solutions') THEN 'alan.hetherington@equipmentshare.com'
      WHEN ${TABLE}.market IN ('Fort Myers, FL - Core Solutions', 'West Palm Beach, FL - Core Solutions', 'Miami, FL - Core Solutions', 'CPE Tampa, FL - Retail', 'CPE Orlando, FL - Retail Yard', 'CPE Jacksonville, FL - Retail Yard') THEN 'CPE.assets@equipmentshare.com'
      ELSE NULL
    END ;;
  }

  dimension: asset_id_T3 {
    type: number
    value_format_name: id
    sql: ${TABLE}.ASSET_ID ;;
    html: <u><p style="color:Blue;"><a href="https://app.estrack.com/#/assets/all/asset/{{ value | url_encode }}/service/work-orders" target='_blank'>{{rendered_value}}</a></p></u>;;
  }

}
