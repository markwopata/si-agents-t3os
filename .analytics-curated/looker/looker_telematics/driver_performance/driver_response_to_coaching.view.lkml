
view: driver_response_to_coaching {
  derived_table: {
    sql: WITH 
      driver_facing_event_drivers AS (
        SELECT da.operator_id
        FROM analytics.fleetcam.events e
        JOIN analytics.fleetcam.asset_fleetcam_xwalk afx
          ON e.vehicle_id = afx.fleetcam_vehicle_id
        JOIN analytics.fleetcam.driver_assignments da
          ON e.event_date BETWEEN da.assignment_time
                             AND COALESCE(da.unassignment_time,'2999-12-31')
           AND afx.es_asset_id = da.asset_id
        WHERE e.event_type_id IN (3,12,13,14,31)
      ),
      
      driver_information AS (
        SELECT DISTINCT operator_id, operator_name, operator_email
        FROM analytics.fleetcam.drivers d
        WHERE market_id IN (SELECT market_id FROM analytics.fleetcam.v_markets_in_program)
           OR employee_title IN (
               'Telematics Installer','Regional Telematics Installer',
               'Mobile Telematics Installer','Telematics Specialist',
               'Regional Lead Telematics Installer',
               'CDL Delivery Driver Apprentice','CDL Apprentice',
               'CDL Driver Apprentice'
             )
           OR (market_name = 'No Market' AND TRY_TO_NUMBER(region) IN (1,2,3,5,7))
           OR operator_id IN (SELECT operator_id FROM driver_facing_event_drivers)
      )
      
      ,
      
      coaching_completed AS (
        SELECT DISTINCT
          d.operator_id,
          DATE_TRUNC('WEEK', dcmb.coaching_completed_date) AS coaching_week,
          dcmb.primary_violation_type,
          dcmb.secondary_violation_type
        FROM analytics.monday.driver_coaching_management_board dcmb
        JOIN es_warehouse.public.users u
          ON LOWER(dcmb.employee_email) = LOWER(u.email_address)
        JOIN analytics.fleetcam.drivers d
          ON d.user_id = u.user_id
        WHERE d.operator_id IN (SELECT operator_id FROM driver_information)
          AND u.deleted = FALSE
          AND dcmb.coaching_status = 'Coaching Complete'
      ),
      
      event_severity_lookup AS (
        SELECT event_type, severity_tier
        FROM VALUES
          ('20+ MPH Over Speed Limit', 5),
          ('Forward Collision Warning', 1),
          ('Camera Covered', 5),
          ('Driver Distracted', 1),
          ('Following Distance Warning', 1),
          ('Driver Smoking', 4),
          ('Driver Using Cell Phone', 5),
          ('Harsh Braking', 1),
          ('10-20 MPH Over Speed Limit', 0.5),
          ('Following Distance Warning and Harsh Breaking', 3)
        AS t(event_type, severity_tier)
      ),
      
      weekly_metrics AS (
        SELECT
          ddp.operator_id,
          di.operator_name,
          DATE_TRUNC('WEEK', ddp.day) AS week_start,
          ddp.event_type,
          SUM(ddp.total_events)            AS total_events,
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
      
      weekly_drive_time_and_mileage AS (
        SELECT
          operator_id,
          DATE_TRUNC('WEEK', trip_start) AS week_start,
          SUM(trip_time_capped - idle_duration)/3600 AS total_drive_time,
          SUM(trip_miles)                AS total_miles_driven
        FROM analytics.fleetcam.daily_trip_times
        GROUP BY operator_id, DATE_TRUNC('WEEK', trip_start)
      ),
      
      drive_time_stats AS (
        SELECT
          operator_id,
          AVG(total_drive_time)         AS avg_drive_time,
          STDDEV_SAMP(total_drive_time) AS sd_drive_time
        FROM weekly_drive_time_and_mileage
        WHERE week_start BETWEEN
          DATEADD(WEEK, -52, DATE_TRUNC('WEEK', CURRENT_DATE))
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
            WHERE cc.operator_id = uw.operator_id
              AND cc.coaching_week <= uw.week_start
          ) AS last_coaching_week,
          (
            SELECT COUNT(*)
            FROM coaching_completed cc
            WHERE cc.operator_id = uw.operator_id
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
            WHEN COALESCE(wdm.total_drive_time,0) = 0 THEN 1
            WHEN dts.operator_id IS NULL         THEN 1
            WHEN COALESCE(wdm.total_drive_time,0)
                 < LEAST(dts.avg_drive_time - 2 * dts.sd_drive_time, 10)
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
          CASE 
            WHEN MAX(fd.total_drive_time)=0 THEN NULL
            ELSE ROUND(
                   SUM(wm.weighted_events)
                   / NULLIF(MAX(fd.total_drive_time),0)
                 ,4)
          END AS weighted_events_per_hour,
          SUM(CASE WHEN wm.severity_tier=5 THEN wm.total_events ELSE 0 END) AS tier5_event_count,
          CASE 
            WHEN MAX(fd.total_drive_time)=0 THEN NULL
            ELSE ROUND(
                   SUM(CASE WHEN wm.severity_tier=5 THEN wm.total_events ELSE 0 END)
                   / NULLIF(MAX(fd.total_drive_time),0)
                 ,4)
          END AS tier5_events_per_hour,
          SUM(CASE WHEN wm.severity_tier<>5 THEN wm.total_events ELSE 0 END) AS non_tier5_event_count,
          CASE 
            WHEN MAX(fd.total_drive_time)=0 THEN NULL
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
          PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY h.tier5_event_count)        AS sev_count_95,
          PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY h.tier5_event_count)        AS sev_count_90,
          PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY h.tier5_event_count)        AS sev_count_75,
          PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY h.tier5_events_per_hour)    AS sev_ph_95,
          PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY h.tier5_events_per_hour)    AS sev_ph_90,
          PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY h.tier5_events_per_hour)    AS sev_ph_75,
          PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY h.weighted_events_per_hour) AS eph_95,
          PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY h.weighted_events_per_hour) AS eph_90,
          PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY h.weighted_events_per_hour) AS eph_75
        FROM (
          SELECT DISTINCT week_start
          FROM driver_weekly_aggregates
          WHERE week_start < DATE_TRUNC('WEEK', CURRENT_DATE)
        ) cur
        JOIN driver_weekly_aggregates h
          ON h.week_start BETWEEN DATEADD(WEEK, -5, cur.week_start)
                             AND DATEADD(WEEK, -1, cur.week_start)
             AND h.low_drive_flag = 0
        GROUP BY cur.week_start
      ),
      
      event_type_ranking AS (
        SELECT
          operator_id, week_start, event_type,
          SUM(total_events) AS total_events,
          RANK() OVER (
            PARTITION BY operator_id, week_start
            ORDER BY SUM(total_events) DESC
          ) AS event_rank
        FROM weekly_metrics
        GROUP BY operator_id, week_start, event_type
      ),
      
      top_contributors AS (
        SELECT
          operator_id, week_start,
          MAX(CASE WHEN event_rank=1 THEN event_type END) AS primary_contributing_event,
          MAX(CASE WHEN event_rank=2 THEN event_type END) AS secondary_contributing_event
        FROM event_type_ranking
        WHERE event_rank <= 2
        GROUP BY operator_id, week_start
      ),
      
      ranked_volume AS (
        SELECT
          dwa.*,
          NTILE(3) OVER (
            PARTITION BY week_start
            ORDER BY weighted_events DESC
          ) AS volume_tile
        FROM driver_weekly_aggregates dwa
      ),
      
      variation_calc AS (
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
          ROUND(
            rv.weighted_events
            - AVG(CASE WHEN rv.low_drive_flag=0 THEN rv.weighted_events END)
              OVER (
                PARTITION BY rv.operator_id
                ORDER BY rv.week_start
                ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING
              )
          ,2) AS delta_vs_4wk_avg,
          (
            rv.weighted_events
            - AVG(CASE WHEN rv.low_drive_flag=0 THEN rv.weighted_events END)
              OVER (
                PARTITION BY rv.operator_id
                ORDER BY rv.week_start
                ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING
              )
          ) / NULLIF(
            STDDEV_SAMP(CASE WHEN rv.low_drive_flag=0 THEN rv.weighted_events END)
              OVER (
                PARTITION BY rv.operator_id
                ORDER BY rv.week_start
                ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING
              )
          ,0) AS z_score,
          CASE
            WHEN z_score <= -1 THEN 'Improving'
            WHEN z_score >=  1 THEN 'Worsening'
            ELSE 'Flat'
          END AS trend_against_4wk_avg,
          CASE
            WHEN rv.volume_tile=1 THEN 'High'
            WHEN rv.volume_tile=2 THEN 'Medium'
            WHEN rv.volume_tile=3 THEN 'Low'
            ELSE 'Unclassified'
          END AS volume_tier
        FROM ranked_volume rv
      ),
      
      coaching_priority_classified AS (
        SELECT
          sb.operator_id,
          sb.operator_name,
          sb.week_start,
          sb.total_events,
          sb.weighted_events,
          sb.total_drive_time,
          sb.total_miles_driven,
          sb.low_drive_flag,
          sb.weighted_events_per_hour,
          sb.tier5_event_count,
          sb.tier5_events_per_hour,
          sb.non_tier5_event_count,
          sb.non_tier5_events_per_hour,
          sb.volume_tier,
          sb.rolling_avg_events,
          sb.delta_vs_4wk_avg,
          sb.trend_against_4wk_avg,
          dt.sev_count_95,
          dt.sev_count_90,
          dt.sev_count_75,
          dt.sev_ph_95,
          dt.sev_ph_90,
          dt.sev_ph_75,
          dt.eph_95,
          dt.eph_90,
          dt.eph_75,
          CASE
            WHEN sb.tier5_event_count >= dt.sev_count_95
              OR sb.tier5_events_per_hour >= dt.sev_ph_95
              OR sb.weighted_events_per_hour >= dt.eph_95 THEN 'Critical'
            WHEN sb.tier5_event_count BETWEEN dt.sev_count_90 AND dt.sev_count_95
              OR sb.tier5_events_per_hour BETWEEN dt.sev_ph_90 AND dt.sev_ph_95
              OR sb.weighted_events_per_hour BETWEEN dt.eph_90 AND dt.eph_95 THEN 'High'
            WHEN sb.tier5_event_count BETWEEN dt.sev_count_75 AND dt.sev_count_90
              OR sb.tier5_events_per_hour BETWEEN dt.sev_ph_75 AND dt.sev_ph_90
              OR sb.weighted_events_per_hour BETWEEN dt.eph_75 AND dt.eph_90 THEN 'Medium'
            ELSE 'Low'
          END AS base_priority,
          CASE
            WHEN base_priority='Critical' AND sb.trend_against_4wk_avg='Improving' THEN 'High'
            WHEN base_priority='High'     AND sb.trend_against_4wk_avg='Improving' THEN 'Medium'
            WHEN base_priority='Medium'   AND sb.trend_against_4wk_avg='Improving' THEN 'Low'
            ELSE base_priority
          END AS coaching_priority
        FROM variation_calc sb
        JOIN dynamic_thresholds dt
          ON sb.week_start = dt.week_start
      ),
      
      priority_streaks_base AS (
        SELECT
          psb.*,
          COUNT(cc.coaching_week) OVER (
            PARTITION BY psb.operator_id
            ORDER BY psb.week_start
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
          ) AS reset_count
        FROM coaching_priority_classified psb
        LEFT JOIN coaching_completed cc
          ON psb.operator_id = cc.operator_id
         AND psb.week_start  = cc.coaching_week
        WHERE psb.low_drive_flag = 0
      ),
      
      priority_streaks AS (
        SELECT
          psb.*,
          ROW_NUMBER() OVER (
            PARTITION BY psb.operator_id
            ORDER BY psb.week_start
          ) AS rn_all,
          ROW_NUMBER() OVER (
            PARTITION BY psb.operator_id, psb.coaching_priority, psb.reset_count
            ORDER BY psb.week_start
          ) AS rn_grp
        FROM priority_streaks_base psb
      ),
      
      priority_streaks_final AS (
        SELECT
          *,
          rn_all - rn_grp AS streak_group
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
            WHEN coaching_priority='Critical' AND coaching_priority_streak_weeks>=2 THEN 'Yes'
            WHEN coaching_priority='High'     AND coaching_priority_streak_weeks>=3 THEN 'Yes'
            ELSE 'No'
          END AS coaching_overdue_flag
        FROM priority_streaks_final
      ),
      
      priority_ranked_filtered AS (
        SELECT
          *,
          RANK() OVER (
            PARTITION BY week_start, coaching_priority
            ORDER BY
              CASE coaching_overdue_flag WHEN 'Yes' THEN 1 ELSE 2 END,
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
          aw.low_drive_flag      AS is_low_drive_week,
          aw.total_events,
          aw.weighted_events     AS weighted_event_points,
          aw.total_drive_time,
          aw.total_miles_driven,
          aw.weighted_events_per_hour,
          aw.tier5_event_count,
          aw.tier5_events_per_hour,
          aw.non_tier5_event_count,
          aw.non_tier5_events_per_hour,
          aw.volume_tier         AS event_volume_tercile,
          aw.rolling_avg_events  AS rolling_avg_4wk_events,
          aw.delta_vs_4wk_avg,
          aw.trend_against_4wk_avg,
          ch.last_coaching_week,
          ch.total_coaching_events,
          prf.coaching_priority_bucket_rank,
          prf.coaching_priority_streak_weeks,
          prf.coaching_priority_streak_start,
          prf.coaching_overdue_flag,
          aw.coaching_priority   AS final_priority_bucket,
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
      ),
      
      pre_post AS (
        SELECT
          cc.operator_id,
          cc.coaching_week,
          pf.operator_name,
          pf.week_start,
          pf.total_events,
          pf.weighted_event_points,
          pf.weighted_events_per_hour,
          pf.tier5_event_count,
          pf.tier5_events_per_hour,
          pf.non_tier5_event_count,
          pf.non_tier5_events_per_hour,
          pf.total_drive_time,
          pf.total_miles_driven,
          pf.is_low_drive_week,
          pf.event_volume_tercile,
          pf.rolling_avg_4wk_events,
          pf.delta_vs_4wk_avg,
          pf.trend_against_4wk_avg,
          pf.final_priority_bucket,
          pf.primary_contributing_event,
          pf.secondary_contributing_event,
          CASE
            WHEN pf.week_start < cc.coaching_week THEN 'pre'
            WHEN pf.week_start > cc.coaching_week THEN 'post'
            ELSE 'week_of'
          END AS period
        FROM coaching_completed cc
        JOIN priority_with_flagged pf
          ON cc.operator_id = pf.operator_id
         AND pf.week_start BETWEEN 
             DATEADD(WEEK, -4, cc.coaching_week)
             AND DATEADD(WEEK,  4, cc.coaching_week)
      ),
      
      period_summary AS (
        SELECT
          operator_id,
          operator_name,
          coaching_week,
          period,
          AVG(total_events)               AS avg_total_events,
          AVG(weighted_event_points)      AS avg_weighted_points,
          AVG(weighted_events_per_hour)   AS avg_weighted_per_hr,
          AVG(tier5_event_count)          AS avg_tier5_count,
          AVG(tier5_events_per_hour)      AS avg_tier5_per_hr,
          AVG(non_tier5_event_count)      AS avg_non_tier5_count,
          AVG(non_tier5_events_per_hour)  AS avg_non_tier5_per_hr,
          AVG(total_drive_time)           AS avg_drive_time,
          AVG(total_miles_driven)         AS avg_miles_driven,
          AVG(is_low_drive_week)          AS pct_low_drive_weeks,
          SUM(CASE WHEN event_volume_tercile='High'   THEN 1 ELSE 0 END)/COUNT(*)   AS pct_high_volume_weeks,
          SUM(CASE WHEN event_volume_tercile='Medium' THEN 1 ELSE 0 END)/COUNT(*)   AS pct_med_volume_weeks,
          SUM(CASE WHEN event_volume_tercile='Low'    THEN 1 ELSE 0 END)/COUNT(*)   AS pct_low_volume_weeks
        FROM pre_post
        WHERE period IN ('pre','post')
        GROUP BY operator_id, operator_name, coaching_week, period
      )
      
      SELECT
        pre.operator_id,
        pre.operator_name,
        pre.coaching_week,
      
        pre.avg_total_events   AS pre_avg_total_events,
        post.avg_total_events  AS post_avg_total_events,
        ROUND(post.avg_total_events - pre.avg_total_events, 2) AS delta_total_events,
      
        pre.avg_weighted_points   AS pre_avg_weighted_points,
        post.avg_weighted_points  AS post_avg_weighted_points,
        ROUND(post.avg_weighted_points - pre.avg_weighted_points, 2) AS delta_weighted_points,
      
        pre.avg_weighted_per_hr   AS pre_avg_weighted_per_hr,
        post.avg_weighted_per_hr  AS post_avg_weighted_per_hr,
        ROUND(post.avg_weighted_per_hr - pre.avg_weighted_per_hr, 4) AS delta_weighted_per_hr,
      
        pre.avg_tier5_count       AS pre_avg_tier5_count,
        post.avg_tier5_count      AS post_avg_tier5_count,
        ROUND(post.avg_tier5_count - pre.avg_tier5_count, 2) AS delta_tier5_count,
      
        pre.avg_tier5_per_hr      AS pre_avg_tier5_per_hr,
        post.avg_tier5_per_hr     AS post_avg_tier5_per_hr,
        ROUND(post.avg_tier5_per_hr - pre.avg_tier5_per_hr, 4) AS delta_tier5_per_hr,
      
        pre.avg_non_tier5_count    AS pre_avg_non_tier5_count,
        post.avg_non_tier5_count   AS post_avg_non_tier5_count,
        ROUND(post.avg_non_tier5_count - pre.avg_non_tier5_count, 2) AS delta_non_tier5_count,
      
        pre.avg_non_tier5_per_hr   AS pre_avg_non_tier5_per_hr,
        post.avg_non_tier5_per_hr  AS post_avg_non_tier5_per_hr,
        ROUND(post.avg_non_tier5_per_hr - pre.avg_non_tier5_per_hr, 4) AS delta_non_tier5_per_hr,
      
        pre.avg_drive_time        AS pre_avg_drive_time,
        post.avg_drive_time       AS post_avg_drive_time,
        ROUND(post.avg_drive_time - pre.avg_drive_time, 2) AS delta_drive_time,
      
        pre.avg_miles_driven      AS pre_avg_miles_driven,
        post.avg_miles_driven     AS post_avg_miles_driven,
        ROUND(post.avg_miles_driven - pre.avg_miles_driven, 2) AS delta_miles_driven,
        cc.primary_violation_type,
        cc.secondary_violation_type
      
      FROM period_summary pre
      JOIN period_summary post
        ON pre.operator_id   = post.operator_id
       AND pre.coaching_week = post.coaching_week
       AND pre.period       = 'pre'
       AND post.period      = 'post'
      join coaching_completed cc on cc.operator_id = pre.operator_id AND cc.coaching_week = pre.coaching_week
      ORDER BY pre.operator_name, pre.coaching_week ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
  }

  dimension: operator_name {
    type: string
    sql: ${TABLE}."OPERATOR_NAME" ;;
  }

  dimension: coaching_week {
    type: date
    sql: ${TABLE}."COACHING_WEEK" ;;
  }

  dimension: pre_avg_total_events {
    type: number
    sql: ${TABLE}."PRE_AVG_TOTAL_EVENTS" ;;
  }

  dimension: post_avg_total_events {
    type: number
    sql: ${TABLE}."POST_AVG_TOTAL_EVENTS" ;;
  }

  dimension: delta_total_events {
    type: number
    sql: ${TABLE}."DELTA_TOTAL_EVENTS" ;;
  }

  dimension: pre_avg_weighted_points {
    type: number
    sql: ${TABLE}."PRE_AVG_WEIGHTED_POINTS" ;;
  }

  dimension: post_avg_weighted_points {
    type: number
    sql: ${TABLE}."POST_AVG_WEIGHTED_POINTS" ;;
  }

  dimension: delta_weighted_points {
    type: number
    sql: ${TABLE}."DELTA_WEIGHTED_POINTS" ;;
  }

  dimension: pre_avg_weighted_per_hr {
    type: number
    sql: ${TABLE}."PRE_AVG_WEIGHTED_PER_HR" ;;
  }

  dimension: post_avg_weighted_per_hr {
    type: number
    sql: ${TABLE}."POST_AVG_WEIGHTED_PER_HR" ;;
  }

  dimension: delta_weighted_per_hr {
    type: number
    sql: ${TABLE}."DELTA_WEIGHTED_PER_HR" ;;
  }

  dimension: pre_avg_tier5_count {
    type: number
    sql: ${TABLE}."PRE_AVG_TIER5_COUNT" ;;
  }

  dimension: post_avg_tier5_count {
    type: number
    sql: ${TABLE}."POST_AVG_TIER5_COUNT" ;;
  }

  dimension: delta_tier5_count {
    type: number
    sql: ${TABLE}."DELTA_TIER5_COUNT" ;;
  }

  dimension: pre_avg_tier5_per_hr {
    type: number
    sql: ${TABLE}."PRE_AVG_TIER5_PER_HR" ;;
  }

  dimension: post_avg_tier5_per_hr {
    type: number
    sql: ${TABLE}."POST_AVG_TIER5_PER_HR" ;;
  }

  dimension: delta_tier5_per_hr {
    type: number
    sql: ${TABLE}."DELTA_TIER5_PER_HR" ;;
  }

  dimension: pre_avg_non_tier5_count {
    type: number
    sql: ${TABLE}."PRE_AVG_NON_TIER5_COUNT" ;;
  }

  dimension: post_avg_non_tier5_count {
    type: number
    sql: ${TABLE}."POST_AVG_NON_TIER5_COUNT" ;;
  }

  dimension: delta_non_tier5_count {
    type: number
    sql: ${TABLE}."DELTA_NON_TIER5_COUNT" ;;
  }

  dimension: pre_avg_non_tier5_per_hr {
    type: number
    sql: ${TABLE}."PRE_AVG_NON_TIER5_PER_HR" ;;
  }

  dimension: post_avg_non_tier5_per_hr {
    type: number
    sql: ${TABLE}."POST_AVG_NON_TIER5_PER_HR" ;;
  }

  dimension: delta_non_tier5_per_hr {
    type: number
    sql: ${TABLE}."DELTA_NON_TIER5_PER_HR" ;;
  }

  dimension: pre_avg_drive_time {
    type: number
    sql: ${TABLE}."PRE_AVG_DRIVE_TIME" ;;
  }

  dimension: post_avg_drive_time {
    type: number
    sql: ${TABLE}."POST_AVG_DRIVE_TIME" ;;
  }

  dimension: delta_drive_time {
    type: number
    sql: ${TABLE}."DELTA_DRIVE_TIME" ;;
  }

  dimension: pre_avg_miles_driven {
    type: number
    sql: ${TABLE}."PRE_AVG_MILES_DRIVEN" ;;
  }

  dimension: post_avg_miles_driven {
    type: number
    sql: ${TABLE}."POST_AVG_MILES_DRIVEN" ;;
  }

  dimension: delta_miles_driven {
    type: number
    sql: ${TABLE}."DELTA_MILES_DRIVEN" ;;
  }

  dimension: primary_violation_type {
    type: string
    sql: ${TABLE}."PRIMARY_VIOLATION_TYPE" ;;
  }

  dimension: secondary_violation_type {
    type: string
    sql: ${TABLE}."SECONDARY_VIOLATION_TYPE" ;;
  }

  set: detail {
    fields: [
        operator_id,
	operator_name,
	coaching_week,
	pre_avg_total_events,
	post_avg_total_events,
	delta_total_events,
	pre_avg_weighted_points,
	post_avg_weighted_points,
	delta_weighted_points,
	pre_avg_weighted_per_hr,
	post_avg_weighted_per_hr,
	delta_weighted_per_hr,
	pre_avg_tier5_count,
	post_avg_tier5_count,
	delta_tier5_count,
	pre_avg_tier5_per_hr,
	post_avg_tier5_per_hr,
	delta_tier5_per_hr,
	pre_avg_non_tier5_count,
	post_avg_non_tier5_count,
	delta_non_tier5_count,
	pre_avg_non_tier5_per_hr,
	post_avg_non_tier5_per_hr,
	delta_non_tier5_per_hr,
	pre_avg_drive_time,
	post_avg_drive_time,
	delta_drive_time,
	pre_avg_miles_driven,
	post_avg_miles_driven,
	delta_miles_driven,
	primary_violation_type,
	secondary_violation_type
    ]
  }
}
