view: account_lifecycle_details {

  derived_table: {
    sql:
    -- your SQL unchanged
    with collector_types as (
        select
            company_id,
            company_name,
            market_name,
            snapshot_date,
            case
                when final_collector ilike '%BAD DEBT WRITE OFF%' then 'Bad Debt Write Off'
                when final_collector ilike '%PRE-LEGAL%' then 'Pre-Legal'
                when final_collector ilike 'LEGAL%' then 'Legal'
                when final_collector ilike '%THIRD PARTY%' then 'Third Party'
                else 'Market Collector'
            end as collector_type
        from analytics.bi_ops.collector_customer_assignments_daily_snapshot
    ),

      snapshot_with_lag as (
      select
      company_id,
      company_name,
      market_name,
      snapshot_date,
      collector_type,
      lag(collector_type) over (
      partition by company_id
      order by snapshot_date
      ) as prev_collector_type
      from collector_types
      ),

      change_points as (
      select
      company_id,
      company_name,
      market_name,
      snapshot_date as window_start_date,
      collector_type,
      prev_collector_type
      from snapshot_with_lag
      where collector_type is distinct from prev_collector_type
      ),

      windows as (
      select
      company_id,
      company_name,
      market_name,
      window_start_date,
      collector_type,
      prev_collector_type,
      coalesce(
      lead(window_start_date) over (
      partition by company_id
      order by window_start_date
      ) - 1,
      current_date
      ) as window_end_date
      from change_points
      )


      select
      *,
      count(*) over (partition by company_id) as change_count,
      case
        when collector_type = 'Market Collector'
        and prev_collector_type <> 'Market Collector'
        then true
        when collector_type = 'Bad Debt Write Off'
        then true
        else false
      end as resolved,
      -- Add company-level resolved flag
      max(case
        when collector_type = 'Market Collector'
        and prev_collector_type <> 'Market Collector'
        then true
        when collector_type = 'Bad Debt Write Off'
        then true
        else false
      end) over (partition by company_id) as company_is_resolved
      from windows

      ;;
  }

  # =========================
  # 🏢 Company Info
  # =========================

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: change_count {
    type: number
    sql: ${TABLE}.change_count ;;
  }

  # =========================
  # 📅 Dates
  # =========================

  dimension_group: window_start {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.window_start_date ;;
  }

  dimension_group: window_end {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.window_end_date ;;
  }

  measure: pre_legal_date {
    type: date
    sql: MIN(case
      when ${collector_type} = 'Pre-Legal'
      then ${window_start_date}
      else null
    end) ;;
  }

  measure: legal_date {
    type: date
    sql: MIN(case
      when ${collector_type} = 'Legal'
      then ${window_start_date}
      else null
    end) ;;
  }

  measure: third_party_date {
    type: date
    sql: MIN(case
      when ${collector_type} = 'Third Party'
      then ${window_start_date}
      else null
    end) ;;
  }

  measure: resolution_date {
    type: date
    sql: MIN(case
      when ${resolved} = true
      then ${window_start_date}
      else null
    end) ;;
  }

  # =========================
  # 🔁 Collector State
  # =========================

  dimension: collector_type {
    type: string
    sql: ${TABLE}.collector_type ;;
  }

  dimension: previous_collector_type {
    type: string
    sql: ${TABLE}.prev_collector_type ;;
  }

  dimension: resolved {
    type: yesno
    sql: ${TABLE}.resolved ;;
  }

  dimension: company_is_resolved {
    type: yesno
    sql: ${TABLE}.company_is_resolved ;;
  }

  dimension: is_escalated {
    type: yesno
    sql: case when ${collector_type} != 'Market Collector' then true else false end ;;
  }

  dimension: escalation_type {
    type: string
    sql:
      case
        when ${collector_type} = 'Market Collector' then null
        else ${collector_type}
      end ;;
  }

  # =========================
  # ⏳ Duration Metrics
  # =========================

  dimension: window_length_days {
    type: number
    sql: datediff(day, ${window_start_date}, ${window_end_date}) + 1 ;;
  }

  dimension: is_active_window {
    type: yesno
    sql: case when ${window_end_date} = current_date then true else false end ;;
  }

  # =========================
  # 📊 Measures
  # =========================

  measure: count {
    type: count
  }

  measure: resolution {
    type: string
    sql:
    MAX(case
      when ${resolved} = true and ${collector_type} = 'Market Collector'
        then 'Paid'
      when ${resolved} = true and ${collector_type} = 'Bad Debt Write Off'
        then 'Write Off'
      else null
    end) ;;
  }

  measure: companies {
    type: count_distinct
    sql: ${company_id} ;;
  }

  measure: escalations {
    type: count
    filters: [collector_type: "-Market Collector"]
  }

  measure: resolutions {
    type: count
    filters: [resolved: "yes"]
  }

  measure: total_escalation_days {
    type: sum
    sql: ${window_length_days} ;;
    filters: [collector_type: "-Market Collector"]
  }

  measure: avg_escalation_days {
    type: average
    sql: ${window_length_days} ;;
    filters: [collector_type: "-Market Collector"]
  }

}
