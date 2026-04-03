view: p2p_ap_rep_vendor_assignments {

  derived_table: {
    sql: SELECT distinct
    v.vendor_code,
    COALESCE(
        ts.ap_rep,
        sp.ap_rep,
        r.ap_rep,
        'Default Rep'
    ) AS rep_name
FROM
    analytics.concur.invoices_received v
LEFT JOIN
    analytics.procure_2_pay.gs_ap_rep_vendor_letter r ON (
        UPPER(LEFT(v.vendor_name, 1)) = r.vendor
        OR (LEFT(v.vendor_name, 1) BETWEEN '0' AND '9' AND r.vendor = 'NUMBERS')
    )
LEFT JOIN
     analytics.procure_2_pay.gs_ap_rep_vendor_tooling_solution ts ON v.vendor_code = ts.vendor_id
LEFT JOIN
    analytics.procure_2_pay.gs_ap_rep_vendor_special_handle sp ON v.vendor_code = sp.vendor_id;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_code {
    type: string
    sql: ${TABLE}."VENDOR_CODE" ;;
  }

  dimension: rep_name {
    type: string
    sql: ${TABLE}."REP_NAME" ;;
  }


  set: detail {
    fields: [
      vendor_code, rep_name

    ]
  }

}
