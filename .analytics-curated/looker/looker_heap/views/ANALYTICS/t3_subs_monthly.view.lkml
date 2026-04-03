  view: t3_subs_monthly {
    derived_table: {
      sql: WITH monthly_company_counts AS (
            SELECT
              t3.month::date AS invoiced_month
              , COUNT(DISTINCT t3.company_id) AS company_count
            FROM ANALYTICS.T_3_INVOICE_COMPANY_IDS t3

            GROUP BY
              t3.month::date
          )
          SELECT
            invoiced_month
            , company_count
            , LAG(company_count) OVER (partition by invoiced_month ORDER BY invoiced_month) AS previous_company_count
          FROM
            monthly_company_counts  ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension_group: invoiced_month {
      type: time
      sql: ${TABLE}.INVOICED_MONTH ;;

    }

    dimension: company_count {
      type: number
      sql: ${TABLE}.COMPANY_COUNT ;;
    }

    dimension: previous_company_count {
      type: number
      sql: ${TABLE}.PREVIOUS_COMPANY_COUNT ;;
    }

    measure: company_count_total {
      type: sum_distinct
      sql_distinct_key: ${invoiced_month_month} ;;
      sql: ${company_count};;
    }

    measure: previous_company_count_total {
      type: sum_distinct
      sql_distinct_key: ${invoiced_month_month} ;;
      sql: ${previous_company_count};;
    }

    measure: monthly_difference {
      type: number
      sql: ${company_count_total} - ${previous_company_count_total} ;;
    }


    set: detail {
      fields: [
        invoiced_month_month,
        company_count,
        previous_company_count
      ]
    }
  }
