include: "/_standard/people_analytics/docebo/certification.layer.lkml"
include: "/_standard/explores/docebo_base.explore"

explore: +company_directory {
  label: "PA Docebo Certifications"
  case_sensitive: no

  join: users {
    type: inner
    relationship: one_to_one
    sql_on: to_varchar(${company_directory.employee_id}) = ${users.employee_id};;

  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.market_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: certification {
    type: left_outer
    relationship: one_to_many
    sql_on: ${users.id} = ${certification.user_id} ;;
  }
}
