
view: intacct_dup_apa_apj {
  derived_table: {
    sql: SELECT p.DOCNO              APJ_INVOICE,
                 pod.url_sage         APJ_URL_SAGE,
                 p.TOTAL              APJ_AMOUNT,
                 p.AUWHENCREATED      APJ_WHENCREATED,
                 p.PONUMBER           APJ_PONUMBER,
                 p.CUSTVENDID         APJ_VENDORID,
                 p.CUSTVENDNAME       APJ_VENDORNAME,
                 p.USERID             APJ_USERID,
                 PPO.DOCNO         AS APA_POR_NUMBER,
                 POD2.URL_SAGE,
                 POD2.URL_T3,
                 PPO.TOTAL         AS APA_POR_TOTAL,
                 PPO.AUWHENCREATED AS APA_POR_WHENCREATED,
                 PPO.CUSTVENDID    AS APA_POR_VENDORID,
                 PPO.CUSTVENDNAME  AS APA_POR_VENDOR,
                 PPO.USERID           APA_POR_USER_ID,
                 PPO.BLANKET_PO       APA_BLANKET,
                 PPO.STATE         AS APA_POR_STATE

          FROM "ANALYTICS"."INTACCT"."PODOCUMENT" p

                   LEFT JOIN (SELECT DOCNO,
                                     TOTAL,
                                     AUWHENCREATED,
                                     PONUMBER,
                                     CUSTVENDID,
                                     CUSTVENDNAME,
                                     BLANKET_PO,
                                     USERID,
                                     STATE
                              FROM "ANALYTICS"."INTACCT"."PODOCUMENT"
                              WHERE DOCPARID = 'Purchase Order'
                                AND STATE = 'Pending') PPO
                             ON PPO.DOCNO = UPPER(p.PONUMBER)

                   LEFT JOIN (SELECT DISTINCT VENDOR_INVOICE_NUMBER,
                                              URL_SAGE,
                                              URL_CONCUR
                              FROM analytics.intacct_models.po_detail) POD
                             ON POD.VENDOR_INVOICE_NUMBER = P.DOCNO


                   LEFT JOIN (SELECT DISTINCT RECEIPT_NUMBER,
                                              URL_SAGE,
                                              URL_T3
                              FROM analytics.intacct_models.po_detail) POD2
                             ON POD2.RECEIPT_NUMBER = PPO.DOCNO


          WHERE p.DOCPARID IN ('Vendor Invoice', 'Purchase Order')

            AND p.PONUMBER NOT IN ('', 'nan')
            AND P.PONUMBER LIKE ANY ('3%', '4%', '5%', '6%', '7&', '8%', '9%', 'E%', 'e%')

            AND p.CREATEDFROM is NULL
            AND P.CUSTVENDID = APA_POR_VENDORID ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: apj_invoice {
    type: string
    label: "APJ Invoice"
    sql: ${TABLE}."APJ_INVOICE" ;;
    html: <a href="{{ apj_url_sage._value }}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: apj_url_sage {
    type: string
    label: "APJ URL Sage"
    sql: ${TABLE}."APJ_URL_SAGE" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: apj_amount {
    type: number
    label: "APJ Amount"
    sql: ${TABLE}."APJ_AMOUNT" ;;
  }

  dimension_group: apj_whencreated {
    type: time
    label: "APJ When Created"
    sql: ${TABLE}."APJ_WHENCREATED" ;;
  }

  dimension: apj_ponumber {
    type: string
    label: "APJ PO Number"
    sql: ${TABLE}."APJ_PONUMBER" ;;
  }

  dimension: apj_vendorid {
    type: string
    label: "APJ Vendor ID"
    sql: ${TABLE}."APJ_VENDORID" ;;
  }

  dimension: apj_vendorname {
    type: string
    label: "APJ Vendor Name"
    sql: ${TABLE}."APJ_VENDORNAME" ;;
  }

  dimension: apj_userid {
    type: string
    label: "APJ User ID"
    sql: ${TABLE}."APJ_USERID" ;;
  }

  dimension: apa_por_number {
    type: string
    label: "APA POR Number"
    sql: ${TABLE}."APA_POR_NUMBER" ;;
    html: <a href="{{ url_sage._value }}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: url_sage {
    type: string
    sql: ${TABLE}."URL_SAGE" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: apa_por_total {
    type: number
    label: "APA POR Total"
    sql: ${TABLE}."APA_POR_TOTAL" ;;
  }

  dimension_group: apa_por_whencreated {
    type: time
    label: "APA POR When Created"
    sql: ${TABLE}."APA_POR_WHENCREATED" ;;
  }

  dimension: apa_por_vendorid {
    type: string
    label: "APA POR Vendor ID"
    sql: ${TABLE}."APA_POR_VENDORID" ;;
  }

  dimension: apa_por_vendor {
    type: string
    label: "APA POR Vendor"
    sql: ${TABLE}."APA_POR_VENDOR" ;;
  }

  dimension: apa_por_user_id {
    type: string
    label: "APA POR User ID"
    sql: ${TABLE}."APA_POR_USER_ID" ;;
  }

  dimension: apa_blanket {
    type: yesno
    label: "APA Blanket PO Flag"
    sql: ${TABLE}."APA_BLANKET" ;;
  }

  dimension: apa_por_state {
    type: string
    label: "APA POR State"
    sql: ${TABLE}."APA_POR_STATE" ;;
  }

  set: detail {
    fields: [
        apj_invoice,
        apj_url_sage,
        apj_amount,
        apj_whencreated_time,
        apj_ponumber,
        apj_vendorid,
        apj_vendorname,
        apj_userid,
        apa_por_number,
        url_sage,
        url_t3,
        apa_por_total,
        apa_por_whencreated_time,
        apa_por_vendorid,
        apa_por_vendor,
        apa_por_user_id,
        apa_blanket,
        apa_por_state
    ]
  }
}
