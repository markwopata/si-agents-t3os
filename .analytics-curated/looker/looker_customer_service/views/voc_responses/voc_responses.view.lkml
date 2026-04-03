
view: voc_responses {
  derived_table: {
    sql: select
      _row,
      can_you_provide_a_summary_of_the_voc_what_do_they_like_or_hate_what_they_re_trying_to_accomplish_you_get_the_idea_,
      do_you_have_any_ideas_about_how_to_make_things_better_explain_and_or_tell_us_how_to_contact_you_to_hear_them_,
      where_did_you_talk_and_what_was_it_choose_best_option_phone_,
      where_did_you_talk_and_what_was_it_choose_best_option_chat_,
      coalesce(coalesce(where_did_you_talk_and_what_was_it_choose_best_option_phone_ , where_did_you_talk_and_what_was_it_choose_best_option_chat_),
      where_did_you_talk_and_what_was_it_choose_best_option_email_)
      as where_did_you_talk_concat,
      timestamp::datetime as created_timestamp,
      if_reported_on_behalf_of_someone_please_provide_what_you_know_unless_user_requests_to_be_anonymous_,
      add_any_valuable_notes_from_the_convo_or_copy_paste_them_from_es_admin_,
      where_did_you_talk_and_what_was_it_choose_best_option_email_,
      what_was_the_feedback_about_i_e_t_3_fleet_geofences_billing_trackers_etc_,
      did_any_of_these_happen_in_the_interaction_,
      interaction_id_front_intercom_cx_one_id_or_url_link_to_the_original_conversation_,
      who_did_you_interact_with_company_include_id_name_and_phone_or_email_if_available_,
      team,
      email_address,
      _fivetran_synced,
      HIDE
      from
      ANALYTICS.VOC_SURVEY.VOC_SURVEY_GS
      where
      timestamp::datetime <= DATEADD(Day ,-2, current_date)
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: can_you_provide_a_summary_of_the_voc_what_do_they_like_or_hate_what_they_re_trying_to_accomplish_you_get_the_idea_ {
    label: "sentiment summary"
    type: string
    sql: ${TABLE}."CAN_YOU_PROVIDE_A_SUMMARY_OF_THE_VOC_WHAT_DO_THEY_LIKE_OR_HATE_WHAT_THEY_RE_TRYING_TO_ACCOMPLISH_YOU_GET_THE_IDEA_" ;;
  }

  dimension: do_you_have_any_ideas_about_how_to_make_things_better_explain_and_or_tell_us_how_to_contact_you_to_hear_them_ {
    type: string
    sql: ${TABLE}."DO_YOU_HAVE_ANY_IDEAS_ABOUT_HOW_TO_MAKE_THINGS_BETTER_EXPLAIN_AND_OR_TELL_US_HOW_TO_CONTACT_YOU_TO_HEAR_THEM_" ;;
  }

  dimension: where_did_you_talk_and_what_was_it_choose_best_option_phone_ {
    type: string
    sql: ${TABLE}."WHERE_DID_YOU_TALK_AND_WHAT_WAS_IT_CHOOSE_BEST_OPTION_PHONE_" ;;
  }

  dimension: where_did_you_talk_and_what_was_it_choose_best_option_chat_ {
    type: string
    sql: ${TABLE}."WHERE_DID_YOU_TALK_AND_WHAT_WAS_IT_CHOOSE_BEST_OPTION_CHAT_" ;;
  }

  dimension: convo_type {
    type: string
    sql: ${TABLE}."WHERE_DID_YOU_TALK_CONCAT" ;;
  }
  dimension_group: created_timestamp {
    type: time
    sql: ${TABLE}."CREATED_TIMESTAMP" ;;
  }

  dimension: if_reported_on_behalf_of_someone_please_provide_what_you_know_unless_user_requests_to_be_anonymous_ {
    type: string
    sql: ${TABLE}."IF_REPORTED_ON_BEHALF_OF_SOMEONE_PLEASE_PROVIDE_WHAT_YOU_KNOW_UNLESS_USER_REQUESTS_TO_BE_ANONYMOUS_" ;;
  }

  dimension: add_any_valuable_notes_from_the_convo_or_copy_paste_them_from_es_admin_ {
    type: string
    sql: ${TABLE}."ADD_ANY_VALUABLE_NOTES_FROM_THE_CONVO_OR_COPY_PASTE_THEM_FROM_ES_ADMIN_" ;;
  }

  dimension: where_did_you_talk_and_what_was_it_choose_best_option_email_ {
    type: string
    sql: ${TABLE}."WHERE_DID_YOU_TALK_AND_WHAT_WAS_IT_CHOOSE_BEST_OPTION_EMAIL_" ;;
  }

  dimension: what_was_the_feedback_about_i_e_t_3_fleet_geofences_billing_trackers_etc_ {
    type: string
    sql: ${TABLE}."WHAT_WAS_THE_FEEDBACK_ABOUT_I_E_T_3_FLEET_GEOFENCES_BILLING_TRACKERS_ETC_" ;;
  }

  dimension: did_any_of_these_happen_in_the_interaction_ {
    type: string
    sql: ${TABLE}."DID_ANY_OF_THESE_HAPPEN_IN_THE_INTERACTION_" ;;
  }

  dimension: interaction_id_front_intercom_cx_one_id_or_url_link_to_the_original_conversation_ {
    type: string
    sql: ${TABLE}."INTERACTION_ID_FRONT_INTERCOM_CX_ONE_ID_OR_URL_LINK_TO_THE_ORIGINAL_CONVERSATION_" ;;
  }

  dimension: who_did_you_interact_with_company_include_id_name_and_phone_or_email_if_available_ {
    type: string
    sql: ${TABLE}."WHO_DID_YOU_INTERACT_WITH_COMPANY_INCLUDE_ID_NAME_AND_PHONE_OR_EMAIL_IF_AVAILABLE_" ;;
  }

  dimension: team {
    type: string
    sql: ${TABLE}."TEAM" ;;
  }

  dimension: hide {
    type: string
    sql: ${TABLE}."HIDE" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }



  set: detail {
    fields: [
      _row,
      can_you_provide_a_summary_of_the_voc_what_do_they_like_or_hate_what_they_re_trying_to_accomplish_you_get_the_idea_,
      do_you_have_any_ideas_about_how_to_make_things_better_explain_and_or_tell_us_how_to_contact_you_to_hear_them_,
      where_did_you_talk_and_what_was_it_choose_best_option_phone_,
      where_did_you_talk_and_what_was_it_choose_best_option_chat_,
      created_timestamp_time,
      if_reported_on_behalf_of_someone_please_provide_what_you_know_unless_user_requests_to_be_anonymous_,
      add_any_valuable_notes_from_the_convo_or_copy_paste_them_from_es_admin_,
      where_did_you_talk_and_what_was_it_choose_best_option_email_,
      what_was_the_feedback_about_i_e_t_3_fleet_geofences_billing_trackers_etc_,
      did_any_of_these_happen_in_the_interaction_,
      interaction_id_front_intercom_cx_one_id_or_url_link_to_the_original_conversation_,
      who_did_you_interact_with_company_include_id_name_and_phone_or_email_if_available_,
      team,
      email_address,
      _fivetran_synced_time,
      hide,
      convo_type
    ]
  }
}
