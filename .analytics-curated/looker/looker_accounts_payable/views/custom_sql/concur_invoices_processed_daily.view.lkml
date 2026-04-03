view: concur_invoices_processed_daily {
  derived_table: {
    sql: SELECT
          CAST(CONVERT_TIMEZONE('America/Chicago', POH.WHENMODIFIED) AS DATE) AS DATE,
          COUNT(DISTINCT POH.RECORDNO)                                        AS VI_COUNT
      FROM
          ANALYTICS.INTACCT.PODOCUMENT POH
      WHERE
            POH.DOCPARID = 'Vendor Invoice'
        AND CAST(CONVERT_TIMEZONE('America/Chicago', POH.WHENMODIFIED) AS DATE) >= '2022-07-01'
        AND POH.CREATEDUSERID IN ('xml_concur', 'xml_fsateam')
      GROUP BY
          CAST(CONVERT_TIMEZONE('America/Chicago', POH.WHENMODIFIED) AS DATE)
      ORDER BY
          CAST(CONVERT_TIMEZONE('America/Chicago', POH.WHENMODIFIED) AS DATE) DESC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: vi_count {
    type: number
    sql: ${TABLE}."VI_COUNT" ;;
  }

  set: detail {
    fields: [date, vi_count]
  }
}
