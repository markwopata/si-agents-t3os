
view: driver_performance {
  derived_table: {
    sql: WITH driver_facing_event_drivers AS (
  SELECT da.operator_id
  FROM analytics.fleetcam.events e
  JOIN analytics.fleetcam.asset_fleetcam_xwalk afx
    ON e.vehicle_id = afx.fleetcam_vehicle_id
  JOIN analytics.fleetcam.driver_assignments da
    ON e.event_date >= da.assignment_time
   AND e.event_date <  COALESCE(da.unassignment_time,'2999-12-31'::timestamp)
   AND afx.es_asset_id = da.asset_id
  WHERE e.event_type_id IN (3,12,13,14,31)
),

driver_information AS (
  SELECT DISTINCT d.operator_id, d.operator_name, d.operator_email
  FROM analytics.fleetcam.drivers d
  WHERE
        EXISTS (
          SELECT 1
          FROM analytics.fleetcam.v_markets_in_program mip
          WHERE mip.market_id = d.market_id
        )
     OR d.employee_title IN (
          'Telematics Installer','Regional Telematics Installer',
          'Mobile Telematics Installer','Telematics Specialist',
          'Regional Lead Telematics Installer',
          'CDL Delivery Driver Apprentice','CDL Apprentice',
          'CDL Driver Apprentice'
        )
     OR (d.market_name = 'No Market' AND TRY_TO_NUMBER(d.region) IN (1,2,3,5,7))
     OR (
          d.market_name = 'No Market'
          AND EXISTS (
            SELECT 1
            FROM driver_facing_event_drivers dfe
            WHERE dfe.operator_id = d.operator_id
          )
        )
),

coaching_completed AS (
  SELECT DISTINCT
    d.operator_id,
    DATE_TRUNC('WEEK', dcmb.coaching_completed_date) AS coaching_week
  FROM analytics.monday.driver_coaching_management_board dcmb
  JOIN es_warehouse.public.users u
    ON LOWER(dcmb.employee_email) = LOWER(u.email_address)
  JOIN analytics.fleetcam.drivers d
    ON d.user_id = u.user_id
  WHERE d.operator_id IN (SELECT operator_id FROM driver_information)
    AND u.deleted = FALSE
    AND (dcmb.coaching_status = 'Coaching Complete'
         OR dcmb.coaching_completed_date IS NOT NULL)
    AND coaching_severity = 'Coaching'
),

-- Integer-only tiers
event_severity_lookup AS (
  SELECT * FROM (VALUES
    ('20+ MPH Over Speed Limit', 5),
    ('Forward Collision Warning', 1),
    --('Camera Covered', 5),
    ('Driver Distracted', 3),
    ('Following Distance Warning', 2),
    --('Driver Smoking', 4),
    ('Driver Using Cell Phone', 5),
    ('Harsh Braking', 2),
    ('10-20 MPH Over Speed Limit', 1),
    ('Following Distance Warning and Harsh Braking', 3),
    ('Forward Collision Warning and Harsh Braking', 3),
    ('Forward Collision Warning and 10-20 MPH Over Speed Limit', 3),
    ('Forward Collision Warning and 20+ MPH Over Speed Limit', 5),
    ('Forward Collision Warning, Harsh Braking, and 10-20 MPH Over Speed Limit', 3),
    ('Forward Collision Warning, Harsh Braking, and 20+ MPH Over Speed Limit', 5)
  ) AS event_severity(event_type, severity_tier)
),


weekly_metrics AS (
  SELECT
    ddp.operator_id,
    di.operator_name,
    DATE_TRUNC('WEEK', ddp.day) AS week_start,
    ddp.event_type,
    SUM(ddp.total_events) AS total_events,
    esl.severity_tier,
    SUM(ddp.total_events * esl.severity_tier) AS weighted_events
  FROM analytics.fleetcam.daily_driver_points ddp
  JOIN driver_information di
    ON ddp.operator_id = di.operator_id
  JOIN event_severity_lookup esl
    ON ddp.event_type = esl.event_type
  GROUP BY ddp.operator_id, di.operator_name,
           DATE_TRUNC('WEEK', ddp.day), ddp.event_type, esl.severity_tier
),

camera_covered_weekly AS (
  SELECT
    ddp.operator_id,
    DATE_TRUNC('WEEK', ddp.day) AS week_start,
    SUM(CASE WHEN ddp.event_type = 'Camera Covered' THEN ddp.total_events ELSE 0 END) AS camera_covered_events
  FROM analytics.fleetcam.daily_driver_points ddp
  GROUP BY 1,2
),

camera_covered_flags AS (
  SELECT
    operator_id,
    week_start,
    CASE WHEN camera_covered_events > 0 THEN 1 ELSE 0 END AS camera_covered_flag
  FROM camera_covered_weekly
),

driver_smoking_weekly AS (
  SELECT
    ddp.operator_id,
    DATE_TRUNC('WEEK', ddp.day) AS week_start,
    SUM(CASE WHEN ddp.event_type = 'Driver Smoking' THEN ddp.total_events ELSE 0 END) AS driver_smoking_events
  FROM analytics.fleetcam.daily_driver_points ddp
  GROUP BY 1,2
),

driver_smoking_flags AS (
  SELECT
    operator_id,
    week_start,
    CASE WHEN driver_smoking_events > 0 THEN 1 ELSE 0 END AS driver_smoking_flag
  FROM driver_smoking_weekly
),

weekly_drive_time_and_mileage AS (
  SELECT
    operator_id,
    DATE_TRUNC('WEEK', trip_start) AS week_start,
    SUM(trip_time_capped - COALESCE(idle_duration,0))/3600 AS total_drive_time,
    SUM(trip_miles) AS total_miles_driven
  FROM analytics.fleetcam.daily_trip_times
  GROUP BY operator_id, DATE_TRUNC('WEEK', trip_start)
),

drive_time_stats AS (
  SELECT
    operator_id,
    AVG(total_drive_time)         AS avg_drive_time,
    STDDEV_SAMP(total_drive_time) AS sd_drive_time
  FROM weekly_drive_time_and_mileage
  WHERE week_start BETWEEN DATEADD(WEEK, -52, DATE_TRUNC('WEEK', CURRENT_DATE))
                       AND DATEADD(WEEK,  -1, DATE_TRUNC('WEEK', CURRENT_DATE))
  GROUP BY operator_id
  HAVING COUNT(*) >= 6 OR MAX(total_drive_time) >= 10
),

unique_weeks AS (
  SELECT DISTINCT operator_id, week_start
  FROM weekly_metrics
),

coaching_history AS (
  SELECT
    uw.operator_id,
    uw.week_start,
    (
      SELECT MAX(cc.coaching_week)
      FROM coaching_completed cc
      WHERE cc.operator_id   = uw.operator_id
        AND cc.coaching_week <= uw.week_start
    ) AS last_coaching_week,
    (
      SELECT COUNT(*)
      FROM coaching_completed cc
      WHERE cc.operator_id   = uw.operator_id
        AND cc.coaching_week <= uw.week_start
    ) AS total_coaching_events
  FROM unique_weeks uw
),

weekly_drive_time_flagged AS (
  SELECT
    uw.operator_id,
    uw.week_start,
    COALESCE(wdm.total_drive_time, 0)   AS total_drive_time,
    COALESCE(wdm.total_miles_driven, 0) AS total_miles_driven,
    CASE
      WHEN COALESCE(wdm.total_drive_time,0) < 1 THEN 1
      WHEN COALESCE(wdm.total_drive_time,0) = 0 THEN 1
      WHEN dts.operator_id IS NULL            THEN 1
      WHEN COALESCE(wdm.total_drive_time,0)
           < LEAST(GREATEST(dts.avg_drive_time - 2 * dts.sd_drive_time, 0), 10)
      THEN 1 ELSE 0
    END AS low_drive_flag
  FROM unique_weeks uw
  LEFT JOIN weekly_drive_time_and_mileage wdm
    ON uw.operator_id = wdm.operator_id
   AND uw.week_start  = wdm.week_start
  LEFT JOIN drive_time_stats dts
    ON uw.operator_id = dts.operator_id
),

driver_weekly_aggregates AS (
  SELECT
    wm.operator_id,
    wm.operator_name,
    wm.week_start,
    SUM(wm.total_events)    AS total_events,
    SUM(wm.weighted_events) AS weighted_events,
    MAX(fd.total_drive_time)    AS total_drive_time,
    MAX(fd.total_miles_driven)  AS total_miles_driven,
    MAX(fd.low_drive_flag)      AS low_drive_flag,
    CASE WHEN MAX(fd.total_drive_time)=0 THEN NULL
         ELSE ROUND(
                SUM(wm.weighted_events) / NULLIF(MAX(fd.total_drive_time),0)
              ,4)
    END AS weighted_events_per_hour,
    SUM(CASE WHEN wm.severity_tier=5 THEN wm.total_events ELSE 0 END) AS tier5_event_count,
    CASE WHEN MAX(fd.total_drive_time)=0 THEN NULL
         ELSE ROUND(
                SUM(CASE WHEN wm.severity_tier=5 THEN wm.total_events ELSE 0 END)
                / NULLIF(MAX(fd.total_drive_time),0)
              ,4)
    END AS tier5_events_per_hour,
    SUM(CASE WHEN wm.severity_tier<>5 THEN wm.total_events ELSE 0 END) AS non_tier5_event_count,
    CASE WHEN MAX(fd.total_drive_time)=0 THEN NULL
         ELSE ROUND(
                SUM(CASE WHEN wm.severity_tier<>5 THEN wm.total_events ELSE 0 END)
                / NULLIF(MAX(fd.total_drive_time),0)
              ,4)
    END AS non_tier5_events_per_hour
  FROM weekly_metrics wm
  LEFT JOIN weekly_drive_time_flagged fd
    ON wm.operator_id = fd.operator_id
   AND wm.week_start  = fd.week_start
  GROUP BY wm.operator_id, wm.operator_name, wm.week_start
),

dynamic_thresholds AS (
  SELECT
    cur.week_start,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY hist.tier5_event_count)        AS sev_count_95,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY hist.tier5_event_count)        AS sev_count_90,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY hist.tier5_event_count)        AS sev_count_75,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY hist.tier5_events_per_hour)    AS sev_ph_95,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY hist.tier5_events_per_hour)    AS sev_ph_90,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY hist.tier5_events_per_hour)    AS sev_ph_75,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY hist.weighted_events_per_hour) AS eph_95,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY hist.weighted_events_per_hour) AS eph_90,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY hist.weighted_events_per_hour) AS eph_75
  FROM (
    SELECT DISTINCT week_start FROM driver_weekly_aggregates
    WHERE week_start < DATE_TRUNC('WEEK', CURRENT_DATE)
  ) cur
  JOIN driver_weekly_aggregates hist
    ON hist.week_start BETWEEN DATEADD(WEEK, -5, cur.week_start) AND DATEADD(WEEK, -1, cur.week_start)
   AND hist.low_drive_flag = 0
  GROUP BY cur.week_start
),

-- Deterministic ranking (break ties by event_type)
event_type_ranking AS (
  SELECT operator_id, week_start, event_type,
         SUM(total_events) AS total_events,
         ROW_NUMBER() OVER (
           PARTITION BY operator_id, week_start
           ORDER BY SUM(total_events) DESC, event_type
         ) AS event_rank
  FROM weekly_metrics
  GROUP BY operator_id, week_start, event_type
  HAVING SUM(total_events) > 0
),

top_contributors AS (
  SELECT operator_id, week_start,
         MAX(CASE WHEN event_rank=1 THEN event_type END) AS primary_contributing_event,
         MAX(CASE WHEN event_rank=2 THEN event_type END) AS secondary_contributing_event
  FROM event_type_ranking
  WHERE event_rank <= 2
  GROUP BY operator_id, week_start
),

ranked_volume AS (
  SELECT
    dwa.*,
    NTILE(3) OVER (PARTITION BY week_start ORDER BY weighted_events DESC) AS volume_tile
  FROM driver_weekly_aggregates dwa
),

/* 1) Rolling stats (prior 4 weeks, exclude low-drive weeks) */
variation_base AS (
  SELECT
    rv.*,
    AVG(CASE WHEN rv.low_drive_flag=0 THEN rv.weighted_events END)
      OVER (
        PARTITION BY rv.operator_id
        ORDER BY rv.week_start
        ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING
      ) AS rolling_avg_events,
    STDDEV_SAMP(CASE WHEN rv.low_drive_flag=0 THEN rv.weighted_events END)
      OVER (
        PARTITION BY rv.operator_id
        ORDER BY rv.week_start
        ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING
      ) AS rolling_sd_events,
    COUNT(CASE WHEN rv.low_drive_flag=0 THEN 1 END)
      OVER (
        PARTITION BY rv.operator_id
        ORDER BY rv.week_start
        ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING
      ) AS non_low_weeks
  FROM ranked_volume rv
),

/* 2) Delta and guarded z-score (require >=2 prior non-low weeks) */
variation_calc AS (
  SELECT
    vb.*,
    ROUND(vb.weighted_events - vb.rolling_avg_events, 2) AS delta_vs_4wk_avg,
    CASE
      WHEN vb.non_low_weeks < 2 OR vb.rolling_sd_events IS NULL OR vb.rolling_sd_events = 0
        THEN NULL
      ELSE (vb.weighted_events - vb.rolling_avg_events) / vb.rolling_sd_events
    END AS z_score,
    CASE vb.volume_tile
      WHEN 1 THEN 'High' WHEN 2 THEN 'Medium' WHEN 3 THEN 'Low' ELSE 'Unclassified'
    END AS volume_tier
  FROM variation_base vb
),

/* 3) Trend using z_score in an outer layer */
variation_final AS (
  SELECT
    vc.*,
    CASE
      WHEN vc.z_score <= -1 THEN 'Improving'
      WHEN vc.z_score >=  1 THEN 'Worsening'
      ELSE 'Flat'
    END AS trend_against_4wk_avg
  FROM variation_calc vc
),

/* Base priority in its own CTE */
base_priority_classified AS (
  SELECT
    sb.*,
    dt.sev_count_95, dt.sev_count_90, dt.sev_count_75,
    dt.sev_ph_95,  dt.sev_ph_90,  dt.sev_ph_75,
    dt.eph_95,     dt.eph_90,     dt.eph_75,
    CASE
      WHEN sb.tier5_event_count        >= dt.sev_count_95
        OR sb.tier5_events_per_hour    >= dt.sev_ph_95
        OR sb.weighted_events_per_hour >= dt.eph_95
        THEN 'Critical'
      WHEN (sb.tier5_event_count BETWEEN dt.sev_count_90 AND dt.sev_count_95)
        OR (sb.tier5_events_per_hour BETWEEN dt.sev_ph_90 AND dt.sev_ph_95)
        OR (sb.weighted_events_per_hour BETWEEN dt.eph_90 AND dt.eph_95)
        THEN 'High'
      WHEN (sb.tier5_event_count BETWEEN dt.sev_count_75 AND dt.sev_count_90)
        OR (sb.tier5_events_per_hour BETWEEN dt.sev_ph_75 AND dt.sev_ph_90)
        OR (sb.weighted_events_per_hour BETWEEN dt.eph_75 AND dt.eph_90)
        THEN 'Medium'
      ELSE 'Low'
    END AS base_priority
  FROM variation_final sb
  LEFT JOIN dynamic_thresholds dt
    ON sb.week_start = dt.week_start
),

/* Coaching priority (now can reference base_priority safely) */
coaching_priority_classified AS (
  SELECT
    bpc.*,
    CASE
      WHEN bpc.base_priority = 'Critical' AND bpc.trend_against_4wk_avg = 'Improving' THEN 'High'
      WHEN bpc.base_priority = 'High'     AND bpc.trend_against_4wk_avg = 'Improving' THEN 'Medium'
      WHEN bpc.base_priority = 'Medium'   AND bpc.trend_against_4wk_avg = 'Improving' THEN 'Low'
      ELSE bpc.base_priority
    END AS coaching_priority
  FROM base_priority_classified bpc
),

priority_streaks_base AS (
  SELECT
    sb.*,
    COUNT(cc.coaching_week) OVER (
      PARTITION BY sb.operator_id
      ORDER BY sb.week_start
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS reset_count
  FROM coaching_priority_classified sb
  LEFT JOIN coaching_completed cc
    ON sb.operator_id = cc.operator_id
   AND sb.week_start  = cc.coaching_week
  WHERE sb.low_drive_flag = 0
),

priority_streaks AS (
  SELECT
    psb.*,
    ROW_NUMBER() OVER (PARTITION BY psb.operator_id ORDER BY psb.week_start) AS rn_all,
    ROW_NUMBER() OVER (
      PARTITION BY psb.operator_id, psb.coaching_priority, psb.reset_count
      ORDER BY psb.week_start
    ) AS rn_grp
  FROM priority_streaks_base psb
),

priority_streaks_final AS (
  SELECT *, rn_all - rn_grp AS streak_group
  FROM priority_streaks
),

final_scored_weeks AS (
  SELECT
    *,
    COUNT(*) OVER (
      PARTITION BY operator_id, coaching_priority, streak_group
      ORDER BY week_start
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS coaching_priority_streak_weeks,
    MIN(week_start) OVER (
      PARTITION BY operator_id, coaching_priority, streak_group
      ORDER BY week_start
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS coaching_priority_streak_start,
    CASE
      WHEN coaching_priority = 'Critical' AND coaching_priority_streak_weeks >= 3 THEN 'Yes'
      WHEN coaching_priority = 'High'     AND coaching_priority_streak_weeks >= 4 THEN 'Yes'
      ELSE 'No'
    END AS coaching_overdue_flag
  FROM priority_streaks_final
),

priority_ranked_filtered AS (
  SELECT
    *,
    RANK() OVER (
      PARTITION BY week_start, coaching_priority
      ORDER BY CASE coaching_overdue_flag WHEN 'Yes' THEN 1 ELSE 2 END,
               coaching_priority_streak_weeks DESC,
               tier5_events_per_hour DESC,
               non_tier5_events_per_hour DESC,
               weighted_events DESC,
               total_drive_time DESC
    ) AS coaching_priority_bucket_rank
  FROM final_scored_weeks
),

priority_with_flagged AS (
  SELECT
    aw.operator_id,
    aw.operator_name,
    aw.week_start,
    aw.low_drive_flag AS is_low_drive_week,
    COALESCE(ccf.camera_covered_flag, 0) AS camera_covered_flag,  -- existing NEW
    COALESCE(dsf.driver_smoking_flag, 0) AS driver_smoking_flag,  -- NEW
    aw.total_events,
    aw.weighted_events AS weighted_event_points,
    aw.total_drive_time,
    aw.total_miles_driven,
    aw.weighted_events_per_hour,
    aw.tier5_event_count,
    aw.tier5_events_per_hour,
    aw.non_tier5_event_count,
    aw.non_tier5_events_per_hour,
    aw.volume_tier AS event_volume_tercile,
    aw.rolling_avg_events AS rolling_avg_4wk_events,
    aw.delta_vs_4wk_avg,
    aw.trend_against_4wk_avg,
    ch.last_coaching_week,
    ch.total_coaching_events,
    prf.coaching_priority_bucket_rank,
    prf.coaching_priority_streak_weeks,
    prf.coaching_priority_streak_start,
    prf.coaching_overdue_flag,
    aw.coaching_priority AS final_priority_bucket,
    tc.primary_contributing_event,
    tc.secondary_contributing_event
  FROM coaching_priority_classified aw
  LEFT JOIN priority_ranked_filtered prf
    ON aw.operator_id = prf.operator_id
   AND aw.week_start  = prf.week_start
  LEFT JOIN top_contributors tc
    ON aw.operator_id = tc.operator_id
   AND aw.week_start  = tc.week_start
  LEFT JOIN coaching_history ch
    ON aw.operator_id = ch.operator_id
   AND aw.week_start  = ch.week_start
  LEFT JOIN camera_covered_flags ccf
    ON aw.operator_id = ccf.operator_id
   AND aw.week_start  = ccf.week_start
  LEFT JOIN driver_smoking_flags dsf
    ON aw.operator_id = dsf.operator_id
   AND aw.week_start  = dsf.week_start
)

SELECT
  final_priority_bucket,
  coaching_priority_bucket_rank,
  operator_id,
  operator_name,
  week_start,
  is_low_drive_week,
  camera_covered_flag,
  driver_smoking_flag,
  total_events,
  weighted_event_points,
  total_drive_time,
  total_miles_driven,
  weighted_events_per_hour,
  tier5_event_count,
  tier5_events_per_hour,
  non_tier5_event_count,
  non_tier5_events_per_hour,
  rolling_avg_4wk_events,
  delta_vs_4wk_avg,
  trend_against_4wk_avg,
  coaching_priority_streak_weeks,
  coaching_priority_streak_start,
  coaching_overdue_flag,
  last_coaching_week,
  total_coaching_events,
  primary_contributing_event,
  secondary_contributing_event
FROM priority_with_flagged ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: final_priority_bucket {
    type: string
    sql: ${TABLE}."FINAL_PRIORITY_BUCKET" ;;
    html:
    {% if value == 'Critical' %}

    <span style="color: #b02a3e;">◉ </span>{{rendered_value}}

    {% elsif value == 'High' %}

    <span style="color: #DA344D;">◉ </span>{{rendered_value}}

    {% elsif value == 'Medium' %}

    <span style="color: #FF8E2B;">◉ </span>{{rendered_value}}

    {% elsif value == 'Low' %}

    <span style="color: #00CB86;">◉ </span>{{rendered_value}}

    {% else %}
    {{rendered_value}}
    {% endif %};;
  }

  dimension: coaching_priority_bucket_rank {
    type: number
    sql: ${TABLE}."COACHING_PRIORITY_BUCKET_RANK" ;;
  }

  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
  }

  dimension: operator_name {
    type: string
    sql: ${TABLE}."OPERATOR_NAME" ;;
  }

  dimension: week_start {
    type: date
    sql: ${TABLE}."WEEK_START" ;;
  }

  dimension: is_low_drive_week {
    label: "Week Excluded"
    type: string
    sql: ${TABLE}."IS_LOW_DRIVE_WEEK";;
    html:
    {% if value == 1 %}
      <span style="color: red;">🚩 Low Drive Week</span>
    {% else %}

    {% endif %};;
  }

      # sql: IFF(${TABLE}."IS_LOW_DRIVE_WEEK" = 1,TRUE,FALSE);;

  dimension: camera_covered_flag {
    type: string
    sql: ${TABLE}."CAMERA_COVERED_FLAG" ;;
  }

  dimension: driver_smoking_flag {
    type: string
    sql: ${TABLE}."DRIVER_SMOKING_FLAG" ;;
  }

  dimension: total_events {
    type: number
    sql: ${TABLE}."TOTAL_EVENTS" ;;
  }

  dimension: weighted_event_points {
    type: number
    sql: ${TABLE}."WEIGHTED_EVENT_POINTS" ;;
  }

  dimension: total_drive_time {
    type: number
    sql: ${TABLE}."TOTAL_DRIVE_TIME" ;;
    value_format_name: decimal_1
  }

  dimension: total_miles_driven {
    type: number
    sql: ${TABLE}."TOTAL_MILES_DRIVEN" ;;
    value_format_name: decimal_1
  }

  dimension: weighted_events_per_hour {
    type: number
    sql: ${TABLE}."WEIGHTED_EVENTS_PER_HOUR" ;;
    value_format_name: decimal_1
  }

  dimension: tier5_event_count {
    label: "Severe Events Count"
    type: number
    sql: ${TABLE}."TIER5_EVENT_COUNT" ;;
  }

  dimension: tier5_events_per_hour {
    label: "Severe Events Per Hour"
    type: number
    sql: ${TABLE}."TIER5_EVENTS_PER_HOUR" ;;
    value_format_name: decimal_1
  }

  dimension: non_tier5_event_count {
    label: "Non Severe Event Count"
    type: number
    sql: ${TABLE}."NON_TIER5_EVENT_COUNT" ;;
  }

  dimension: non_tier5_events_per_hour {
    label: "Non Severe Events Per Hour"
    type: number
    sql: ${TABLE}."NON_TIER5_EVENTS_PER_HOUR" ;;
    value_format_name: decimal_1
  }

  dimension: rolling_avg_4_wk_events {
    type: number
    sql: ${TABLE}."ROLLING_AVG_4WK_EVENTS" ;;
    value_format_name: decimal_1
  }

  dimension: delta_vs_4_wk_avg {
    type: number
    sql: ${TABLE}."DELTA_VS_4WK_AVG" ;;
    value_format_name: decimal_1
  }

  dimension: trend_against_4_wk_avg {
    type: string
    sql: ${TABLE}."TREND_AGAINST_4WK_AVG" ;;
    html:
    {% case value %}
    {% when 'Improving' %}
    <span style="color: green;">↑ Improving</span>
    {% when 'Worsening' %}
    <span style="color: red;">↓ Worsening</span>
    {% when 'Flat' %}
    <span style="color: gray;">→ Flat</span>
    {% else %}
    '{{ value }}'
    {% endcase %} ;;
  }

  dimension: coaching_priority_streak_weeks {
    type: number
    sql: ${TABLE}."COACHING_PRIORITY_STREAK_WEEKS" ;;
  }

  dimension: coaching_priority_streak_start {
    type: date
    sql: ${TABLE}."COACHING_PRIORITY_STREAK_START" ;;
  }

  dimension: coaching_overdue_flag {
    type: string
    sql: ${TABLE}."COACHING_OVERDUE_FLAG" ;;
  }

  dimension: last_coaching_week {
    type: date
    sql: ${TABLE}."LAST_COACHING_WEEK" ;;
  }

  dimension: total_coaching_events {
    type: number
    sql: ${TABLE}."TOTAL_COACHING_EVENTS" ;;
  }

  dimension: primary_contributing_event {
    type: string
    sql: ${TABLE}."PRIMARY_CONTRIBUTING_EVENT" ;;
  }

  dimension: secondary_contributing_event {
    type: string
    sql: ${TABLE}."SECONDARY_CONTRIBUTING_EVENT" ;;
  }

  dimension: final_priority_bucket_ranking {
    type: string
    sql: case
    when ${final_priority_bucket} = 'Critical' then 1
    when ${final_priority_bucket} = 'High' then 2
    when ${final_priority_bucket} = 'Medium' then 3
    when ${final_priority_bucket} = 'Low' then 4
    else 5
    END
    ;;
  }

  measure: severe_events_per_hour {
    type: sum
    sql: ${tier5_events_per_hour} ;;
    value_format_name: decimal_1
  }

  measure: severe_events_event_count {
    type: sum
    sql: ${tier5_event_count} ;;
    value_format_name: decimal_1
  }

  measure: non_severe_events_per_hour {
    type: sum
    sql: ${non_tier5_events_per_hour} ;;
    value_format_name: decimal_1
  }

  measure: non_severe_event_count {
    type: sum
    sql: ${non_tier5_event_count} ;;
    value_format_name: decimal_1
  }

  dimension: operator_name_link {
    group_label: "Operator Name Link"
    label: "Operator Name"
    type: string
    sql: ${operator_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/2133?Operator+Name={{ operator_name._filterable_value | url_encode}}"target="_blank">
    {{rendered_value}} ➔</a></font>
    ;;
  }

  dimension: view_events_link {
    group_label: "View Events Link"
    label: "View Events"
    type: string
    sql: ${operator_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/2138?Operator+Name={{ operator_name._filterable_value | url_encode}}&Event+Date=last+week"target="_blank">
    View Events ➔</a></font>
    ;;
  }

  dimension: view_events_by_week_link {
    group_label: "View Events by Week Link"
    label: "View Events"
    type: string
    sql: ${operator_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/2138?Operator+Name={{ operator_name._filterable_value | url_encode}}&Event+Date={{ week_start._filterable_value | url_encode}}+to+{{ week_end._filterable_value | url_encode}}"target="_blank">
    View Weeks Events ➔</a></font>
    ;;
  }

  dimension: week_end {
    type: date
    sql: dateadd('days',7,${week_start}) ;;
  }

  # https://equipmentshare.looker.com/dashboards/2138?Operator+Name=Taylor+Paulson&Event+Date=2025%2F07%2F20+to+2025%2F07%2F28


  set: detail {
    fields: [
        final_priority_bucket,
  coaching_priority_bucket_rank,
  operator_name,
  week_start,
  is_low_drive_week,
  total_events,
  weighted_event_points,
  total_drive_time,
  total_miles_driven,
  weighted_events_per_hour,
  tier5_event_count,
  tier5_events_per_hour,
  non_tier5_event_count,
  non_tier5_events_per_hour,
  rolling_avg_4_wk_events,
  delta_vs_4_wk_avg,
  trend_against_4_wk_avg,
  coaching_priority_streak_weeks,
  coaching_priority_streak_start,
  coaching_overdue_flag,
  last_coaching_week,
  total_coaching_events,
  primary_contributing_event,
  secondary_contributing_event
    ]
  }
}
