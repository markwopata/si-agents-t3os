view: approved_invoice_salespersons_flat {
    derived_table: {
      sql:
      SELECT invoice_id,
             billing_approved_date,
             primary_salesperson_id AS salesperson_id,
             1                      AS salesperson_type
        FROM es_warehouse.public.approved_invoice_salespersons
       UNION ALL
      SELECT invoice_id,
             billing_approved_date,
             value                  AS salesperson_id,
             2                      AS salesperson_type
        FROM es_warehouse.public.approved_invoice_salespersons, TABLE ( FLATTEN(secondary_salesperson_ids) )
       WHERE secondary_salesperson_ids <> '[]'
          ;;}


    dimension_group: billing_approved {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}.CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
    }

    dimension: invoice_id {
      type: number
      sql: ${TABLE}."INVOICE_ID" ;;
      value_format_name: id
    }

    dimension: salesperson_id {
      type: number
      sql: ${TABLE}."SALESPERSON_ID" ;;
      value_format_name: id
    }

    dimension: salesperson_type {
      type: number
      sql: ${TABLE}."SALESPERSON_TYPE" ;;
    }

  }
