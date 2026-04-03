view: materials_revenue_sqft {

  sql_table_name: analytics.materials.int_sales_per_sq_ft ;;

  dimension: pkey {
      primary_key: yes
      hidden: yes
      type:  string
      sql:
          ${TABLE}.bt_branch_id::varchar || '|' ||
          to_char(${TABLE}.revenue_month, 'YYYY-MM-DD') || '|' ||
          ${TABLE}.market_name::varchar ;;
    }

    dimension: revenue_month {
      description: "revenue month"
      type: date
      sql: ${TABLE}.revenue_month ;;
    }

    dimension: bt_branch_id {
      description: "Branch id"
      type: number
      sql: ${TABLE}.bt_branch_id ;;
    }

    dimension: market_name {
      description: "market name"
      type: string
      sql: ${TABLE}.market_name ;;
    }

    measure: square_footage {
      description: "square footage"
      type: sum
      sql: ${TABLE}.square_footage ;;
    }

    measure: total_revenue{
      description: "total revenue"
      type: sum
      sql: ${TABLE}.total_revenue ;;
      value_format_name: usd_0
    }

    measure: sales_per_squarefoot {
      description: "Sales per Square Foot"
      type: number
      sql: ${total_revenue} / NULLIF(${square_footage}, 0) ;;
      value_format_name: usd_0
    }

  }
