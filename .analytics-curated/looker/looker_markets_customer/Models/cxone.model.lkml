connection: "es_snowflake_analytics"

# include: "/views/ANALYTICS/CXone/completed_contacts.view.lkml"
# include: "/views/ANALYTICS/CXone/agents.view.lkml"
# include: "/views/ANALYTICS/CXone/teams.view.lkml"
# include: "/views/ES_WAREHOUSE/users.view.lkml"
# include: "/views/ANALYTICS/parsed_phone_numbers.view.lkml"
# include: "/views/ES_WAREHOUSE/companies.view.lkml"

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# explore: completed_contacts {
#   description: "View for querying completed contacts (calls) in the NICE phone system"
#   case_sensitive: no

#   join: agents {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${completed_contacts.agent_id} = ${agents.agent_id} ;;
#   }

#   join: teams {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${agents.team_id} = ${teams.team_id} ;;
#   }

#   join: call_to {
#     from: parsed_phone_numbers
#     type: left_outer
#     relationship: many_to_one
#     sql_on: TRY_CAST(${completed_contacts.to_addr} as number) = ${call_to.phone_number};;
#   }

#   join: to_user {
#     from: users
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${call_to.user_id} = ${to_user.user_id};;
#   }

#   join: to_company {
#     from: companies
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${to_user.company_id} = ${to_company.company_id} ;;
#   }

#   join: call_from {
#     from: parsed_phone_numbers
#     type: left_outer
#     relationship: many_to_one
#     sql_on: TRY_CAST(${completed_contacts.from_addr} as number) = ${call_from.phone_number};;
#   }

#   join: from_user {
#     from: users
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${call_from.user_id} = ${from_user.user_id};;
#   }

#   join: from_company {
#     from: companies
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${from_user.company_id} = ${from_company.company_id} ;;
#   }

# }
