view: sage_pos_submitted_not_approved {
  derived_table: {
    sql:        SELECT
          p.DOCNO as "PO Number",
          p.RECORDNO as "PO Recordno",
          pe.RECORDNO as "Line Recordno",
          p.CUSTVENDID as "Vendor ID",
          p.CUSTVENDNAME as "Vendor Name",
          p.STATE as "State",
          p.WHENCREATED as "Created Date",
          p.MESSAGE as "Message",
          p.DELIVERTO_CONTACTNAME as "Deliver To",
          p.TOTAL as "Total",
          pe.DEPARTMENTNAME as "Market",
          el.name as "Expense Line",
          pe.ITEMID as "Item ID",
          pe.UIQTY as "Qty",
          pe.QTY_CONVERTED as "Qty Converted",
          pe.UIPRICE as "Price",
          pe.TOTAL as "Line Total",
          pe.MEMO as "Memo",
          p.CREATEDUSERID    as "Creator Login",
                    INITCAP(
            REGEXP_REPLACE(
              REGEXP_REPLACE(COALESCE(p.T3_PR_CREATED_BY, ui.DESCRIPTION), '^\\d+ - ', ''),
              '[^A-Za-z\\.\\s]',
              ''
            )
          ) AS "Creator Name", --Remove's Cost Capture ID, the dash, and trailing emojis

      FROM "ANALYTICS"."INTACCT"."PODOCUMENT" p

      LEFT JOIN "ANALYTICS"."INTACCT"."PODOCUMENTENTRY" pe on p.DOCID = pe.DOCHDRID
      LEFT JOIN "ANALYTICS"."INTACCT"."EXPENSE_LINE"    el ON pe.GLDIMEXPENSE_LINE = el.ID
      LEFT JOIN "ANALYTICS"."INTACCT"."USERINFO"        ui ON p.CREATEDUSERID      = ui.LOGINID

      WHERE p.DOCPARID = 'Purchase Order Entry'
     -- AND p.DOCNO NOT LIKE 'PO%'
      --AND p.DOCNO NOT LIKE '%-%'
      --AND p.DOCNO NOT LIKE '%_C'
      --AND p.DOCNO NOT LIKE '%a'
      --AND p.DOCNO NOT LIKE 'E%'
      --AND p.DOCNO < 300000
      AND p.STATE = 'Submitted'

      ORDER BY p.WHENCREATED DESC, p.DOCNO DESC
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po_number {
    type: string
    label: "PO Number"
    sql: ${TABLE}."PO Number" ;;
  }

  dimension: po_recordno {
    type: number
    sql: ${TABLE}."PO Recordno" ;;
  }

  dimension: line_recordno {
    type: number
    sql: ${TABLE}."Line Recordno" ;;
  }

  dimension: vendor_id {
    type: string
    label: "Vendor ID"
    sql: ${TABLE}."Vendor ID" ;;
  }

  dimension: vendor_name {
    type: string
    label: "Vendor Name"
    sql: ${TABLE}."Vendor Name" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."State" ;;
  }

  dimension: created_date {
    type: date
    label: "Created Date"
    sql: ${TABLE}."Created Date" ;;
  }

  dimension: message {
    type: string
    sql: ${TABLE}."Message" ;;
  }

  dimension: deliver_to {
    type: string
    label: "Deliver To"
    sql: ${TABLE}."Deliver To" ;;
  }

  dimension: total {
    type: number
    sql: ${TABLE}."Total" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."Market" ;;
  }

  dimension: expense_line {
    type: string
    label: "Expense Line"
    sql: ${TABLE}."Expense Line" ;;
  }

  dimension: item_id {
    type: string
    label: "Item ID"
    sql: ${TABLE}."Item ID" ;;
  }

  dimension: qty {
    type: number
    sql: ${TABLE}."Qty" ;;
  }

  dimension: qty_converted {
    type: number
    sql: ${TABLE}."Qty Converted" ;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}."Price" ;;
  }

  dimension: line_total {
    type: number
    label: "Line Total"
    sql: ${TABLE}."Line Total" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."Memo" ;;
  }

  dimension: creator_login {
    type: string
    sql: ${TABLE}."Creator Login" ;;
  }

  dimension: creator_name {
    type: string
    sql: ${TABLE}."Creator Name" ;;
  }

  set: detail {
    fields: [
      po_number,
      po_recordno,
      line_recordno,
      vendor_id,
      vendor_name,
      state,
      created_date,
      message,
      deliver_to,
      total,
      market,
      expense_line,
      item_id,
      qty,
      qty_converted,
      price,
      line_total,
      memo,
      creator_login,
      creator_name
    ]
  }
}
