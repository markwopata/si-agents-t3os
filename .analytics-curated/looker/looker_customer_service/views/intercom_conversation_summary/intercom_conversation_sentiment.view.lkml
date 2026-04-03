view: intercom_conversation_sentiment {
  sql_table_name: "ANALYTICS"."INTERCOM"."INTERCOM_CONVERSATION_SENTIMENT" ;;

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: conv_body {
    type: string
    sql: ${TABLE}."CONV_BODY" ;;
  }
  dimension: conv_es_admin {
    type: string
    sql: ${TABLE}."CONV_ES_ADMIN" ;;
  }
  dimension: conv_source_domain {
    type: string
    sql: ${TABLE}."CONV_SOURCE_DOMAIN" ;;
  }
  dimension_group: conversation_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CONVERSATION_CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: conversation_id {
    type: string
    sql: ${TABLE}."CONVERSATION_ID" ;;
  }
  dimension_group: conversation_last_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CONVERSATION_LAST_UPDATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: conversation_tag {
    type: string
    sql: ${TABLE}."CONVERSATION_TAG" ;;
  }
  dimension: cortex_ai_sentiment {
    type: string
    sql: ${TABLE}."CORTEX_AI_SENTIMENT" ;;
  }
  dimension: ending_sentiment {
    type: string
    sql: ${TABLE}."ENDING_SENTIMENT" ;;
  }
  dimension: gpt_model {
    type: string
    sql: ${TABLE}."GPT_MODEL" ;;
  }
  dimension: initial_sentiment {
    type: string
    sql: ${TABLE}."INITIAL_SENTIMENT" ;;
  }
  dimension: interaction_sentiment {
    type: string
    sql: ${TABLE}."INTERACTION_SENTIMENT" ;;
  }
  dimension: issue_sentiment {
    type: string
    sql: ${TABLE}."ISSUE_SENTIMENT" ;;
  }
  dimension: overall_sentiment {
    type: string
    sql: ${TABLE}."OVERALL_SENTIMENT" ;;
  }
  dimension_group: pipeline_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."PIPELINE_COMPLETED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: pipeline_status {
    type: string
    sql: ${TABLE}."PIPELINE_STATUS" ;;
  }
  dimension: prompt_version {
    type: string
    sql: ${TABLE}."PROMPT_VERSION" ;;
  }
  dimension: resolved {
    type: string
    sql: ${TABLE}."RESOLVED" ;;
  }
  dimension_group: table_last_update {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TABLE_LAST_UPDATE" ;;
  }
  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }
  dimension: resolved_resolution {
    type: string
    sql: case when ${resolved} = 'Resolved' THEN ${conversation_id} else null end ;;
  }
  dimension: uncertain_resolution {
    type: string
    sql: case when ${resolved} = 'Uncertain' THEN ${conversation_id} else null end ;;
  }
  dimension: abandoned_resolution {
    type: string
    sql: case when ${resolved} = 'Abandoned' THEN ${conversation_id} else null end ;;
  }
  dimension: escalated_resolution {
    type: string
    sql: case when ${resolved} = 'Escalated' THEN ${conversation_id} else null end ;;
  }
  dimension: overall_positive_sentiment {
    type: string
    sql: case when ${overall_sentiment} = 'Positive' THEN ${conversation_id} else null end ;;
  }
  dimension: overall_mixed_sentiment {
    type: string
    sql: case when ${overall_sentiment} = 'Mixed' THEN ${conversation_id} else null end ;;
  }
  dimension: overall_neutral_sentiment {
    type: string
    sql: case when ${overall_sentiment} = 'Neutral' THEN ${conversation_id} else null end ;;
  }
  dimension: overall_negative_sentiment {
    type: string
    sql: case when ${overall_sentiment} = 'Negative' THEN ${conversation_id} else null end ;;
  }
  dimension: issue_positive_sentiment {
    type: string
    sql: case when ${issue_sentiment} = 'Positive' THEN ${conversation_id} else null end ;;
  }
  dimension: issue_mixed_sentiment {
    type: string
    sql: case when ${issue_sentiment} = 'Mixed' THEN ${conversation_id} else null end ;;
  }
  dimension: issue_neutral_sentiment {
    type: string
    sql: case when ${issue_sentiment} = 'Neutral' THEN ${conversation_id} else null end ;;
  }
  dimension: issue_negative_sentiment {
    type: string
    sql: case when ${issue_sentiment} = 'Negative' THEN ${conversation_id} else null end ;;
  }
  dimension: interaction_positive_sentiment {
    type: string
    sql: case when ${interaction_sentiment} = 'Positive' THEN ${conversation_id} else null end ;;
  }
  dimension: interaction_mixed_sentiment {
    type: string
    sql: case when ${interaction_sentiment} = 'Mixed' THEN ${conversation_id} else null end ;;
  }
  dimension: interaction_neutral_sentiment {
    type: string
    sql: case when ${interaction_sentiment} = 'Neutral' THEN ${conversation_id} else null end ;;
  }
  dimension: interaction_negative_sentiment {
    type: string
    sql: case when ${interaction_sentiment} = 'Negative' THEN ${conversation_id} else null end ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }
  measure: resolved_count {
    group_label: "Count"
    type: count_distinct
    sql: ${resolved_resolution};;
    drill_fields: [detail*]
  }
  measure: uncertain_count {
    group_label: "Count"
    type: count_distinct
    sql: ${uncertain_resolution};;
    drill_fields: [detail*]
  }
  measure: abandoned_count {
    group_label: "Count"
    type: count_distinct
    sql: ${abandoned_resolution};;
    drill_fields: [detail*]
  }
  measure: escalated_count {
    group_label: "Count"
    type: count_distinct
    sql: ${escalated_resolution};;
    drill_fields: [detail*]
  }
  measure: overall_positive_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${overall_positive_sentiment};;
    drill_fields: [detail*]
  }
  measure: overall_mixed_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${overall_mixed_sentiment};;
    drill_fields: [detail*]
  }
  measure: overall_neutral_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${overall_neutral_sentiment};;
    drill_fields: [detail*]
  }
  measure: overall_negative_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${overall_mixed_sentiment};;
    drill_fields: [detail*]
  }
  measure: issue_positive_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${issue_positive_sentiment};;
    drill_fields: [detail*]
  }
  measure: issue_mixed_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${issue_mixed_sentiment};;
    drill_fields: [detail*]
  }
  measure: issue_neutral_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${issue_neutral_sentiment};;
    drill_fields: [detail*]
  }
  measure: issue_negative_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${issue_mixed_sentiment};;
    drill_fields: [detail*]
  }
  measure: interaction_positive_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${interaction_positive_sentiment};;
    drill_fields: [detail*]
  }
  measure: interaction_mixed_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${interaction_mixed_sentiment};;
    drill_fields: [detail*]
  }
  measure: interaction_neutral_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${interaction_neutral_sentiment};;
    drill_fields: [detail*]
  }
  measure: interaction_negative_sentiment_count {
    group_label: "Count"
    type: count_distinct
    sql: ${interaction_mixed_sentiment};;
    drill_fields: [detail*]
  }
  measure: resolved_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${resolved_count}/${count};;
    drill_fields: [detail*]
  }
  measure: uncertain_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${uncertain_count}/${count};;
    drill_fields: [detail*]
  }
  measure: abandoned_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${abandoned_count}/${count};;
    drill_fields: [detail*]
  }
  measure: escalated_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${escalated_count}/${count};;
    drill_fields: [detail*]
  }
  measure: overall_positive_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${overall_positive_sentiment_count}/${count};;
    drill_fields: [detail*]
  }
  measure: overall_mixed_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${overall_mixed_sentiment_count}/${count};;
    drill_fields: [detail*]
  }
  measure: overall_neutral_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${overall_neutral_sentiment_count}/${count};;
    drill_fields: [detail*]
  }
  measure: overall_negative_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${overall_negative_sentiment_count}/${count};;
    drill_fields: [detail*]
  }
  measure: issue_positive_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${issue_positive_sentiment_count}/${count};;
    drill_fields: [detail*]
  }
  measure: issue_mixed_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${issue_mixed_sentiment_count}/${count};;
    drill_fields: [detail*]
  }
  measure: issue_neutral_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${issue_neutral_sentiment_count}/${count};;
    drill_fields: [detail*]
  }
  measure: issue_negative_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${issue_negative_sentiment_count}/${count};;
    drill_fields: [detail*]
  }
  measure: interaction_positive_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${interaction_positive_sentiment_count}/ (${interaction_positive_sentiment_count} +
        ${interaction_neutral_sentiment_count} +
        ${interaction_mixed_sentiment_count} +
        ${interaction_negative_sentiment_count});;
    drill_fields: [detail*]
  }
  measure: interaction_mixed_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${interaction_mixed_sentiment_count}/ (${interaction_positive_sentiment_count} +
        ${interaction_neutral_sentiment_count} +
        ${interaction_mixed_sentiment_count} +
        ${interaction_negative_sentiment_count});;
    drill_fields: [detail*]
  }
  measure: interaction_neutral_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${interaction_neutral_sentiment_count}/ (${interaction_positive_sentiment_count} +
        ${interaction_neutral_sentiment_count} +
        ${interaction_mixed_sentiment_count} +
        ${interaction_negative_sentiment_count});;
    drill_fields: [detail*]
  }
  measure: interaction_negative_percent {
    group_label: "Percent"
    type: number
    value_format: "0.0%"
    sql: ${interaction_negative_sentiment_count}/ (${interaction_positive_sentiment_count} +
        ${interaction_neutral_sentiment_count} +
        ${interaction_mixed_sentiment_count} +
        ${interaction_negative_sentiment_count});;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      conversation_created_date,
      conversation_id,
      conv_es_admin,
      conversation_tag,
      conv_body,
      overall_sentiment,
      interaction_sentiment,
      issue_sentiment,
      resolved
    ]
  }
}
