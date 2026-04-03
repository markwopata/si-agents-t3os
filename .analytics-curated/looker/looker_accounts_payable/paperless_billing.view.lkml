
view: paperless_billing {
  derived_table: {
    sql: WITH market_collector_assignments AS (
          SELECT DISTINCT
              CCA.COMPANY_ID,
              CCA.COMPANY_NAME,
              CCA.FINAL_COLLECTOR,
              CCA.MARKET_ID,
              CCA.MARKET_NAME,
              CCA.MARKET_COLLECTOR,
              CONCAT(CCA.MARKET_ID, ' - ', CCA.MARKET_NAME) AS "MARKET",
              MAX(i.start_date::DATE) AS latest_invoice_date,
              bc.paperless_billing
          FROM ANALYTICS.GS.COLLECTOR_CUSTOMER_ASSIGNMENTS CCA
          JOIN ES_WAREHOUSE.PUBLIC.invoices i
              ON cca.company_id = i.company_id
          JOIN analytics.public.billing_contacts bc
              ON i.company_id = bc.company_id
          WHERE i.billing_approved_date IS NOT NULL
          AND billing_approved_date::date <= current_date
          GROUP BY
              CCA.COMPANY_ID,
              CCA.COMPANY_NAME,
              CCA.FINAL_COLLECTOR,
              CCA.MARKET_ID,
              CCA.MARKET_NAME,
              CCA.MARKET_COLLECTOR,
              bc.paperless_billing
      )
      SELECT
          market_collector_assignments.COMPANY_ID AS "company_id",
          market_collector_assignments.COMPANY_NAME AS "company_name",
          market_collector_assignments.MARKET AS "market",
          market_collector_assignments.MARKET_COLLECTOR AS "market_collector",
          market_collector_assignments.FINAL_COLLECTOR,
          market_collector_assignments.paperless_billing,
          DATEDIFF(DAY, market_collector_assignments.latest_invoice_date, CURRENT_DATE) AS days_since_rental
      FROM market_collector_assignments
      WHERE DATEDIFF(DAY, market_collector_assignments.latest_invoice_date, CURRENT_DATE) <= 120 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_collector_assignments_company_id {
    type: number
    sql: ${TABLE}."company_id" ;;
  }

  dimension: market_collector_assignments_company_name {
    type: string
    sql: ${TABLE}."company_name" ;;
  }

  dimension: market_collector_assignments_market {
    type: string
    sql: ${TABLE}."market" ;;
  }

  dimension: market_collector_assignments_market_collector {
    type: string
    sql: ${TABLE}."market_collector" ;;
  }

  dimension: final_collector {
    type: string
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }

  dimension: paperless_billing {
    type: yesno
    sql: ${TABLE}."PAPERLESS_BILLING" ;;
  }

  dimension: days_since_rental {
    type: number
    sql: ${TABLE}."DAYS_SINCE_RENTAL" ;;
  }

  set: detail {
    fields: [
        market_collector_assignments_company_id,
  market_collector_assignments_company_name,
  market_collector_assignments_market,
  market_collector_assignments_market_collector,
  paperless_billing,
  days_since_rental
    ]
  }
}
