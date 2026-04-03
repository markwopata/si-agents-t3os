connection: "es_snowflake_analytics"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/dbt_views/*.view.lkml"
include: "/webex/*.view.lkml"
include: "/intercom/*.view.lkml"
include: "/front/*.view.lkml"

explore: date_spine {
  label: "Customer Service Performance Dashboards"

  join: webex_contact_center_calls {
    relationship: one_to_many
    sql_on: ${date_spine.dt_date} = COALESCE(TRY_TO_TIMESTAMP_TZ(${webex_contact_center_calls.created_at_date}),
    TRY_TO_TIMESTAMP_NTZ(${webex_contact_center_calls.created_at_date}) )::DATE
    ;;
    }

  join: intercom_tag_history {
    relationship: one_to_many
    sql_on: ${date_spine.dt_date} = COALESCE( TRY_TO_TIMESTAMP_TZ(${intercom_tag_history.created_at_date}),
    TRY_TO_TIMESTAMP_NTZ(${intercom_tag_history.created_at_date}) )::DATE
    ;;
    }

  join: front_cx_message {
    relationship: one_to_many
    sql_on: ${date_spine.dt_date} = ${front_cx_message.created_date} ;;
  }

  join: front_cx_conversation {
    relationship: many_to_one
    sql_on: ${front_cx_message.conversation_id} = ${front_cx_conversation.conversation_id} ;;
  }

  join: front_customer_support {
    relationship: one_to_many
    sql_on: ${front_cx_message.conversation_id} = ${front_customer_support.conversation_id}
    and ${front_cx_message.message_id} = ${front_customer_support.message_id} ;;
  }

  join: v_cx_conversations_with_emails {
    relationship: one_to_many
    sql_on: ${front_cx_conversation.conversation_id} = ${v_cx_conversations_with_emails.conversation_id}
      and ${front_cx_conversation.teammate_id} = ${v_cx_conversations_with_emails.teammate_id};;
  }

  }
