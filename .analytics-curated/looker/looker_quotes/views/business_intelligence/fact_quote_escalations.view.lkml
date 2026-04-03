view: fact_quote_escalations {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_FACT_QUOTE_ESCALATIONS" ;;

  dimension_group: _created_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  dimension: escalated_by_user_key {
    type: string
    sql: ${TABLE}."ESCALATED_BY_USER_KEY" ;;
    hidden: yes
  }

  dimension: quote_created_date_key {
    type: string
    sql: ${TABLE}."QUOTE_CREATED_DATE_KEY" ;;
    hidden: yes
  }

  dimension: quote_customer_key {
    type: string
    sql: ${TABLE}."QUOTE_CUSTOMER_KEY" ;;
    hidden: yes
  }

  dimension: quote_escalated_date_key {
    type: string
    sql: ${TABLE}."QUOTE_ESCALATED_DATE_KEY" ;;
    hidden: yes
  }

  dimension: quote_escalation_id {
    type: string
    sql: ${TABLE}."QUOTE_ESCALATION_ID" ;;
    hidden: yes
  }

  dimension: quote_escalation_key {
    type: string
    sql: ${TABLE}."QUOTE_ESCALATION_KEY" ;;
    hidden: yes
  }

  dimension: quote_key {
    type: string
    sql: ${TABLE}."QUOTE_KEY" ;;
    hidden: yes
  }

  dimension: attachment_filepath {
    type: string
    sql: ${TABLE}."ATTACHMENT_FILEPATH" ;;
  }

  dimension: escalation_reason {
    type: string
    sql: ${TABLE}."ESCALATION_REASON" ;;
  }

  dimension: has_attachment {
    type: yesno
    sql: ${TABLE}."HAS_ATTACHMENT" ;;
  }

  dimension: num_days_to_escalation {
    type: number
    sql: ${TABLE}."NUM_DAYS_TO_ESCALATION" ;;
  }

  filter: user_date_range {
    type: date
    description: "User-selected date range for current vs previous comparison"
  }

  dimension: timeframe {
    type: string
    sql:
      CASE
        WHEN ${quote_escalated_date.date_raw} >= {% date_start user_date_range %}
         AND ${quote_escalated_date.date_raw} <= {% date_end user_date_range %}
          THEN 'Current'
        WHEN ${quote_escalated_date.date_raw} >=
        dateadd(
        day,
        -datediff(
        day,
        {% date_start user_date_range %},
        {% date_end user_date_range %}
        ),
        {% date_start user_date_range %}
        )
        AND ${quote_escalated_date.date_raw} < {% date_start user_date_range %}
        THEN 'Previous'
        END
        ;;
  }


  measure: total_count_of_previous_quotes {
    type: count_distinct
    sql: ${quote_key} ;;
    filters: [timeframe: "Previous", quote_key: "-NULL"]
    # drill_fields: [quote_info*]
  }

  measure: total_count_of_current_quotes {
    type: count_distinct
    sql: ${quote_key} ;;
    filters: [timeframe: "Current", quote_key: "-NULL"]
    html:
    <a href="#drillmenu" style = "color:#000000;" target="_self">
    {{ rendered_value }} {% if difference_in_quotes._value > 0 %}

      {% assign indicator = "green,▲" | split: ',' %}

      {% elsif difference_in_quotes._value < 0 %}

      {% assign indicator = "red,▼" | split: ',' %}

      {% else %}

      {% endif %}

      <font color="{{indicator[0]}}">

      {% if value == 99999.12345 %} &infin

      {% else %}({{ difference_in_quotes._rendered_value }})

      {% endif %} {{indicator[1]}}

      </font>
      </a>;;
    # drill_fields: [quote_info*]
  }

  measure: difference_in_quotes {
    type: number
    sql: ${total_count_of_current_quotes} - ${total_count_of_previous_quotes} ;;
  }

  measure: count {
    type: count
  }
}
