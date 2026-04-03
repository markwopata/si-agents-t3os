include: "/_standard/analytics/commission/commission_details.layer.lkml"

# commission_details.explore.lkml

explore: commission_details {
  label: "Commission Details for Investigation"

  # use the same base view the layer uses for line item grain
  from: commission_details

  # ensure these are available for row context
  # (these should already exist in commission_details; if not, they must be joined in)
}

view: +commission_details {

  # FLOOR column
  measure: floor_rate_amount {
    type: number
    sql: ${TABLE}.FLOOR_RATE_AMOUNT ;;  # <-- replace with your real column/expression

    drill_fields: [floor_rate] {
      label: "View Floor rate history"
      explore: branch_rental_rates_historical

      fields: [
        branch_rental_rates_historical.rate_type,
        branch_rental_rates_historical.date_created_date,
        branch_rental_rates_historical.price_per_hour,
        branch_rental_rates_historical.price_per_day,
        branch_rental_rates_historical.price_per_week,
        branch_rental_rates_historical.price_per_month
      ]

      sql_where:
        ${branch_rental_rates_historical.branch_id} = {{ branch_id }}
        AND ${branch_rental_rates_historical.equipment_class_id} = {{ equipment_class_id }}
        AND ${branch_rental_rates_historical.rate_type_id} = 3
      ;;
    }
  }

  # BENCH column
  measure: bench_rate_amount {
    type: number
    sql: ${TABLE}.BENCH_RATE_AMOUNT ;;

    drill_fields: [benchmark_rate] {
      label: "View Bench rate history"
      explore: branch_rental_rates_historical
      fields: [branch_rental_rates_historical.date_created_date, branch_rental_rates_historical.price_per_day]
      sql_where:
        ${branch_rental_rates_historical.branch_id} = {{ branch_id }}
        AND ${branch_rental_rates_historical.equipment_class_id} = {{ equipment_class_id }}
        AND ${branch_rental_rates_historical.rate_type_id} = 2
      ;;
    }
  }

  # BOOK column
  measure: book_rate_amount {
    type: number
    sql: ${TABLE}.BOOK_RATE_AMOUNT ;;

    drill_fields: [book_rate] {
      label: "View Book rate history"
      explore: branch_rental_rates_historical
      fields: [branch_rental_rates_historical.date_created_date, branch_rental_rates_historical.price_per_day]
      sql_where:
        ${branch_rental_rates_historical.branch_id} = {{ branch_id }}
        AND ${branch_rental_rates_historical.equipment_class_id} = {{ equipment_class_id }}
        AND ${branch_rental_rates_historical.rate_type_id} = 1
      ;;
    }
  }
}
