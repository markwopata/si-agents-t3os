connection: "es_snowflake_analytics"

include: "/views/intercom_conversation_summary/intercom_conversations.view.lkml"
include: "/views/intercom_conversation_summary/intercom_conversation_sentiment.view.lkml"

explore: intercom_conversation_sentiment {
  case_sensitive: no
  sql_always_where: ${intercom_conversation_sentiment.overall_sentiment} is not null ;;

}
