view: webex_branch_rollovers {

  derived_table: {
    sql:
      select distinct
          cd.*,
      DATEADD(minute,cd.site_timezone,cd.start_time)::date as start_date,
      case
      when (cd.called_number = '2300')
      and cd.redirecting_number is not null
      and cd.redirecting_number <> ''
      then cd.correlation_id
      else null
      end as calls_rolled_to_queue,

      case
      when cd.answer_time IS NULL
      AND cd.releasing_party = 'Remote'
      then cd.correlation_id
      else null
      end as abandoned_calls,
      datediff('second', cd.start_time, cd.answer_time) as queue_time_seconds,
      datediff('second', cd.answer_time, cd.release_time) as talk_time_seconds,
      case
      when cd.redirecting_number = '2300'
      and cd.called_number = '+18336541665'
      then cd.correlation_id
      else null
      end as rolled_to_cs_call

      from INBOUND.WEBEX.CALL_HISTORY_DETAILS cd
      where cd.correlation_id IN
      (
        select correlation_id
        from INBOUND.WEBEX.CALL_HISTORY_DETAILS
        group by correlation_id
        having COUNT(*) > 1
            AND SUM(
                CASE
                    WHEN redirect_reason = 'TimeOfDay' THEN 1
                    ELSE 0
                END
            ) = 0
      )
      ;;
  }

# DIMENSIONS

  dimension: start_date {
    description: "Date the call occurred"
    type: date
    sql: ${TABLE}.start_date  ;;
  }

  dimension: location {
    description: "Location of the call"
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: user {
    description: "Name of user in position or queue"
    type: string
    sql: ${TABLE}.user ;;
  }

  dimension: user_type {
    description: "Name of the user type"
    type: string
    sql: ${TABLE}.user_type ;;
  }

  dimension: dialed_digits {
    type: string
    sql: ${TABLE}.dialed_digits ;;
  }

  dimension: called_number {
    description: "Number of party getting called"
    type: string
    sql: ${TABLE}.called_number ;;
  }

  dimension: calling_number {
    description: "Number of caller"
    type: string
    sql: ${TABLE}.calling_number ;;
  }

  dimension: redirecting_number {
    description: "Number of party that redirected the call"
    type: string
    sql: ${TABLE}.redirecting_number ;;
  }

  dimension: answered {
    description: "Indicator if a call was answered or not"
    type: string
    sql: CASE WHEN upper(${TABLE}.answered) = 'TRUE' THEN 'Answered' ELSE 'Missed' END ;;
  }

  dimension: answer_indicator {
    description: "Answer flag with detail"
    type: string
    sql: ${TABLE}.answer_indicator ;;
  }

  dimension: start_time {
    description: "Time the call was started"
    type: date_time
    sql: DATEADD(minute,${TABLE}.site_timezone,${TABLE}.start_time) ;;
  }

  dimension: answer_time {
    description: "Time the call was answered"
    type: date_time
    sql: DATEADD(minute,${TABLE}.site_timezone,${TABLE}.answer_time) ;;
  }

  dimension: release_time {
    description: "Time the call was ended"
    type: date_time
    sql: DATEADD(minute,${TABLE}.site_timezone,${TABLE}.release_time) ;;
  }

  dimension: site_timezone {
    description: "Timezone of the local site"
    type: number
    sql: ${TABLE}.site_timezone ;;
  }

  dimension: correlation_id {
    description: "ID relating a call together"
    type: string
    sql: ${TABLE}.correlation_id ;;
  }

  dimension: rolled_to_cs_call {
    description: "Correlation ID when call rolled from 2300 to Customer Support number, else NULL"
    type: string
    sql: ${TABLE}.rolled_to_cs_call ;;
  }

  dimension: rolled_to_queue_call {
    description: "Correlation ID when call rolled to 2300, else NULL"
    type: string
    sql: ${TABLE}.calls_rolled_to_queue ;;
  }

# MEASURES

  measure: call_volume {
    description: "Number of total calls - regardless of rollover"
    type: count_distinct
    sql: ${TABLE}.correlation_id ;;
  }

  measure: call_volume_business_hours {
    description: "Distinct calls with start_time between 7 AM and 5 PM"
    type: count_distinct
    sql:
    CASE
      WHEN EXTRACT(HOUR FROM TO_TIMESTAMP_NTZ(${start_time})) BETWEEN 7 AND 16
      THEN ${TABLE}.correlation_id
    END ;;
  }

  measure: calls_rolled_to_queue {
    description: "Number of total calls rolled to general queue number"
    type: count_distinct
    label: "Unique Calls Rolled to General Queue"
    sql: ${TABLE}.calls_rolled_to_queue ;;
  }

  measure: calls_rolled_to_queue_all {
    description: "Row-level count of calls rolled to general queue number"
    type: count
    label: "Calls Rolled to General Queue"
    filters: [rolled_to_queue_call: "-NULL", dialed_digits: "2300"]
  }

  measure: calls_rolled_to_cs {
    description: "Number of total calls rolled to CS from general queue number"
    type: count_distinct
    label: "Unique Calls Rolled to CS"
    sql: ${TABLE}.rolled_to_cs_call ;;
  }

  measure: calls_rolled_to_cs_all {
    description: "Row-level count of calls rolled to CS from general queue number"
    type: count
    label: "Calls Rolled to CS"
    filters: [rolled_to_cs_call: "-NULL"]  # only rows where rolled_to_cs_call is NOT NULL
  }


  measure: calls_rolled_to_cs_percentage {
    description: "Percentage of total calls transferred to queue"
    sql: ${calls_rolled_to_cs_all} / nullif(${call_volume},0) ;;
    value_format_name: percent_2
  }

  measure: calls_rolled_to_queue_percentage {
    description: "Percentage of total calls transferred to queue"
    sql: ${calls_rolled_to_queue_all} / nullif(${call_volume},0) ;;
    value_format_name: percent_2
  }

  measure: answered_rollover {
    description: "Number of total calls rolled to Customer Support number that were answered"
    type: count_distinct
    sql: ${TABLE}.correlation_id ;;
    filters: [redirecting_number: "2300", called_number: "+18336541665", answered: "Answered"]
  }

  measure: missed_rollover {
    description: "Number of total calls rolled to Customer Support number that were NOT answered"
    type: count_distinct
    sql: ${TABLE}.correlation_id ;;
    filters: [redirecting_number: "2300", called_number: "+18336541665", answered: "Missed"]
  }

  measure: transfer_answer_ratio {
    description: "Number of total calls answered vs not answered as a %"
    label: "Transfer Answer %"
    sql: (${answered_rollover}-${missed_rollover}) / nullif(${answered_rollover},0) ;;
    value_format_name: percent_2
  }

  measure: abandoned_calls {
    description: "Number of total calls rolled from that were abandoned (only Contact Center side)"
    type: count_distinct
    sql: ${TABLE}.abandoned_calls ;;
  }

  ############################################
  # Queue Time Measures
  ############################################

  measure: avg_queue_time_seconds {
    description: "Average amount of time that was spent from the start of the call to the answer in seconds"
    type: average
    sql: ${TABLE}.queue_time_seconds ;;
  }

  measure: max_queue_time_seconds {
    description: "Max amount of time that was spent from the start of the call to the answer in seconds"
    type: max
    sql: ${TABLE}.queue_time_seconds ;;
  }

  measure: avg_queue_time_hours {
    description: "Average amount of time that was spent from the start of the call to the answer in hours"
    type: average
    sql: ${TABLE}.queue_time_seconds / 3600 ;;
    html: {{ avg_queue_time_fmt._rendered_value }} ;;
  }

  measure: avg_queue_time_fmt {
    description: "Average queue time formatted as Hh Mm Ss (seconds rounded to 0 decimals)"
    type: string
    hidden: yes
    sql:
      CONCAT(
        FLOOR(AVG(${TABLE}.queue_time_seconds) / 3600), 'h ',
        FLOOR(MOD(AVG(${TABLE}.queue_time_seconds), 3600) / 60), 'm ',
        ROUND(MOD(AVG(${TABLE}.queue_time_seconds), 60), 0), 's'
      ) ;;
  }

  measure: max_queue_time_hours {
    description: "Max amount of time that was spent from the start of the call to the answer in hours"
    type: max
    sql: ${TABLE}.queue_time_seconds / 3600 ;;
    html: {{ max_queue_time_fmt._rendered_value }} ;;
  }

  measure: max_queue_time_fmt {
    description: "Max queue time formatted as Hh Mm Ss (seconds rounded to 0 decimals)"
    type: string
    hidden: yes
    sql:
      CONCAT(
        FLOOR(MAX(${TABLE}.queue_time_seconds) / 3600), 'h ',
        FLOOR(MOD(MAX(${TABLE}.queue_time_seconds), 3600) / 60), 'm ',
        ROUND(MOD(MAX(${TABLE}.queue_time_seconds), 60), 0), 's'
      ) ;;
  }

  ############################################
  # Talk Time Measures
  ############################################

  measure: avg_talk_time_seconds {
    description: "Average amount of time that was spent from the answer of the call to the release"
    type: average
    sql: ${TABLE}.talk_time_seconds ;;
  }

  measure: max_talk_time_seconds {
    description: "Max amount of time that was spent from the answer of the call to the release"
    type: max
    sql: ${TABLE}.talk_time_seconds ;;
  }

  measure: avg_talk_time_hours {
    description: "Average amount of time that was spent from the answer of the call to the release in hours"
    type: average
    sql: ${TABLE}.talk_time_seconds / 3600 ;;
    html: {{ avg_talk_time_fmt._rendered_value }} ;;
  }

  measure: avg_talk_time_fmt {
    description: "Average talk time formatted as Hh Mm Ss (seconds rounded to 0 decimals)"
    type: string
    hidden: yes
    sql:
      CONCAT(
        FLOOR(AVG(${TABLE}.talk_time_seconds) / 3600), 'h ',
        FLOOR(MOD(AVG(${TABLE}.talk_time_seconds), 3600) / 60), 'm ',
        ROUND(MOD(AVG(${TABLE}.talk_time_seconds), 60), 0), 's'
      ) ;;
  }

  measure: max_talk_time_hours {
    description: "Max amount of time that was spent from the answer of the call to the release in hours"
    type: max
    sql: ${TABLE}.talk_time_seconds / 3600 ;;
    html: {{ max_talk_time_fmt._rendered_value }} ;;
  }

  measure: max_talk_time_fmt {
    description: "Max talk time formatted as Hh Mm Ss (seconds rounded to 0 decimals)"
    type: string
    hidden: yes
    sql:
      CONCAT(
        FLOOR(MAX(${TABLE}.talk_time_seconds) / 3600), 'h ',
        FLOOR(MOD(MAX(${TABLE}.talk_time_seconds), 3600) / 60), 'm ',
        ROUND(MOD(MAX(${TABLE}.talk_time_seconds), 60), 0), 's'
      ) ;;
  }

}
