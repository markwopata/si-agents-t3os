view: salesperson_type_invoice {
  derived_table: {
    sql: -- Your SQL query here
      WITH
          expanded_salespersons AS (SELECT ais.invoice_id,
                                            ais.SECONDARY_SALESPERSON_IDS,
                                            VALUE::STRING AS salesperson_id
                                     FROM ES_WAREHOUSE.PUBLIC.approved_invoice_salespersons ais, TABLE (FLATTEN(INPUT => ais.SECONDARY_SALESPERSON_IDS))

      UNION ALL

      SELECT ais.invoice_id,
      ais.SECONDARY_SALESPERSON_IDS,
      PRIMARY_SALESPERSON_ID::varchar
      FROM ES_WAREHOUSE.PUBLIC.approved_invoice_salespersons ais)

      , joined_salespersons AS (SELECT es.invoice_id,
      concat(u.FIRST_NAME, ' ', u.LAST_NAME) AS full_name,
      USER_ID
      FROM expanded_salespersons es
      LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS u
      ON es.salesperson_id = u.USER_ID)

      SELECT invoice_no,
      i.INVOICE_ID,
      BILLING_APPROVED_DATE,
      ARRAY_TO_STRING(ARRAY_AGG(full_name), ', ') AS salesrep_names
      FROM joined_salespersons
      LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON i.INVOICE_ID = joined_salespersons.INVOICE_ID
      WHERE i.invoice_id IN (SELECT invoice_id
      FROM joined_salespersons
      --WHERE USER_ID = 218986
      )
      GROUP BY invoice_no, i.invoice_id, BILLING_APPROVED_DATE ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}.invoice_id ;;
  }

  dimension_group: billing_approved_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.billing_approved_date ;;
  }

  dimension: salesrep_names {
    type: string
    sql: ${TABLE}.salesrep_names ;;
  }
}
