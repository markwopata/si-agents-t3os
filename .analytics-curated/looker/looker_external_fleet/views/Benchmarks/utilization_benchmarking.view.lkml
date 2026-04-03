view: utilization_benchmarking {
    derived_table: {
      sql: select * from analytics.analytics.benchmarking_ratings ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: benchmark_name {
      type: string
      sql: ${TABLE}."BENCHMARK_NAME" ;;
    }

    dimension: rating {
      type: string
      sql: ${TABLE}."RATING" ;;
    }

    dimension: limit_type {
      type: string
      sql: ${TABLE}."LIMIT_TYPE" ;;
    }

    dimension: lower_limit {
      type: number
      sql: ${TABLE}."LOWER_LIMIT" ;;
    }

    dimension: upper_limit {
      type: number
      sql: ${TABLE}."UPPER_LIMIT" ;;
    }

    set: detail {
      fields: [
        benchmark_name,
        rating,
        limit_type,
        lower_limit,
        upper_limit
      ]
    }
  }
