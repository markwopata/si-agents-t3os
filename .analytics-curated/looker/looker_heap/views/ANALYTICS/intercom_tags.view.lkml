
view: intercom_tags {
  derived_table: {
    sql: select
              conversation_id
          ,   created_at
          ,   company_id
          ,   user_id
          ,   employee_id
          ,   conv_sentiment
          ,   sentiment_bucket
          ,   original_tag
          ,   high_level_tag
          ,   detailed_tag
      from analytics.t3_analytics.intercom_conversations ;;
  }

  dimension: conversation_link {
    label: "Link to Conversation"
    type: string
    sql: ${TABLE}."CONVERSATION_ID";;
    html: <font color="#0063f3"><u><a href="https://app.intercom.com/a/inbox/cc3wvy5y/inbox/search/conversation/{{ conversation_id._filterable_value }}?filters=&query={{ conversation_id._filterable_value }}&view=List" target="_blank">Click For Conversation</a></font></u>;;
  }


  dimension: conversation_id {
    type: string
    sql: ${TABLE}."CONVERSATION_ID" ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: conv_sentiment {
    type: number
    sql: ${TABLE}."CONV_SENTIMENT" ;;
  }

  dimension: sentiment_bucket {
    type: string
    sql: ${TABLE}."SENTIMENT_BUCKET" ;;
  }

  dimension: high_level_tag {
    type: string
    sql: ${TABLE}."HIGH_LEVEL_TAG" ;;
  }

  dimension: detailed_tag {
    type: string
    sql: ${TABLE}."DETAILED_TAG" ;;
  }

  dimension: original_tag {
    type: string
    sql: ${TABLE}."ORIGINAL_TAG" ;;
  }

  set: detail {
    fields: [
      conversation_id,
      created_at_time,
      company_id,
      user_id,
      employee_id,
      conv_sentiment,
      sentiment_bucket,
      high_level_tag,
      detailed_tag
    ]
  }
}
