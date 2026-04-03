view: rental_swap_test {
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
    AND d.completed_date::date >= '2025-12-01'
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
    AND d.completed_date::date >= '2025-12-01'
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
    CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(wo.date_created AS TIMESTAMP_NTZ)) AS wo_date_central,
    wo.work_order_id,
    wo.asset_id,
    wo.work_order_status_name,
    wo.severity_level_name,
    wo.work_order_type_name,
    wo.archived_date,
    wo.description,
    wo.branch_id,
    tag.company_tag_id,
    o.originator_type_id,
    LISTAGG(ct.name, ', ') AS tags
  FROM es_warehouse.work_orders.work_orders wo
  JOIN eligible_assets ea
    ON ea.asset_id = wo.asset_id
  LEFT JOIN es_warehouse.work_orders.work_order_company_tags tag
    ON wo.work_order_id = tag.work_order_id
  LEFT JOIN es_warehouse.work_orders.company_tags ct
    ON tag.company_tag_id = ct.company_tag_id
  LEFT JOIN es_warehouse.work_orders.work_order_originators o
    ON wo.work_order_id = o.work_order_id
  WHERE o.originator_type_id <> 3
    AND wo.date_created::date >= '2025-12-01'
  GROUP BY
    wo.date_created, wo.work_order_id, wo.asset_id,
    wo.work_order_status_name, wo.severity_level_name, wo.work_order_type_name,
    wo.archived_date, wo.description, wo.branch_id, tag.company_tag_id, o.originator_type_id
)

, wo_mapped AS (
  SELECT
    s.rental_id,
    w.work_order_id,
    w.work_order_type_name
  FROM iea_spine s
  JOIN wos w
    ON w.asset_id = s.asset_id
   AND w.wo_date >= s.date_start
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
    CONVERT_TIMEZONE('UTC','America/Chicago', CAST(d.delivery_date AS TIMESTAMP_NTZ)) AS delivery_date,
    CONVERT_TIMEZONE('UTC','America/Chicago', CAST(s.date_start   AS TIMESTAMP_NTZ)) AS asset_start_date,
    CONVERT_TIMEZONE('UTC','America/Chicago', CAST(s.date_end   AS TIMESTAMP_NTZ)) AS asset_end_date,
    CONVERT_TIMEZONE('UTC','America/Chicago', CAST(s.rental_start_date   AS TIMESTAMP_NTZ)) AS rental_start_date,
    CONVERT_TIMEZONE('UTC','America/Chicago', CAST(s.rental_end_date      AS TIMESTAMP_NTZ)) AS rental_end_date,
    CONVERT_TIMEZONE('UTC','America/Chicago', CAST(w.wo_date      AS TIMESTAMP_NTZ)) AS wo_date,

    rs.name AS rental_status,
    o.market_id,
    o.order_id,
    s.rental_equipment_class,
    a.equipment_class_id AS asset_equipment_class,

    w.work_order_id,
    w.work_order_type_name,
    w.severity_level_name,
    w.tags,

    /* durations (days) */
    CASE
      WHEN s.date_end::date = '9999-12-31'
        THEN ROUND(DATEDIFF('hour', s.date_start, CURRENT_TIMESTAMP()) / 24.0, 2)
      ELSE ROUND(DATEDIFF('hour', s.date_start, s.date_end) / 24.0, 2)
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
    END AS substitutions

  FROM iea_spine s
  JOIN deliveries_one d
    ON d.rental_id = s.rental_id
   AND d.asset_id  = s.asset_id
  -- JOIN es_warehouse.public.rentals r
  --   ON r.rental_id = s.rental_id
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
  WHERE s.rental_start_date::date >= '2025-12-01'
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
    ) AS total_subs

  FROM base b
  LEFT JOIN inspection_only_rentals ior
    ON ior.rental_id = b.rental_id
  GROUP BY 1
)

, swap_reasons as (
SELECT
  rental_id,
  CASE
    WHEN total_subs         = 1 THEN 'Substitution'
    WHEN is_inspection_only = 1 THEN 'Inspection'
    WHEN total_breakdowns   = 1 THEN 'Breakdown'
    ELSE 'Unknown'
  END AS reason,
  is_inspection_only,
  total_breakdowns,
  total_subs
FROM cte
)

select
    b.*,
    sr.reason
from base b
join swap_reasons sr on b.rental_id = sr.rental_id ;;
  }

   dimension: rental_id {
    type: string
    sql: ${TABLE}.rental_id ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension: rental_asset_number {
    type: number
    sql: ${TABLE}.rental_asset_number ;;
  }

  dimension: primary_reason {
    type: string
    sql: ${TABLE}.reason ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}.rental_status ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}.order_id ;;
  }

  dimension: rental_equipment_class {
    type: number
    sql: ${TABLE}.rental_equipment_class ;;
  }

  dimension: asset_equipment_class {
    type: number
    sql: ${TABLE}.asset_equipment_class ;;
  }

  dimension: substitution {
    type: yesno
    sql: ${TABLE}.substitutions ;;
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

  dimension: asset_start_formatted {
    group_label: "Formatted Dates"
    label: "Asset Start"
    type: date_time
    datatype: datetime
    sql: ${asset_start_time} ;;
    html: {{ value | date: "%b %-d, %Y %I:%M %p" }} ;;
  }


  dimension: asset_end_formatted {
    group_label: "Formatted Dates"
    label: "Asset Start"
    type: date_time
    datatype: datetime
    sql: ${asset_end_time} ;;
    html: {{ value | date: "%b %-d, %Y %I:%M %p" }} ;;
  }



  dimension_group: delivery {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.delivery_date ;;
  }

  dimension_group: asset_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.asset_start_date ;;
  }

  dimension_group: asset_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.asset_end_date ;;
  }

  dimension_group: work_order_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.wo_date ;;
  }

  # Work order fields (nullable when no WO matches)
  dimension: work_order_id {
    type: string
    sql: COALESCE(CAST(${TABLE}.work_order_id AS VARCHAR), '-') ;;
  }

  dimension: work_order_id_html {
    group_label: "Work Orders"
    label: "Work Order ID"
    type: string
    sql: ${work_order_id} ;;
    html:
      {% if work_order_id._value != '-' %}
        <a href="https://app.estrack.com/#/service/work-orders/{{work_order_id._value}}/updates"
           style="color: blue;"
           target="_blank"><b>{{work_order_id._value}}</b> ➔</a>
      {% else %}
        -
      {% endif %}
      ;;
    skip_drill_filter: yes
  }


  dimension: work_order_type_name {
    type: string
    sql: ${TABLE}.work_order_type_name ;;
    skip_drill_filter: yes
  }

  dimension: severity_level_name {
    type: string
    sql: ${TABLE}.severity_level_name ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}.tags ;;
  }

  # Durations (numeric)
  dimension: asset_duration_days {
    type: number
    sql: ${TABLE}.asset_duration_days ;;
    value_format_name: "decimal_2"
  }

  dimension: breakdown_duration_days {
    type: number
    sql: ${TABLE}.breakdown_duration_days ;;
    value_format_name: "decimal_2"
  }

  # Primary key: create a composite row key for explores/drills
  # (rental_id + asset_id + work_order_id + wo_date) covers fanout well.
  dimension: rental_asset_wo_key {
    primary_key: yes
    hidden: yes
    type: string
    sql:
      CONCAT(
        CAST(${TABLE}.rental_id AS VARCHAR), '-',
        CAST(${TABLE}.asset_id AS VARCHAR), '-',
        COALESCE(CAST(${TABLE}.work_order_id AS VARCHAR), 'no_wo'), '-',
        COALESCE(TO_VARCHAR(${TABLE}.wo_date), 'no_date')
      ) ;;
  }

  # Measures
  measure: row_count {
    type: count
    label: "Row Count"
    drill_fields: [rental_id, asset_id, work_order_id, work_order_type_name, severity_level_name, primary_reason]
  }

  measure: rental_count {
    type: count_distinct
    sql: ${TABLE}.rental_id ;;
    label: "Distinct Rental Count"
  }

  measure: asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    label: "Distinct Asset Count"

    drill_fields: [
      primary_reason,
      rental_id,
      asset_id,
      rental_start_formatted,
      rental_end_formatted,
      asset_start_formatted,
      asset_end_formatted,
      asset_duration_html,
      work_order_id_html,
      work_order_type_name,
      severity_level_name,
      substitution
    ]

    link: {
      label: "Drill Sorted"
      url: "
      {% assign base = link | split: '&sorts=' | first %}
      {{ base }}&sorts=rental_swap_test.asset_start_time+asc
      "
    }
  }

  dimension: asset_duration {
    label: "Asset Duration (Days)"
    type: number
    sql: CASE WHEN ${asset_end_date} = '9999-12-30'
          THEN DATEDIFF('hour', ${asset_start_time}, CURRENT_TIMESTAMP()) / 24.0
          ELSE DATEDIFF('hour', ${asset_start_time}, ${asset_end_time}) / 24.0
          END ;;
    value_format_name: "decimal_1"
  }

  dimension: asset_duration_html {
    label: "Asset Duration"
    type: string
    sql:
    CASE
      WHEN ABS(${asset_duration}) < 1 AND ROUND(ABS(${asset_duration} * 24), 0) = 1
        THEN TO_VARCHAR(ROUND(${asset_duration} * 24, 0)) || ' hour'
      WHEN ABS(${asset_duration}) < 1
        THEN TO_VARCHAR(ROUND(${asset_duration} * 24, 0)) || ' hours'
      WHEN ABS(${asset_duration}) >= 1 AND ABS(${asset_duration}) < 2
        THEN TO_VARCHAR(ROUND(${asset_duration}, 0)) || ' day'
      ELSE TO_VARCHAR(ROUND(${asset_duration}, 0)) || ' days'
    END ;;
  }


  measure: work_order_count {
    type: count_distinct
    sql: ${TABLE}.work_order_id ;;
    label: "Distinct Work Order Count"
  }
}
