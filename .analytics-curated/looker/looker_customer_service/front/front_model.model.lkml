connection: "es_snowflake_analytics"

include: "/front/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: front_cx_conversation {
  group_label: "Customer Service"
  case_sensitive: no
  label: "Front"

   join: front_cx_message {
     relationship: one_to_many
     sql_on: ${front_cx_conversation.conversation_id} = ${front_cx_message.conversation_id} ;;
   }

   join: v_cx_conversations_with_emails {
    relationship: one_to_many
    sql_on: ${front_cx_conversation.conversation_id} = ${v_cx_conversations_with_emails.conversation_id}
    and ${front_cx_conversation.teammate_id} = ${v_cx_conversations_with_emails.teammate_id};;
   }

}
