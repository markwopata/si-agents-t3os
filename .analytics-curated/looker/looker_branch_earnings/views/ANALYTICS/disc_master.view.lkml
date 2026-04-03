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
    label: "Name"
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
    label: "DISC Code"
    type: string
    sql: ${TABLE}."DISC_CODE" ;;
  }

  dimension: disc_sent_date {
    type: string
    sql: ${TABLE}."DISC_SENT_DATE" ;;
  }

  dimension: disc_website_link {
    type: string
    html: <font color="blue "><u><a href = "http://www.discoveryreport.com/v/{{disc_master.disc_code._value}}"target="_blank">Link to DISC</a></font></u> ;;
    sql:  ${disc_code} ;;
  }

  dimension: link_to_disc_pdf {
    type: string
    html: <font color="blue "><u><a href = "http://www.discoveryreport.com/v/{{disc_master.disc_code._value}}"target="_blank">Link to DISC</a></font></u> ;;
    sql:  ${disc_code} ;;
  }

  dimension: email_address {
    label: "Email Address"
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
    primary_key: yes
  }

  dimension: environment_style {
    label: "DISC Main"
    type: string
    sql: ${TABLE}."ENVIRONMENT_STYLE" ;;
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

  dimension: main_strength {
    type: string
    sql: ${TABLE}."MAIN_STRENGTH" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: updated_date {
    type: string
    sql: ${TABLE}."UPDATED_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
