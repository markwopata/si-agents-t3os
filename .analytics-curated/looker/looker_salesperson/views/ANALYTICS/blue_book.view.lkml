view: blue_book {
  # # You can specify the table name if it's different from the view name:
  sql_table_name:"ANALYTICS"."PUBLIC"."THE_BLUE_BOOK";;
  #
  # # Define your dimensions and measures here, like this:
   dimension: email_id {
     type: string
     sql: ${TABLE}."EMAIL ID";;
   }

  dimension: project_id {
    type: number
    sql: ${TABLE}."BLUE BOOK PROJECT ID";;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE";;
  }

  dimension: project_title {
    type: string
    sql: ${TABLE}."BLUE BOOK PROJECT TITLE";;
  }

  dimension: project_city {
    type: string
    sql: ${TABLE}."BLUE BOOK PROJECT CITY";;
  }

  dimension: project_state {
    type: string
    map_layer_name: us_states
    sql: ${TABLE}."BLUE BOOK PROJECT STATE";;
    drill_fields: [project_zip]
  }

  dimension: project_zip {
    type: string
    map_layer_name: us_zipcode_tabulation_areas
    sql: ${TABLE}."BLUE BOOK PROJECT ZIP";;
  }

  dimension: custom_search_description {
    type: string
    sql: ${TABLE}."BLUE BOOK CUSTOM SEARCH DESCRIPTION";;
  }

  dimension: project_status {
    type: string
    sql: ${TABLE}."BLUE BOOK PROJECT STATUS";;
  }

  dimension: project_structure {
    type: string
    sql: ${TABLE}."BLUE BOOK PROJECT STRUCTURE";;
  }

  dimension: project_prebid_meeting {
    type: string
    sql: ${TABLE}."PROJECT PRE-BID MEETING";;
  }

  dimension: project_prebid_mandatory {
    type: string
    sql: ${TABLE}."PROJECT PRE-BID MANDATORY";;
  }

  dimension: bid_date {
    type: date_time
    sql: ${TABLE}."PROJECT BID DUE DATE";;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY";;
  }

  dimension: company_link {
    type: string
    sql: ${company};;
    link: {
      label: "{{value}} Company Contact Details"
      url: "/dashboards/561?Company={{ value | encode_uri }}"
    }
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST NAME";;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST NAME";;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE";;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}."PHONE";;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL";;
  }

  dimension: proview_or_projectview {
    type: string
    sql: ${TABLE}."PROVIEW OR PROJECTVIEW" ;;
    html: <font color="blue "><u><a href={{value}}> {{value}} </a></font></u> ;;
  }

  dimension: classification_matches {
    type: string
    sql: ${TABLE}."CLASSIFICATION/SPECSEARCH MATCHES";;
  }

  dimension: street {
    type: string
    sql: ${TABLE}."STREET";;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY";;
  }

  dimension: state {
    type: string
    map_layer_name: us_states
    sql: ${TABLE}."STATE";;
  }

  dimension: postal_code{
    type: string
    map_layer_name: us_zipcode_tabulation_areas
    sql: ${TABLE}."POSTAL CODE";;
  }

  dimension: complete_address {
    type: string
    sql:  CONCAT(${street}, ', ', ${city}, ', ', ${state}, ' ', ${postal_code}) ;;
  }

  dimension: lead_owner {
    type: string
    sql: ${TABLE}."BLUE BOOK LEAD OWNER";;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS";;
  }

  dimension: lead_source {
    type: string
    sql: ${TABLE}."LEADSOURCE";;
  }

  dimension: record_type {
    type: string
    sql: ${TABLE}."RECORDTYPE";;
  }

  dimension: account_code {
    type: number
    sql: ${TABLE}."BLUE BOOK ACCOUNT CODE";;
  }

  dimension: unique_id {
    type: string
    sql: ${TABLE}."BLUE BOOK UNIQUE ID";;
  }

  dimension: projectview_url{
    type: string
    sql: ${TABLE}."PROJECTVIEW URL" ;;
    html:<font color="blue "><u><a href={{value}}>{{value}}</a></font></u>  ;;
  }

  dimension: city_state {
    type:  string
    sql:  CONCAT(${city}, ', ', ${state}) ;;
  }

  dimension: project_city_state {
    type:  string
    sql:  CONCAT(${project_city}, ', ', ${project_state}) ;;
  }

  dimension: company_contacts {
    type:  string
    sql: CONCAT(${first_name}, ' ', ${last_name});;
  }

  measure: project_count {
    type:  count_distinct
    sql:  ${project_id} ;;
  }

  measure:  company_count {
    type:  count_distinct
    sql:  ${unique_id} ;;
  }


}
