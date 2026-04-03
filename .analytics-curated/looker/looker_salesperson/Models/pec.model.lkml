connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/pec.view.lkml"
include: "/views/ANALYTICS/pec_contact.view.lkml"
include: "/views/ANALYTICS/plant.view.lkml"
include: "/views/ANALYTICS/plant_contact.view.lkml"


explore: pec {
  case_sensitive: no

  join: pec_contact {
    type: left_outer
    relationship: many_to_one
    sql_on: ${pec.project_id} = ${pec_contact.proj_id} ;;
  }
}


# Commented out due to low usage on 2026-03-26
# explore: plant {
#   case_sensitive: no
#
#   join: plant_contact {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${plant.plant_id} = ${plant_contact.plant_id} ;;
#   }
# }
