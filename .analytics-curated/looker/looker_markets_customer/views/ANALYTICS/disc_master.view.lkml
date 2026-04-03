view: disc_master {
  derived_table: {
    sql:
    with consolidate_discs as(
    select
    *
    ,ROW_NUMBER() OVER (PARTITION BY email_address  ORDER BY status  ) AS rn
    from analytics.public.DISC_MASTER dm
    order by disc_sent_date desc
    )
    select
    *
    from consolidate_discs
    where rn=1
    order by disc_sent_date desc
    ;;
  }

  dimension: applicant {
    type: string
    sql: ${TABLE}."APPLICANT" ;;
  }

  dimension: basic_style {
    type: string
    sql: ${TABLE}."BASIC_STYLE" ;;
  }

  dimension: blend {
    type: string
    sql: ${TABLE}."BLEND" ;;
  }

  dimension: completed_date {
    type: string
    sql: ${TABLE}."COMPLETED_DATE" ;;
  }

  dimension: disc_code {
    type: string
    sql: ${TABLE}."DISC_CODE" ;;
  }

  dimension: disc_sent_date {
    type: string
    sql: ${TABLE}."DISC_SENT_DATE" ;;
  }

  dimension: days_since_disc_sent {
    type: number
    sql: (current_timestamp::DATE - ${disc_sent_date}::DATE)::NUMERIC(20,0) ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: environment_style {
    type: string
    sql: ${TABLE}."ENVIRONMENT_STYLE" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: link_to_disc_pdf {
    type: string
    html: <font color="blue "><u><a href ="https://www.discoveryreport.com/v/{{disc_code._value}}"target="_blank">{{environment_style._value}}</a></font></u> ;;
    sql: ${disc_code} ;;
  }

  dimension: main_strength {
    type: string
    sql: ${TABLE}."MAIN_STRENGTH" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  measure: count {
    type: count
    drill_fields: [first_name, last_name]
  }

  dimension: completed_disc {
    type: yesno
    sql: ${status} = 'completed' ;;
  }

  dimension: pending_disc {
    type: yesno
    sql: ${status} = 'pending_completion' OR ${status} is NULL ;;
  }

  dimension: d_environment {
    type: number
    sql:  case when ${TABLE}."ENVIRONMENT_STYLE" is null or ${TABLE}."ENVIRONMENT_STYLE" = 'fe69fb8d-2c0d-434a-9a9b-f658fdc4c2cc' then null else cast(split_part(${TABLE}."ENVIRONMENT_STYLE",' ',1) as integer) end;;
  }

  dimension: i_environment {
    type: number
    sql:  case when ${TABLE}."ENVIRONMENT_STYLE" is null or ${TABLE}."ENVIRONMENT_STYLE" = 'fe69fb8d-2c0d-434a-9a9b-f658fdc4c2cc' then null else cast(split_part(${TABLE}."ENVIRONMENT_STYLE",' ',2) as integer) end;;
  }

  dimension: s_environment {
    type: number
    sql:  case when ${TABLE}."ENVIRONMENT_STYLE" is null or ${TABLE}."ENVIRONMENT_STYLE" = 'fe69fb8d-2c0d-434a-9a9b-f658fdc4c2cc' then null else cast(split_part(${TABLE}."ENVIRONMENT_STYLE",' ',3) as integer) end;;
  }

  dimension: c_environment {
    type: number
    sql:  case when ${TABLE}."ENVIRONMENT_STYLE" is null or ${TABLE}."ENVIRONMENT_STYLE" = 'fe69fb8d-2c0d-434a-9a9b-f658fdc4c2cc' then null else cast(split_part(${TABLE}."ENVIRONMENT_STYLE",' ',4) as integer) end;;
  }

  dimension: dominant_environment {
    type: string
    sql:  case when ${blend} = 'LEVEL Blend' then 'Level'
          else
            case greatest(${d_environment}, ${i_environment}, ${s_environment}, ${c_environment}) when ${d_environment} then 'D' when ${i_environment} then 'I' when ${s_environment} then 'S' when ${c_environment} then 'C' else null
            end
          end
      ;;
  }

  measure: completed_disc_count {
    type: count
    filters: [completed_disc: "Yes"]
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      first_name,
      last_name,
      environment_style,
      link_to_disc_pdf
    ]
  }

  measure: dom_d_count {
    type: count
    filters: [dominant_environment: "D"]
    drill_fields: [applicant,environment_style,company_directory.employee_title]
  }

  measure: dom_i_count {
    type: count
    filters: [dominant_environment: "I"]
    drill_fields: [applicant,environment_style,company_directory.employee_title]
  }

  measure: dom_s_count {
    type: count
    filters: [dominant_environment: "S"]
    drill_fields: [applicant,environment_style,company_directory.employee_title]
  }

  measure: dom_c_count {
    type: count
    filters: [dominant_environment: "C"]
    drill_fields: [applicant,environment_style,company_directory.employee_title]
  }
}
