view: rentals_with_swaps {
  derived_table: {
    sql:
     WITH swap_rentals AS (
  SELECT iea.rental_id
  FROM analytics.assets.int_equipment_assignments iea
  GROUP BY iea.rental_id
  HAVING COUNT(DISTINCT iea.asset_id) > 1
),

      /* distinct assets per swap rental */
      iea_assets AS (
      SELECT DISTINCT iea.rental_id, iea.asset_id
      FROM analytics.assets.int_equipment_assignments iea
      JOIN swap_rentals sr
      ON sr.rental_id = iea.rental_id
      ),

      /* delivered assets (status=3) for the company/location filter */
      delivered_assets AS (
      SELECT DISTINCT
      d.rental_id,
      d.asset_id
      FROM es_warehouse.public.deliveries d
      JOIN es_warehouse.public.locations l
      ON d.origin_location_id = l.location_id
      JOIN swap_rentals sr
      ON sr.rental_id = d.rental_id
      WHERE d.asset_id IS NOT NULL
      AND l.company_id = 1854
      AND d.delivery_status_id = 3
      AND d.completed_date::date >= '2025-01-01'
      ),

      /* keep only rentals where NO IEA asset is missing a delivered(=3) record */
      all_assets_delivered_rentals AS (
      SELECT ia.rental_id
      FROM iea_assets ia
      LEFT JOIN delivered_assets da
      ON da.rental_id = ia.rental_id
      AND da.asset_id  = ia.asset_id
      GROUP BY ia.rental_id
      HAVING COUNT_IF(da.asset_id IS NULL) = 0
      ),

      /* IEA spine: stable numbering (per rental) BEFORE joining to WOs */
      iea_spine AS (
      SELECT
      iea.rental_id,
      iea.asset_id,
      iea.date_start,
      iea.date_end,
      r.start_date rental_start_date,
      r.end_date rental_end_date,
      r.equipment_class_id rental_equipment_class,
      r.rental_status_id,
      r.order_id,
      ROW_NUMBER() OVER (
      PARTITION BY iea.rental_id
      ORDER BY iea.date_start, iea.asset_id
      ) AS rental_asset_number
      FROM analytics.assets.int_equipment_assignments iea
      JOIN all_assets_delivered_rentals adr
      ON adr.rental_id = iea.rental_id
      JOIN es_warehouse.public.rentals r on iea.rental_id = r.rental_id
      ),

      /* pick ONE delivered row per (rental_id, asset_id) to avoid delivery fanout
      - if you prefer earliest delivery, change ORDER BY completed_date ASC
      */
      deliveries_one AS (
      SELECT
      d.delivery_id,
      d.rental_id,
      d.asset_id,
      d.delivery_status_id,
      d.delivery_type_id,
      ds.name AS delivery_status_name,
      d.completed_date AS delivery_date
      FROM es_warehouse.public.deliveries d
      JOIN es_warehouse.public.delivery_statuses ds
      ON d.delivery_status_id = ds.delivery_status_id
      JOIN es_warehouse.public.locations l
      ON d.origin_location_id = l.location_id
      JOIN all_assets_delivered_rentals adr
      ON adr.rental_id = d.rental_id
      WHERE d.asset_id IS NOT NULL
      AND l.company_id = 1854
      AND d.delivery_status_id = 3
      AND d.completed_date::date >= '2025-01-01'
      QUALIFY ROW_NUMBER() OVER (
      PARTITION BY d.rental_id, d.asset_id
      ORDER BY d.completed_date DESC, d.delivery_id DESC
      ) = 1
      ),

      /* eligible assets to prune WOs scan */
      eligible_assets AS (
      SELECT DISTINCT asset_id
      FROM iea_spine
      ),

      wos AS (
      SELECT
      wo.date_created AS wo_date,
      wo.work_order_id,
      wo.asset_id,
      wo.work_order_status_name,
      wo.severity_level_name,
      wo.work_order_type_name,
      wo.archived_date,
      wo.description,
      wo.branch_id,
      o.originator_type_id
      FROM es_warehouse.work_orders.work_orders wo
      JOIN eligible_assets ea
      ON ea.asset_id = wo.asset_id
      LEFT JOIN es_warehouse.work_orders.work_order_originators o
      ON wo.work_order_id = o.work_order_id
      WHERE o.originator_type_id <> 3
      AND wo.date_created::date >= '2025-01-01'
      )

      , wo_mapped AS (
        SELECT
          s.rental_id,
          s.asset_id,
          d.delivery_date,
          w.work_order_id,
          w.work_order_type_name,
          w.wo_date
        FROM iea_spine s
        JOIN deliveries_one d
          ON d.rental_id = s.rental_id
         AND d.asset_id  = s.asset_id
        JOIN wos w
          ON w.asset_id = s.asset_id
         /* enforce: WO must be after delivery */
         AND w.wo_date >= d.delivery_date
         AND w.wo_date < CASE
                           WHEN s.rental_status_id = 5
                             THEN DATEADD(day, 2, s.date_end)
                           ELSE s.rental_end_date
                         END
      )

      , inspection_only_rentals AS (
      SELECT rental_id
      FROM wo_mapped
      GROUP BY rental_id
      HAVING
      /* require at least one inspection */
      MAX(CASE WHEN work_order_type_name = 'Inspection' THEN 1 ELSE 0 END) = 1
      /* forbid any non-inspection */
      AND MAX(CASE WHEN work_order_type_name <> 'Inspection' OR work_order_type_name IS NULL THEN 1 ELSE 0 END) = 0
      )

      , base AS (
      SELECT
      s.rental_id,
      s.asset_id,

      /* dates */
      d.delivery_date,
      s.date_start AS asset_start_date,
      s.date_end AS asset_end_date,
      s.rental_start_date,
      s.rental_end_date,
      w.wo_date,

      rs.name AS rental_status,
      o.market_id,
      o.order_id,
      s.rental_equipment_class,
      a.equipment_class_id AS asset_equipment_class,

      w.work_order_id,
      w.work_order_type_name,
      w.severity_level_name,

      /* durations (days) */
      CASE
      WHEN s.date_end::date = '9999-12-31'
      THEN ROUND(DATEDIFF('hour', d.delivery_date, CURRENT_TIMESTAMP()) / 24.0, 2)
      ELSE ROUND(DATEDIFF('hour', d.delivery_date, s.date_end) / 24.0, 2)
      END AS asset_duration_days,

      ROUND(DATEDIFF('hour', d.delivery_date, w.wo_date) / 24.0, 2) AS breakdown_duration_days,

      /* stable per-rental asset sequence */
      s.rental_asset_number,

      /* substitution flag */
      CASE
      WHEN (s.rental_equipment_class = a.equipment_class_id) THEN FALSE
      WHEN (s.rental_equipment_class, a.equipment_class_id)
      IN ((131,95),(95,131),(90,184),(184,90),(209,166),(166,209),(5550,5549),(5549,5550))
      THEN FALSE
      ELSE TRUE
      END AS substitutions,

      /* current assignment: today within asset date range (or open-ended) */
(CURRENT_TIMESTAMP >= s.date_start
       AND (s.date_end::date = '9999-12-31' OR CURRENT_TIMESTAMP <= s.date_end)) AS is_current_assignment

      FROM iea_spine s
      JOIN deliveries_one d
      ON d.rental_id = s.rental_id
      AND d.asset_id  = s.asset_id
      JOIN es_warehouse.public.rental_statuses rs
      ON s.rental_status_id = rs.rental_status_id
      JOIN es_warehouse.public.assets a
      ON a.asset_id = s.asset_id
      JOIN es_warehouse.public.orders o
      ON o.order_id = s.order_id
      JOIN es_warehouse.public.users u
      ON u.user_id = o.user_id
      JOIN es_warehouse.public.companies c
      ON c.company_id = u.company_id

      /* WO join: timestamp compare (fast) */
      left JOIN wos w
      ON w.asset_id = s.asset_id
      AND w.wo_date >= d.delivery_date
      AND w.wo_date < CASE
      WHEN s.rental_status_id = 5
      THEN DATEADD(day, 2, s.date_end)
      ELSE s.rental_end_date
      END
      WHERE s.rental_start_date::date >= '2025-01-01'
      )

      , cte AS (
      SELECT
      b.rental_id,

      /* inspection-only flag (exists in inspection_only_rentals) */
      MAX(CASE WHEN ior.rental_id IS NOT NULL THEN 1 ELSE 0 END) AS is_inspection_only,

      /* any breakdown on first asset (your definition) */
      MAX(CASE WHEN b.rental_asset_number = 1 AND b.work_order_type_name IS NOT NULL THEN 1 ELSE 0 END) AS total_breakdowns,

      /* substitution pattern: first is sub=true AND a later asset is sub=false */
      (
      MAX(CASE WHEN b.rental_asset_number = 1 AND b.substitutions = TRUE  THEN 1 ELSE 0 END)
      *
      MAX(CASE WHEN b.rental_asset_number > 1 AND b.substitutions = FALSE THEN 1 ELSE 0 END)
      ) AS total_subs,

      /* rental currently has an asset assigned that is a substitution */
      MAX(CASE WHEN b.is_current_assignment AND b.substitutions = TRUE THEN 1 ELSE 0 END) AS has_current_substitution,

      MAX(
      CASE
        WHEN b.rental_asset_number = 1
         AND b.work_order_type_name IS NOT NULL
         AND b.work_order_type_name != 'Inspection'
         AND b.asset_duration_days < 1
        THEN 1 ELSE 0
      END
    ) AS is_first_day_breakdown,

      FROM base b
      LEFT JOIN inspection_only_rentals ior
      ON ior.rental_id = b.rental_id
      GROUP BY 1
      )

      , swap_reasons as (
      SELECT
      rental_id,
      CASE
      WHEN is_first_day_breakdown = 1 THEN 'First Day Breakdown'
      WHEN total_subs         = 1 THEN 'Substitution'
      WHEN is_inspection_only = 1 THEN 'Inspection'
      WHEN total_breakdowns   = 1 THEN 'Breakdown'
      ELSE 'Unknown'
      END AS reason,
      is_inspection_only,
      total_breakdowns,
      total_subs,
      is_first_day_breakdown,
      has_current_substitution
      FROM cte
      )

   SELECT
    b.rental_id,
    b.order_id,
    b.rental_status,
    sr.reason primary_reason,
    MIN(b.rental_start_date)  AS rental_start_date,
    MAX(b.rental_end_date)    AS rental_end_date,
    MIN(b.delivery_date) as delivery_date,
    COUNT(DISTINCT b.asset_id) AS asset_count,
    CASE
      WHEN MAX(CASE WHEN is_first_day_breakdown = 1 then 1 else 0 end) = 1
        THEN TRUE ELSE FALSE
    END AS first_day_breakdown,
    CASE WHEN MAX(sr.has_current_substitution) = 1 THEN TRUE ELSE FALSE END AS has_current_substitution

FROM base b
join swap_reasons sr on b.rental_id = sr.rental_id
GROUP BY
    b.rental_id,
    b.order_id,
    b.rental_status,
    sr.reason ;;
  }

  dimension: rental_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.rental_id ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}.order_id ;;
  }

  dimension: order_id_html {
    group_label: "Order ID HTML"
    label: "Order ID"
    sql: ${order_id} ;;
    html:
    <a href="https://admin.equipmentshare.com/#/home/orders/{{order_id._value}}" style='color: blue;'
    target="_blank"><b>{{order_id._value}}</b> ➔</a>
    ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}.rental_status ;;
  }

  dimension: primary_reason {
    label: "Primary Swap Reason"
    type: string
    sql: ${TABLE}.primary_reason ;;
  }

  dimension: first_day_breakdown {
    type: yesno
    sql: ${TABLE}.first_day_breakdown ;;
  }

  dimension: has_current_substitution {
    type: yesno
    sql: ${TABLE}.has_current_substitution ;;
  }

  dimension: asset_count {
    label: "Assets in Rental"
    type: number
    sql: ${TABLE}.asset_count ;;
  }

  dimension_group: rental_start_group {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.rental_start_date ;;
  }

  dimension_group: rental_end_group {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.rental_end_date ;;
  }

  dimension_group: delivery {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.delivery_date ;;
  }

  # Dates/times (your SQL outputs timestamps in America/Chicago)
  dimension_group: rental_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.rental_start_date ;;
  }

  dimension_group: rental_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.rental_end_date ;;
  }

  dimension: rental_start_formatted {
    group_label: "Formatted Dates"
    label: "Rental Start"
    type: date
    datatype: date
    sql: ${rental_start_date} ;;
    html: {{ value | date: "%b %-d, %Y" }} ;;
  }

  dimension: rental_end_formatted {
    group_label: "Formatted Dates"
    label: "Rental End"
    type: date
    datatype: date
    sql: ${rental_end_date} ;;
    html: {{ value | date: "%b %-d, %Y" }} ;;
  }


  dimension: delivery_formatted {
    group_label: "Formatted Dates"
    label: "Delivery Date"
    type: date_time
    datatype: datetime
    sql: ${delivery_time} ;;
    html: {{ value | date: "%b %-d, %Y %I:%M %p" }} ;;
  }


  # measure: asset_count_measure {
  #   type: sum
  #   sql: ${asset_count} ;;
  #   label: "Distinct Asset Count"

  #   drill_fields: [
  #     primary_reason,
  #     rental_id,
  #     order_id_html,
  #     v_markets.market_name,
  #     int_equipment_assignments.asset_id_html,
  #     rental_start_formatted,
  #     rental_end_formatted,
  #     int_equipment_assignments.delivery_formatted,
  #     int_equipment_assignments.asset_start_formatted,
  #     int_equipment_assignments.asset_end_formatted,
  #     int_equipment_assignments.asset_duration_html,
  #     work_orders.work_order_id_html,
  #     work_orders.work_order_type_name,
  #     work_orders.severity_level_name,
  #     company_tags.tags
  #     # substitution
  #   ]

  #   link: {
  #     label: "Drill Sorted"
  #     url: "
  #     {% assign base = link | split: '&sorts=' | first %}
  #     {{ base }}&sorts=int_equipment_assignments.asset_start_formatted+asc
  #     "
  #   }
  # }

  measure: asset_count_measure {
    type: sum
    sql: ${asset_count} ;;
    label: "Distinct Asset Count"
    html: <a href="#drillmenu" target="_self">{{ rendered_value }}
      <img src="https://imgur.com/ZCNurvk.png" height="15" width="15" alt="" /></a> ;;
    drill_fields: [
      primary_reason,
      rental_id,
      order_id_html,
      v_markets.market_name,
      int_equipment_assignments.asset_id_html,
      rental_start_formatted,
      rental_end_formatted,
      int_equipment_assignments.delivery_formatted,
      int_equipment_assignments.asset_start_formatted,
      int_equipment_assignments.asset_end_formatted,
      int_equipment_assignments.asset_duration_html,
      work_orders.work_order_id_html,
      work_orders.work_order_type_name,
      work_orders.severity_level_name,
      company_tags.tags,
      ccc_entries.complaint,
      ccc_entries.correction
      # substitution
    ]
    link: {
      label: "Drill Sorted"
      url: "
      {% assign base = link | split: '&sorts=' | first %}
      {{ base }}&sorts=int_equipment_assignments.asset_start_formatted+asc
      "
    }
  }



  # dimension: asset_duration {
  #   label: "Asset Duration (Days)"
  #   type: number
  #   sql: CASE WHEN ${asset_end_date} = '9999-12-30'
  #         THEN DATEDIFF('hour', ${asset_start_time}, CURRENT_TIMESTAMP()) / 24.0
  #         ELSE DATEDIFF('hour', ${asset_start_time}, ${asset_end_time}) / 24.0
  #         END ;;
  #   value_format_name: "decimal_1"
  # }

  measure: total_rentals {
    type: count_distinct
    sql: ${rentals.rental_id} ;;
  }

  measure: first_day_breakdown_rentals {
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [first_day_breakdown: "yes"]
  }

  measure: first_day_breakdown_perc {
    label: "First Day Breakdown %"
    type: number
    sql: ${first_day_breakdown_rentals} / nullif(${swap_rentals}, 0) ;;
    value_format_name: percent_1
  }

  measure: breakdown_rentals {
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [primary_reason: "Breakdown"]
  }

  measure: breakdown_perc {
    label: "Breakdown %"
    type: number
    sql: ${breakdown_rentals} / nullif(${swap_rentals}, 0) ;;
    value_format_name: percent_1
  }

  measure: sub_rentals {
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [primary_reason: "Substitution"]
  }

  measure: sub_perc {
    label: "Substitution %"
    type: number
    sql: ${sub_rentals} / nullif(${swap_rentals}, 0) ;;
    value_format_name: percent_1
  }

  measure: insp_rentals {
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [primary_reason: "Inspection"]
  }

  measure: insp_perc {
    label: "Inspection %"
    type: number
    sql: ${insp_rentals} / nullif(${swap_rentals}, 0) ;;
    value_format_name: percent_1
  }

  measure: unknown_rentals {
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [primary_reason: "Unknown"]
  }

  measure: unknown_perc {
    label: "Unknown %"
    type: number
    sql: ${unknown_rentals} / nullif(${swap_rentals}, 0) ;;
    value_format_name: percent_1
  }

  measure: swap_rentals {
    type: count_distinct
    sql: ${rental_id} ;;
  }

  measure: pct_rentals_with_swaps {
    label: "% Rentals with Swaps"
    type: number
    sql:
    ${swap_rentals}
    / NULLIF(${total_rentals}, 0) ;;
    value_format_name: percent_1
  }

  # measure: avg_asset_duration {
  #   label: "Average Asset Duration"
  #   type: number
  #   sql:
  #   SUM(
  #     CASE
  #       WHEN ${rental_asset_number} = 1
  #       THEN ${asset_duration}
  #     END
  #   )
  #   /
  #   NULLIF(
  #     COUNT(
  #       CASE
  #         WHEN ${rental_asset_number} = 1
  #         THEN ${rental_id}
  #       END
  #     ), 0
  #   ) ;;
  #   value_format_name: decimal_1
  # }



  # dimension: asset_duration_html {
  #   label: "Asset Duration"
  #   type: string
  #   sql:
  #   CASE
  #     WHEN ABS(${asset_duration}) < 1 AND ROUND(ABS(${asset_duration} * 24), 0) = 1
  #       THEN TO_VARCHAR(ROUND(${asset_duration} * 24, 0)) || ' hour'
  #     WHEN ABS(${asset_duration}) < 1
  #       THEN TO_VARCHAR(ROUND(${asset_duration} * 24, 0)) || ' hours'
  #     WHEN ABS(${asset_duration}) >= 1 AND ABS(${asset_duration}) < 2
  #       THEN TO_VARCHAR(ROUND(${asset_duration}, 0)) || ' day'
  #     ELSE TO_VARCHAR(ROUND(${asset_duration}, 0)) || ' days'
  #   END ;;
  # }

measure: count {
  type: count
}

  measure: work_order_count {
    type: count_distinct
    sql: ${TABLE}.work_order_id ;;
    label: "Distinct Work Order Count"
  }
}
