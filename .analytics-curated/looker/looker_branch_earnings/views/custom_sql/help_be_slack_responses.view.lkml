view: help_be_slack_responses {
  derived_table: {
    sql:
      with date_ranges as (
          select
              pp.display,
              pp.date_published,
              pp.date_published::datetime as start_date,
              lead(pp.date_published::datetime, 1, '2050-01-01'::datetime)
                  over (order by pp.date_published) as end_date,
              pp.date_published as sort_date
          from
              analytics.dbt_seeds.seed_plexi_periods as pp
          where
              pp.date_published is not null
          order by
              pp.date_published desc
      )
      select
          sr.id as pk,
          case
              when coalesce({% parameter company_granularity %}, 'company') = 'region' then sr.region
              when coalesce({% parameter company_granularity %}, 'company') = 'district' then sr.district
              when coalesce({% parameter company_granularity %}, 'company') = 'market' then mrx.market_name
              else 'Total Company'
          end as grouping,
          case
              when coalesce({% parameter timeframe_granularity %}, 'month') = 'year' then left(dr.display, 4)
              when coalesce({% parameter timeframe_granularity %}, 'month') = 'quarter' then
                  left(dr.display, 4) || 'q' || date_part(quarter, dr.start_date)
              when coalesce({% parameter timeframe_granularity %}, 'month') = 'day' then left(dr.display, 10)
              else dr.display
          end as period,
          dr.sort_date as sort_date,
          case
              when sr.thread_ts is null then 'Original Message'
              else 'Thread Reply'
          end as message_type,
          sr.*
      from
          analytics.branch_earnings.slack_responses as sr
          left join analytics.public.market_region_xwalk as mrx
              on sr.market_id::varchar = mrx.market_id::varchar
          join date_ranges as dr
              on sr.event_date between dr.start_date and dr.end_date
      where
          sr.region != 'Corp'
          and sr.district != 'Corporate'
          and sr.thread_ts is null -- No thread replies.
          and sr.prod_level = 'prod'
      order by
          dr.sort_date
    ;;
  }

  parameter: start_date {
    type: date
  }

  parameter: end_date {
    type: date
  }

  parameter: timeframe_granularity {
    description: "Group responses in dashboard at either a month or quarter granularity"
    allowed_value: {
      label: "Month"
      value: "month"
    }
    allowed_value: {
      label: "Quarter"
      value: "quarter"
    }
    allowed_value: {
      label: "Year"
      value: "year"
    }
    allowed_value: {
      label: "Day"
      value: "day"
    }
  }

  parameter: company_granularity {
    description: "Group responses in dashboard by region, district, market or total company"
    allowed_value: {
      label: "Region"
      value: "region"
    }
    allowed_value: {
      label: "District"
      value: "district"
    }
    allowed_value: {
      label: "Market"
      value: "market"
    }
    allowed_value: {
      label: "Company"
      value: "company"
    }
  }

  dimension: pk {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK" ;;
  }

  dimension: event_date {
    label: "Message Date"
    type: date
    sql: ${TABLE}."EVENT_DATE" ;;
  }

  dimension: period {
    label: "Period"
    type: string
    sql: ${TABLE}."PERIOD" ;;
  }

  dimension: grouping {
    label: "Grouping"
    type: string
    sql: ${TABLE}."GROUPING" ;;
  }

  dimension: sort_date {
    label: "Sort Date"
    type: date
    sql: ${TABLE}."SORT_DATE" ;;
  }

  dimension: employee_id {
    label: "Employee ID"
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: full_name {
    label: "Employee Name"
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: channel_id {
    type: string
    hidden: yes
    sql: ${TABLE}."CHANNEL_ID" ;;
  }

  dimension: message_ts {
    type: string
    hidden: yes
    sql: ${TABLE}."MESSAGE_TS" ;;
  }

  dimension: thread_ts {
    type: string
    hidden: yes
    sql: ${TABLE}."THREAD_TS" ;;
  }

  dimension: message_type {
    label: "Message Type"
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension: message_text {
    label: "Message Text"
    type: string
    sql: ${TABLE}."MESSAGE_TEXT" ;;
  }

  dimension: user_name {
    type: string
    hidden: yes
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: user_id {
    type: string
    hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_email {
    label: "Employee Email"
    type: string
    sql: ${TABLE}."USER_EMAIL" ;;
  }

  dimension: url_slack {
    label: "Message URL"
    type: string
    sql: ${TABLE}."URL_SLACK" ;;
  }

  dimension: is_branch_earnings_team {
    type: yesno
    sql: ${TABLE}."IS_BRANCH_EARNINGS_TEAM" ;;
  }

  dimension: prod_level {
    type: string
    hidden: yes
    sql: ${TABLE}."PROD_LEVEL" ;;
  }

  measure: message_count {
    label: "Message Count"
    type: count_distinct
    sql: ${TABLE}."ID" ;;
  }
}
