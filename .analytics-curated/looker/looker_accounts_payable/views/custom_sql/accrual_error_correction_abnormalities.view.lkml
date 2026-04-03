view: accrual_error_correction_abnormalities {
  derived_table: {
    sql:

    select
        document_number,
        --regexp_substr(document_number, '^[^-]+') as document_number,
        regexp_substr(xml, '<correction>([^<]+)</correction>', 1, 1, 'e', 1) as correction_text,
        regexp_substr(xml, '<description2>([^<]+)</description2>', 1, 1, 'e', 1) as description2_text,
        result
    from
        analytics.ap_accrual.create_receipts_job_results
    where
        result = 'error'
        and try_to_number(regexp_substr(document_number, '^[^-]+')) > 1000000
        -- and (correction_text <> 'Make desired changes and press Save to continue.' or correction_text is null)
    qualify
        row_number() over (
            partition by document_number
            order by run_timestamp desc
        ) = 1
        and count(*) over (
            partition by document_number
        ) > 5



      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}.document_number ;;
  }

  dimension: correction {
    type: string
    sql: ${TABLE}."CORRECTION_TEXT" ;;
  }

  dimension: error_description {
    type: string
    sql: ${TABLE}."DESCRIPTION2_TEXT" ;;
  }

  set: detail {
    fields: [
      po_number,correction,error_description
    ]
  }
}
