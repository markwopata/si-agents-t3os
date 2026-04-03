view: safety_meeting_union {
  derived_table: {
    sql:
        SELECT *
        FROM analytics.bi_ops.safety_meeting_attendance
        WHERE ({% condition market_name_filter_mapping %} market_name {% endcondition %}
               and {% condition district_filter_mapping %} district {% endcondition %}
               and {% condition region_name_filter_mapping %} region_name {% endcondition %}
               and {% condition market_type_filter_mapping %} market_type {% endcondition %}
               and {% condition topic_type_filter_mapping %} topic_type {% endcondition %})
          AND (

        (
        'developer' = {{ _user_attributes['department'] }}
        OR 'god view' = {{ _user_attributes['department'] }}
        OR 'telematics' = {{ _user_attributes['department'] }}
        )

        OR
        (
          ('managers' = {{ _user_attributes['department'] }}
           OR 'service_mgr' = {{ _user_attributes['job_role'] }}
           OR 'safety' = {{ _user_attributes['department'] }}
           OR 'hrbp' = {{ _user_attributes['job_role'] }}
           OR 'yes' = {{ _user_attributes['safety_champion'] }}
          )
          AND
          (region_name in ({{_user_attributes['region']}})
           OR district in ({{_user_attributes['district']}})
           OR market_id in ({{_user_attributes['market_id']}})
          )
        )

        ----- This is for individual user access for the 'Individual Safety Meeting Dashboard', and is the default access level--"just see  my data". Note only employee titles specified in `DESC PROCEDURE analytics.bi_ops.update_safety_meeting_attendance_proc()`.

        OR
        (
        current_work_email ILIKE '{{ _user_attributes['email'] }}'
        )


        ----- This is for individual hard coded access. This is needed when someone who isn't a GM or Service Mgr ask for manager permission for the dashboard.
        ----- They will need added to the Safety Meeting subfolder of Limited Access as well.

        OR
        (
        '{{ _user_attributes['email'] }}' IN ('susan.lauretti@equipmentshare.com',
                                              'katie@equipmentshare.com',
                                              'wyatt.slavens@equipmentshare.com',
                                              'louie.johnson@equipmentshare.com',
                                              'halley.moore@equipmentshare.com',
                                              'rachele.burkett@equipmentshare.com',
                                              'matt.tanner@equipmentshare.com',
                                              'jeremy.brownmiller@equipmentshare.com',
                                              'anthony.young@equipmentshare.com',
                                              'morgan.panos@equipmentshare.com',
                                              'tom.hutchinson@equipmentshare.com',
                                              'tara.vossekuil@equipmentshare.com',
                                              'chris.sondergaard@equipmentshare.com',
                                              'sonia.parker@equipmentshare.com',
                                              'ben.paullus@equipmentshare.com',
                                              'clint.franklin@equipmentshare.com',
                                              'aryn.rodenbaugh@equipmentshare.com',
                                              'mashanda.blaise@equipmentshare.com',
                                              'petrice.mcgowen@equipmentshare.com',
                                              'jake.michaelis@equipmentshare.com',
                                              'zach.douthitt@equipmentshare.com',
                                              'kamden.nolte@equipmentshare.com',
                                              'erik.munoz@equipmentshare.com',
                                              'marques.baldwin@equipmentshare.com',
                                              'sean.farris@equipmentshare.com',
                                              'blake.comeaux@equipmentshare.com',
                                              'cody.brown@equipmentshare.com',
                                              'james.donnelly@equipmentshare.com',
                                              'brent.hutchison@equipmentshare.com',
                                              'amanda.curl@equipmentshare.com',
                                              'brian.shimko@equipmentshare.com',
                                              'lucas.lopez@equipmentshare.com',
                                              'sarah.woods@equipmentshare.com',
                                              'kate.turmo@equipmentshare.com',
                                              'mallory.mitchell@equipmentshare.com',
                                              'beth.stone@equipmentshare.com',
                                              'jay.guevara@equipmentshare.com',
                                              'victoria.hamilton@equipmentshare.com',
                                              'troy.johnson@equipmentshare.com',
                                              'brian.crisostomo@equipmentshare.com',
                                              'charlie.giesen@equipmentshare.com',
                                              'ramon.galaviz@equipmentshare.com'
                                              )

        AND
          (
            region_name in ({{_user_attributes['region']}})
            OR district in ({{_user_attributes['district']}})
            OR market_id in ({{_user_attributes['market_id']}})
          )
        )

        OR
        (
          'mariam.behashti@equipmentshare.com' = '{{ _user_attributes['email'] }}'
          AND
          (
            region_name in ({{_user_attributes['region']}})
            OR district in ({{_user_attributes['district']}})
            OR market_id in ('10550', '97880') --- Change this to be ({{_user_attributes['market_id']}}) once Mariam isn't managing the attendance for the Advanced branch anymore
          )
        )
                OR
        (
          'mark.reid@equipmentshare.com' = '{{ _user_attributes['email'] }}'
          AND
          (
            region_name in ({{_user_attributes['region']}})
            OR district in ({{_user_attributes['district']}})
            OR market_id in ('70872','73759','77336','77337','77338','77339','81933','81934',
                    '81935','81936','129486','141614','141682','142813','142815',
                    '150855','162558','166067','170834','170836','170837','170839') --- per help looker request from dnaielle baldwin
          )
        )
                OR
        (
          'brandon.c.wright@equipmentshare.com' = '{{ _user_attributes['email'] }}'
          AND
          (
            region_name in ({{_user_attributes['region']}})
            OR district in ({{_user_attributes['district']}})
            OR market_id in ('116676', '169657') --- per help looker request from danielle baldwin
          )
        )
      );;
  }


  ## For everything to work, the start dates MUST be correct on the weekly and monthly topic names Google Sheet. Here is the link to the
  # Sheet: https://docs.google.com/spreadsheets/d/1hGh680aUcGsc5m9hPbkmOJwggG9i7tKUaC-N0ACDakA/edit#gid=1964261246
  # Quick Guide: https://docs.google.com/document/d/1SR9kbWrPdEjfE3hzuUBLAOoLjDpD10tWDH4u-OrfG-w/edit?tab=t.0
  # Kyle Croucher and Michael Brown are the only ones with permission to edit those protected sheets


  # This view is used on two different dashboards. Safety Meeting Attendance and Individual Safety Meeting Attendance


  ## There are a few things happening within the joins and where clauses

  # First for an employee to be eligible in the weekly topics, the topic start date must be between the employees record effective date and the record ineffective date. This helps capture issues where employees have switched job titles. Please see the where clause in the final_employee_cd_mapping CTE for those employee examples.
  # For an employee to be eligible in the monthly topics, the topic month must be after the employees record effective date.

  # As for the other requirements; the topic submitted date must be within the year of the topics. Everything else is just filtering out different titles.

  measure: count {
    type: count
    drill_fields: [employee_info*]
  }

  dimension: employee_name {
    label: "Employee Name With ID"
    type: string
    #   suggest_persist_for: "1 minute"
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }

  dimension: employee_name_with_link {
    type: string
    #  suggest_persist_for: "1 minute"
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
    link: {
      label: "Link to Individual Employee Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/1158?Topic+Type={{ _filters['safety_meeting_union.topic_type'] | url_encode }}&Employee+Name={{ value }}"
    }
  }

  dimension: email_address {
    type: string
    primary_key: yes
    sql: ${TABLE}."CURRENT_WORK_EMAIL" ;;
  }

  dimension: manager_email {
    type: string
    sql: ${TABLE}."MANAGER_EMAIL" ;;
  }

  # dimension_group: hired {
  #   type: time
  #   sql: ${TABLE}."DATE_HIRED" ;;
  #   html: {{ rendered_value | date: "%b %d, %Y" }};;
  # }

  dimension_group: record_effective {
    label: "Position Effective"
    type: time
    sql: ${TABLE}."RECORD_EFFECTIVE_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: record_ineffective {
    type: time
    sql: ${TABLE}."RECORD_INEFFECTIVE_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  # dimension_group: rehired {
  #   type: time
  #   sql: ${TABLE}."DATE_REHIRED" ;;
  #   html: {{ rendered_value | date: "%b %d, %Y" }};;
  # }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: topic {
    type: string
    sql: ${TABLE}."ELIGIBLE_TOPIC_NAME" ;;
    order_by_field: topic_start_date
    suggest_persist_for: "1 minute"
  }

  dimension_group: topic_start {
    type: time
    sql: ${TABLE}."ELIGIBLE_TOPIC_START_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
    convert_tz: no
  }

  dimension: response_topic_attended {
    type: string
    sql: ${TABLE}."COMPLETED_TOPIC_NAME" ;;
  }

  dimension_group: topic_completed {
    type: time
    sql: ${TABLE}."DATE_SUBMITTED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
    convert_tz: no
  }

  dimension: attended_topic {
    type: string
    sql: case when ${TABLE}."ATTENDED_TOPIC" = 1 then 'Yes' else 'No' end ;;
  }

  dimension: topic_type_flag {
    type: string
    sql: ${TABLE}."TOPIC_TYPE_FLAG" ;;
  }

  dimension: topic_type {
    type: string
    sql: ${TABLE}."TOPIC_TYPE" ;;
  }

  dimension: current_eligible_topic_flag {
    type: string
    sql: ${TABLE}."CURRENT_ELIGIBLE_TOPIC_FLAG" ;;
  }

  dimension: topics_discussed {
    type: string
    sql: ${TABLE}."TOPICS_DISCUSSED" ;;
  }

  dimension: topics_discussed_manager {
    type: string
    sql: ${TABLE}."TOPICS_DISCUSSED_MANAGER" ;;
  }

  dimension: employee_type {
    type: string
    sql: ${TABLE}."EMPLOYEE_TYPE" ;;
  }

  dimension: future_topic_flag {
    type: string
    sql: case when ${topics_discussed} = 'Future Topic' then 1 else 0 end;;
  }

  dimension: attended_topic_formatted {
    type: string
    sql: case when ${TABLE}."CURRENT_ELIGIBLE_TOPIC_FLAG" = 1 and ${TABLE}."ATTENDED_TOPIC" = 0 then 'In Progress' else ${attended_topic} end ;;
    html:
    {% if value == "Yes" %}
    <p><img src="https://findicons.com/files/icons/573/must_have/48/check.png" alt="" height="13" width="13">‎ ‎ ‎ {{ rendered_value }}</p>
    {% elsif value == "No" %}
    <p><img src="https://findicons.com/files/icons/719/crystal_clear_actions/64/cancel.png" alt="" height="13" width="13">‎ ‎ ‎ {{ rendered_value }}</p>
    {% elsif value == "In Progress" %}
    <p><img src="https://findicons.com/files/icons/1681/siena/128/clock_blue.png" alt="" height="13" width="13">‎ ‎ ‎ {{ rendered_value }}</p>
    {% else %}
    {% endif %};;
  }

  measure: count_of_attended_employees {
    type: count_distinct
    sql: CASE WHEN ${attended_topic} = 'Yes' AND ${future_topic_flag} = '0' AND ${TABLE}."CURRENT_WORK_EMAIL" IS NOT NULL THEN ${TABLE}."CURRENT_WORK_EMAIL" END ;;
    drill_fields: [employee_info*]
    filters: [attended_topic: "Yes"]
  }

  measure: count_of_not_attended_employees {
    type: count_distinct
    sql: CASE WHEN ${attended_topic} = 'No' AND ${future_topic_flag} = '0' AND ${TABLE}."CURRENT_WORK_EMAIL" IS NOT NULL THEN ${TABLE}."CURRENT_WORK_EMAIL" END ;;
    drill_fields: [employee_info*]
    filters: [attended_topic: "No"]
  }

  measure: total_count_of_employees {
    type: count_distinct
    sql: ${TABLE}."CURRENT_WORK_EMAIL" ;;
    drill_fields: [employee_info*]
  }

  measure: total_count_of_eligible_topics {
    type: count_distinct
    sql: ${topic};;
    filters: [topics_discussed: "Previous Topics"]
  }

  measure: total_count_of_topics_attended_by_employee {
    type: count_distinct
    sql: ${topic} ;;
    filters: [attended_topic: "Yes"]
  }

  measure: total_count_of_weekly_topics_attended_by_employee {
    type: count_distinct
    sql: ${topic} ;;
    filters: [attended_topic: "Yes", topic_type: "Weekly"]
  }

  measure: total_count_of_weekly_topics_not_attended_by_employee {
    type: count_distinct
    sql: ${topic} ;;
    filters: [attended_topic: "No", topic_type: "Weekly"]
    drill_fields: [topic,topic_start_date]
  }

  measure: topic_completion_percentage_individual {
    type: number
    sql: ${total_count_of_topics_attended_by_employee}/case when ${total_count_of_eligible_topics} = 0 then null else ${total_count_of_eligible_topics} end ;;
    value_format_name: percent_1
  }

  measure: percentage_complete {
    type: number
    sql: ${count_of_attended_employees}/case when ${total_count_of_employees} = 0 then null else ${total_count_of_employees} end ;;
    value_format_name: percent_1
  }

  measure: total_percentage_complete {
    type: number
    sql:
    CASE WHEN (${count_of_attended_employees} + ${count_of_not_attended_employees}) = 0 THEN NULL
      ELSE ${count_of_attended_employees} / (${count_of_attended_employees} + ${count_of_not_attended_employees})
    END ;;
    value_format_name: percent_1
  }


  measure: total_count {
    type: number
    sql: (${count_of_attended_employees} + ${count_of_not_attended_employees}) ;;
    drill_fields: [employee_info*]
  }

  filter: region_name_filter_mapping {
    type: string
  }

  filter: district_filter_mapping {
    type: string
  }

  filter: market_name_filter_mapping {
    type: string
  }

  filter: market_type_filter_mapping {
    type: string
  }

  filter: topic_type_filter_mapping {
    type: string
  }


  set: employee_info {
    fields: [
      employee_name,
      email_address,
      market_name,
      district,
      region_name,
      record_effective_date,
      employee_title,
      employee_status,
      topic,
      topic_completed_date
    ]
  }


  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: safety_meeting_union {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
