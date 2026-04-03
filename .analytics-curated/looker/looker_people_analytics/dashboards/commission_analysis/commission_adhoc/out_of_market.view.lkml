  view: out_of_market {

    derived_table: {
      sql:
      WITH data AS (
        SELECT
          rental_approved_date::date AS MONTH,
          rental_district,
          rental_market_id,
          rental_market,
          sp_user_id,
          salesperson,
          sp_district,
          sp_market_id,
          sp_market,
          SUM(RENTAL_REVENUE) AS TOTAL_RENTAL_REVENUE,
          SUM(CASE WHEN rental_market_id != sp_market_id THEN RENTAL_REVENUE ELSE 0 END)
            AS OUTSIDE_MARKET__TOTAL_RENTAL_REVENUE,
          SUM(CASE WHEN RENTAL_DISTRICT != SP_DISTRICT THEN RENTAL_REVENUE ELSE 0 END)
            AS OUTSIDE_DISTRICT__TOTAL_RENTAL_REVENUE,

          SUM(CASE WHEN RENTAL_DISTRICT != SP_DISTRICT OR rental_market_id != sp_market_id THEN RENTAL_REVENUE ELSE 0 END)
          AS TOTAL_OUTSIDE_RENTAL_REVENUE,

          COUNT(*) AS TOTAL_RENTAL_COUNT,
          SUM(CASE WHEN rental_market_id != sp_market_id THEN 1 ELSE 0 END)
            AS OUTSIDE_MARKET__TOTAL_RENTAL_COUNT,
          SUM(CASE WHEN RENTAL_DISTRICT != SP_DISTRICT THEN 1 ELSE 0 END)
            AS OUTSIDE_DISTRICT__TOTAL_RENTAL_COUNT
        FROM analytics.bi_ops.salesperson_line_items_historic
        WHERE RENTAL_REVENUE != 0
        GROUP BY
          rental_approved_date,
          rental_district,
          rental_market_id,
          rental_market,
          sp_user_id,
          salesperson,
          sp_district,
          sp_market_id,
          sp_market
      )
      SELECT * FROM data;;
    }

    dimension_group: month {
      type: time
      timeframes: [raw, month, quarter, year]  # 🔹 Removed 'raw' and 'date' to prevent duplicates
      sql: ${TABLE}.MONTH ;;
      description: "The rental approved date truncated to month."
    }

    dimension: rental_district {
      type: string
      sql: ${TABLE}.rental_district ;;
      description: "District where the rental occurred."
      drill_fields: [
        rental_market,
        rental_market_id,
        salesperson,
        total_rental_revenue,
        total_rental_count
      ]
    }

    dimension: rental_market_id {
      type: string
      sql: ${TABLE}.rental_market_id ;;
      description: "Market ID where the rental occurred."
    }

    dimension: rental_market {
      type: string
      sql: ${TABLE}.rental_market ;;
      description: "Market name where the rental occurred."
    }

    dimension: sp_user_id {
      type: string
      sql: ${TABLE}.sp_user_id ;;
      description: "Salesperson's user ID."
    }

    dimension: salesperson {
      type: string
      sql: ${TABLE}.salesperson ;;
      description: "Salesperson's name."
    }

    dimension: sp_district {
      type: string
      sql: ${TABLE}.sp_district ;;
      description: "Salesperson's assigned district."
    }

    dimension: sp_market_id {
      type: string
      sql: ${TABLE}.sp_market_id ;;
      description: "Salesperson's assigned market ID."
    }

    dimension: sp_market {
      type: string
      sql: ${TABLE}.sp_market ;;
      description: "Salesperson's assigned market."
    }
    measure: total_rental_revenue {
      type: sum
      sql: ${TABLE}.TOTAL_RENTAL_REVENUE ;;
      description: "Total rental revenue."
      value_format: "$#,##0.00"
      drill_fields: [ rental_district, rental_market, salesperson ]
    }

    measure: outside_market_total_rental_revenue {
      type: sum
      sql: ${TABLE}.OUTSIDE_MARKET__TOTAL_RENTAL_REVENUE ;;
      description: "Total rental revenue from outside the salesperson's market."
      value_format: "$#,##0.00"
    }

    measure: outside_district_total_rental_revenue {
      type: sum
      sql: ${TABLE}.OUTSIDE_DISTRICT__TOTAL_RENTAL_REVENUE ;;
      description: "Total rental revenue from outside the salesperson's district."
      value_format: "$#,##0.00"
    }

    measure: total_rental_count {
      type: sum
      sql: ${TABLE}.TOTAL_RENTAL_COUNT ;;
      description: "Total count of rentals."
      value_format: "#,##0"
      drill_fields: [rental_district, rental_market, outside_market_total_rental_revenue, total_rental_count,outside_district_total_rental_revenue, outside_district_total_rental_count]
      # link: {
      #   label: "Drill Down by District"
      #   url: "/explore/model_name/explore_name?fields=rental_district,total_rental_count&filters[month]=%{month}&pivots=rental_district"
      # }
    }

    measure: outside_market_total_rental_count {
      type: sum
      sql: ${TABLE}.OUTSIDE_MARKET__TOTAL_RENTAL_COUNT ;;
      description: "Total count of rentals outside the salesperson's market."
      value_format: "#,##0"
      drill_fields: [rental_district, rental_market, outside_market_total_rental_revenue, total_rental_count,outside_district_total_rental_revenue, outside_district_total_rental_count]
      # link: {
      #   label: "Drill Down by District"
      #   url: "/explore/model_name/explore_name?fields=rental_district,outside_market_total_rental_count&filters[month]=%{month}&pivots=rental_district"
      # }
    }

    measure: outside_district_total_rental_count {
      type: sum
      sql: ${TABLE}.OUTSIDE_DISTRICT__TOTAL_RENTAL_COUNT ;;
      description: "Total count of rentals outside the salesperson's district."
      value_format: "#,##0"
      drill_fields: [rental_district, rental_market, outside_market_total_rental_revenue, total_rental_count,outside_district_total_rental_revenue, outside_district_total_rental_count]
      # link: {
      #   label: "Drill Down by District"
      #   url: "/explore/model_name/explore_name?fields=rental_district,outside_district_total_rental_count&filters[month]=%{month}&pivots=rental_district"
      # }
    }

    dimension: drilldown {
      label: "View District Breakdown"
      type: string
      sql: "'Click for details'" ;;
      link: {
        label: "Drill Down"
        url: "/explore/model_name/explore_name?fields=rental_district,total_rental_revenue,total_rental_count,outside_market_total_rental_count,outside_district_total_rental_count&filters[month]=%{month}&pivots=rental_district"
      }
    }

    measure: total_outside_rental_revenue {
      type: sum
      sql: ${TABLE}.TOTAL_OUTSIDE_RENTAL_REVENUE ;;
      description: "Total rental revenue from rentals outside both the salesperson's district and market."
      value_format: "$#,##0.00"
    }


  }
