view: t3_damaged_items  {
    derived_table: {
      sql: SELECT
    POH.PURCHASE_ORDER_NUMBER                                           AS PO_NUMBER,
    CAST(CONVERT_TIMEZONE('America/Chicago', POH.DATE_CREATED) AS DATE) AS PO_DATE,
    POL.QUANTITY                                                        AS QTY_ORIGINAL,
    POL.TOTAL_REJECTED                                                  AS QTY_REJECTED,
    POL.TOTAL_ACCEPTED                                                  AS QTY_ACCEPTED,
    podoc.state
FROM
    PROCUREMENT.PUBLIC.PURCHASE_ORDERS POH
        LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS POL ON POH.PURCHASE_ORDER_ID = POL.PURCHASE_ORDER_ID
        left join analytics.intacct.podocument podoc on  TO_VARCHAR(poh.PURCHASE_ORDER_NUMBER) =  TO_VARCHAR(podoc.docno)
WHERE
      POL.QUANTITY >= 0
 AND POL.TOTAL_REJECTED > (1.10 * POL.QUANTITY)
 --and po_date > '2023-12-31'
ORDER BY
    po_date desc --(POL.QUANTITY - POL.TOTAL_REJECTED) asc
        ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

  dimension: status {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

    dimension: po_number {
      type: number
      sql: ${TABLE}."PO_NUMBER" ;;
    }

    dimension: po_date {
      type: date
      sql: ${TABLE}."PO_DATE" ;;
    }

    dimension: qty_original {
      type: number
      sql: ${TABLE}."QTY_ORIGINAL" ;;
    }
  dimension: qty_rejected {
    type: number
    sql: ${TABLE}."QTY_REJECTED" ;;
  }
  dimension: qty_accepted {
    type: number
    sql: ${TABLE}."QTY_ACCEPTED" ;;
  }

    set: detail {
      fields: [po_date, po_number,qty_original, qty_rejected,qty_accepted]
    }
  }
