view: costcapture_inventory_backdating {
  # Dashboard-level date filter → applied to r.DATE_CREATED
  filter: created_date { type: date }

  derived_table: {
    sql:
      SELECT
        DATE_TRUNC('month', r.DATE_CREATED) AS month,
        /* Backdated-only quantities & value */
        SUM(CASE WHEN DATE_TRUNC('day', r.DATE_RECEIVED) <> DATE_TRUNC('day', r.DATE_CREATED)
                 THEN li.TOTAL_ACCEPTED ELSE 0 END)                                      AS backdated_units,
        SUM(CASE WHEN DATE_TRUNC('day', r.DATE_RECEIVED) <> DATE_TRUNC('day', r.DATE_CREATED)
                 THEN li.TOTAL_ACCEPTED * li.PRICE_PER_UNIT ELSE 0 END)                  AS backdated_value,
        /* All inventory quantities & value */
        SUM(li.TOTAL_ACCEPTED)                                                           AS total_units,
        SUM(li.TOTAL_ACCEPTED * li.PRICE_PER_UNIT)                                       AS total_value
      FROM procurement.public.purchase_order_receivers r
      JOIN procurement.public.purchase_order_line_items li
        ON li.PURCHASE_ORDER_ID = r.PURCHASE_ORDER_ID
      LEFT JOIN procurement.public.items i
        ON i.ITEM_ID = li.ITEM_ID
      WHERE 1=1
        {% if _filters['costcapture_inventory_backdating.created_date'] %}
          AND {% condition created_date %} r.DATE_CREATED {% endcondition %}
        {% endif %}
        AND i.ITEM_TYPE = 'INVENTORY'
      GROUP BY 1
      ORDER BY 1
    ;;
  }

  # ===== Time =====
  dimension_group: month {
    type: time
    timeframes: [month, month_name, quarter, year]
    datatype: date
    sql: ${TABLE}.month ;;
  }

  # ===== Measures =====
  measure: backdated_units {
    type: sum
    sql: ${TABLE}.backdated_units ;;
  }

  measure: backdated_value {
    type: sum
    sql: ${TABLE}.backdated_value ;;
  }

  measure: total_units {
    type: sum
    sql: ${TABLE}.total_units ;;
  }

  measure: total_value {
    type: sum
    sql: ${TABLE}.total_value ;;
  }

  # Percentages computed as ratios of sums (correct rollups)
  measure: pct_units_backdated {
    type: number
    sql: CASE WHEN ${total_units} = 0 THEN NULL
              ELSE ${backdated_units} / NULLIF(${total_units}, 0)
         END ;;
    value_format_name: percent_2
    label: "% Units Backdated"
  }

  measure: pct_value_backdated {
    type: number
    sql: CASE WHEN ${total_value} = 0 THEN NULL
              ELSE ${backdated_value} / NULLIF(${total_value}, 0)
         END ;;
    value_format_name: percent_2
    label: "% Value Backdated"
  }
}
