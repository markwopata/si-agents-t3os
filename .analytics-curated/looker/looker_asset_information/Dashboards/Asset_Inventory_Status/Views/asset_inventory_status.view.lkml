view: asset_inventory_status {

  derived_table: {
    sql:
  with expanded_assets AS (
    -- Expanding assets across their active date range
    SELECT
        d.dt_date as date,
        ais.asset_id,
        ais.asset_inventory_status,
        ec.equipment_class_id,
        ec.name AS equipment_class_name,
        ais.date_start,
        ais.date_end,
        aa.OEC
    FROM ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY_STATUS ais
    LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa ON ais.asset_id = aa.asset_id
    JOIN OPERATIONAL_ANALYTICS.GOLD.OA_DIM_DATES d on d.dt_date BETWEEN ais.date_start AND COALESCE(ais.date_end, CURRENT_DATE())
        LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
            ON ec.equipment_class_id = aa.equipment_class_id
    WHERE asset_inventory_status IS NOT NULL
    and d.dt_date >= '2023-01-01'
    and d.dt_date <= current_date()
),

ranked_assets AS (
    -- Select most recent status per asset per day
    SELECT
        date,
        asset_id,
        asset_inventory_status,
        oec,
        -- Get the previous day's status for comparison
        LAG(asset_inventory_status) OVER (PARTITION BY asset_id ORDER BY date) AS prev_status,
        -- Identify where the status changes
        CASE
            WHEN LAG(asset_inventory_status) OVER (PARTITION BY asset_id ORDER BY date) <> asset_inventory_status
                OR LAG(asset_inventory_status) OVER (PARTITION BY asset_id ORDER BY date) IS NULL
            THEN 1
            ELSE 0
        END AS status_change_flag
    FROM expanded_assets
),

final_status AS (
    -- Compute consecutive days in the same status (Status Age)
    SELECT
        date,
        asset_id,
        asset_inventory_status,
        oec,
        -- Running count of consecutive days in the same status, resetting on change
        SUM(status_change_flag) OVER (
            PARTITION BY asset_id ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS status_group
    FROM ranked_assets
)

-- Final output with status age
SELECT
    date,
    asset_id,
    asset_inventory_status,
    -- Calculate the consecutive day count within each status period
    ROW_NUMBER() OVER (PARTITION BY asset_id, status_group ORDER BY date) AS status_age,
    CASE WHEN date = CURRENT_DATE() THEN TRUE ELSE FALSE END AS current_flag
FROM final_status
ORDER BY date DESC, asset_id
      ;;
  }

  dimension: pkey {
    type: string
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.asset_id,${TABLE}.date)  ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}.asset_inventory_status ;;
  }

  dimension: status_age {
    type: number
    sql: ${TABLE}.status_age ;;
  }

  dimension: current_flag {
    type: string
    sql: ${TABLE}.current_flag ;;
  }

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.date AS TIMESTAMP_NTZ) ;;
  }


  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }

  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }

  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}
