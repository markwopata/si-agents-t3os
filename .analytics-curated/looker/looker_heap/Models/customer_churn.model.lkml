connection: "es_snowflake"

  include: "/views/ANALYTICS/churn_company.view.lkml"
  include: "/views/ANALYTICS/churn_tickets.view.lkml"

  explore: churn_company {
    group_label: "Customer Churn"
    case_sensitive: no

    join: churn_tickets {
      type: left_outer
      sql_on: ${churn_company.company_id} = ${churn_tickets.company_id} ;;
      relationship: one_to_many
    }
  }
