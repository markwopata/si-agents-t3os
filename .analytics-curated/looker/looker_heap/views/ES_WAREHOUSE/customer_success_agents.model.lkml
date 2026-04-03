connection: "es_snowflake"

include: "/views/t3_company_customer_success_agents/*.view.lkml"

explore: company_customer_success_agents {
  group_label: "Customer Success"
  label: "T3 Company Customer Success Agents"
  case_sensitive: no

  join: heap_user_sessions {
    type: inner
    relationship: many_to_one
    sql_on: ${heap_user_sessions.company_id} = ${company_customer_success_agents.company_id} ;;
  }
}
