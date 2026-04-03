connection: "es_snowflake"

include: "/views/custom_sql/credit_specialists/credit_apps.view.lkml"
include: "/views/custom_sql/outstanding_balances.view.lkml"


explore: credit_apps {
  join: outstanding_balances {
    type: left_outer
    relationship: one_to_many
    sql_on: ${credit_apps.company_id} = ${outstanding_balances.company_id}  ;;
}
}
