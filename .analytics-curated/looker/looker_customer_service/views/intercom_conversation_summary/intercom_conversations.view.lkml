view: intercom_conversations {
  derived_table: {
    sql:
    select
        iic.conversation_id
        , iic.time
        , iic.type
        , iic.library
        , iic.platform
        , iic.device_type
        , iic.region
        , iic.city
        , iic.referrer
        , iic.assigned_admin_email
        , cl.assigned_admin_email as filled_agent_email
        , adm.nickname as agent_name
        , iic.first_message_delivered_as
        , iic.first_message_type
        , iic.first_message_author_type
        , iic.num_conversation_parts
        , iic.conversation_rating
        , iic.url
        , ic.company_id
        , ic.user_id
        , u.timezone
        , u.email_address
        , concat(u.first_name, ' ', u.last_name) as full_name
        , ic.employee_id
        , cd.work_email
        , cd.nickname
        , cd.employee_title
        , cd.location
        , ic.original_tag
        , ic.high_level_tag
        , ic.detailed_tag
        , ic.conv_body
      from HEAP_T3_PLATFORM_PRODUCTION.HEAP.T3_ANALYTICS_INTERCOM_INTERACTION_CONVERSATION iic
      inner join analytics.t3_analytics.intercom_conversations ic
        on iic.conversation_id = ic.conversation_id
      left join es_warehouse.public.users u
        on u.user_id = ic.user_id
      left join analytics.payroll.company_directory cd
        on cd.work_email = u.email_address
      left join
        (select assigned_admin_email, conversation_id
            from HEAP_T3_PLATFORM_PRODUCTION.HEAP.T3_ANALYTICS_INTERCOM_INTERACTION_CONVERSATION
            where type = 'Conversation was Closed') cl
                on cl.conversation_id = iic.conversation_id
      left join analytics.payroll.company_directory adm
        on cl.assigned_admin_email = adm.work_email
        ;;
  }

  dimension: conversation_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.conversation_id ;;
  }

  dimension_group: conversation_time {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.time ;;
  }

  dimension: interaction_type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: library {
    type: string
    sql: ${TABLE}.library ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: device_type {
    type: string
    sql: ${TABLE}.device_type ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: referrer {
    type: string
    sql: ${TABLE}.referrer ;;
  }

  dimension: assigned_admin_email {
    type: string
    sql: ${TABLE}.assigned_admin_email ;;
  }

  dimension: agent_name {
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: first_message_delivered_as {
    type: string
    sql: ${TABLE}.first_message_delivered_as ;;
  }

  dimension: first_message_type {
    type: string
    sql: ${TABLE}.first_message_type ;;
  }

  dimension: first_message_author_type {
    type: string
    sql: ${TABLE}.first_message_author_type ;;
  }

  dimension: num_conversation_parts {
    type: number
    sql: ${TABLE}.num_conversation_parts ;;
  }

  dimension: conversation_rating {
    type: number
    sql: ${TABLE}.conversation_rating ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}.url ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: user_timezone {
    type: string
    sql: ${TABLE}.timezone ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}.email_address ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.full_name ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.employee_id ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}.work_email ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}.nickname ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}.employee_title ;;
  }

  dimension: employee_location {
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: original_tag {
    type: string
    sql: ${TABLE}.original_tag ;;
  }

  dimension: high_level_tag {
    type: string
    sql: ${TABLE}.high_level_tag ;;
  }

  dimension: detailed_tag {
    type: string
    sql: ${TABLE}.detailed_tag ;;
  }

  dimension: conv_body {
    type: string
    sql: ${TABLE}.conv_body ;;
  }

  dimension: tod_bucket {
    type: string
    sql:
    CASE
      WHEN ${conversation_time_time} IS NULL THEN NULL
      WHEN DATE_PART('HOUR', ${conversation_time_raw}) < 12 THEN 'Morning'
      WHEN DATE_PART('HOUR', ${conversation_time_raw}) < 17 THEN 'Afternoon'
      ELSE 'Evening'
    END ;;
  }

  dimension: rating_1_conv_id {
    type: string
    sql: case when ${conversation_rating} = 1 THEN ${conversation_id} else null end ;;
  }

  dimension: rating_2_conv_id {
    type: string
    sql: case when ${conversation_rating} = 2 THEN ${conversation_id} else null end ;;
  }

  dimension: rating_3_conv_id {
    type: string
    sql: case when ${conversation_rating} = 3 THEN ${conversation_id} else null end ;;
  }

  dimension: rating_4_conv_id {
    type: string
    sql: case when ${conversation_rating} = 4 THEN ${conversation_id} else null end ;;
  }

  dimension: rating_5_conv_id {
    type: string
    sql: case when ${conversation_rating} = 5 THEN ${conversation_id} else null end ;;
  }

  measure: conv_count {
    type: count_distinct
    sql: ${conversation_id} ;;
    drill_fields: [detail*]
  }

  measure: rated_conversation_count {
    type: count_distinct
    sql: case when ${conversation_rating} is not null then ${conversation_id} else null end ;;
  }

  measure: unrated_conversation_count {
    type: count_distinct
    sql: ${conversation_id} ;;
    filters: [conversation_rating: "NULL"]
  }

  measure: percent_rated {
    type: number
    sql: (${rated_conversation_count}/${conv_count}) ;;
    value_format: "0.0%"
  }

  measure: percent_rated_employees {
    type: number
    value_format: "0.0%"
    sql:
    CASE
      WHEN COUNT(DISTINCT CASE WHEN ${employee_title} IS NOT NULL THEN ${conversation_id} END) = 0 THEN NULL
      ELSE
        COUNT(DISTINCT CASE WHEN ${employee_title} IS NOT NULL AND ${conversation_rating} IS NOT NULL THEN ${conversation_id} END)
        / COUNT(DISTINCT CASE WHEN ${employee_title} IS NOT NULL THEN ${conversation_id} END)
    END ;;
  }

  measure: percent_rated_customers {
    type: number
    value_format: "0.0%"
    sql:
    CASE
      WHEN COUNT(DISTINCT CASE WHEN ${employee_title} IS NULL THEN ${conversation_id} END) = 0 THEN NULL
      ELSE
        COUNT(DISTINCT CASE WHEN ${employee_title} IS NULL AND ${conversation_rating} IS NOT NULL THEN ${conversation_id} END)
        / COUNT(DISTINCT CASE WHEN ${employee_title} IS NULL THEN ${conversation_id} END)
    END ;;
  }

  measure: average_ratings {
    type: average
    sql: ${conversation_rating};;
    value_format: "0.00"
    drill_fields: [detail*]
  }

  measure: customer_count {
    type: count_distinct
    sql: ${conversation_id} ;;
    filters: [employee_title: "NULL"]
    drill_fields: [detail*]
  }

  measure: rating_1_count {
    type: count_distinct
    sql: ${rating_1_conv_id};;
    drill_fields: [detail*]
  }

  measure: rating_2_count {
    type: count_distinct
    sql: ${rating_2_conv_id};;
    drill_fields: [detail*]
  }

  measure: rating_3_count {
    type: count_distinct
    sql: ${rating_3_conv_id};;
    drill_fields: [detail*]
  }

  measure: rating_4_count {
    type: count_distinct
    sql: ${rating_4_conv_id};;
    drill_fields: [detail*]
  }

  measure: rating_5_count {
    type: count_distinct
    sql: ${rating_5_conv_id};;
    drill_fields: [detail*]
  }

  measure: percent_rated_1 {
    type: number
    value_format: "0.0%"
    sql: ${rating_1_count}/${rated_conversation_count};;
  }

  measure: percent_rated_2 {
    type: number
    value_format: "0.0%"
    sql: ${rating_2_count}/${rated_conversation_count};;
  }

  measure: percent_rated_3 {
    type: number
    value_format: "0.0%"
    sql: ${rating_3_count}/${rated_conversation_count};;
  }

  measure: percent_rated_4 {
    type: number
    value_format: "0.0%"
    sql: ${rating_4_count}/${rated_conversation_count};;
  }

  measure: percent_rated_5 {
    type: number
    value_format: "0.0%"
    sql: ${rating_5_count}/${rated_conversation_count};;
  }

  set: detail {
   fields: [
    conversation_time_date,
    conversation_id,
    high_level_tag,
    user_email,
    agent_name,
    conversation_rating,
    conv_body
    ]
  }

}
