connection: "es_snowflake"

include: "/metrics_memo/memo_months.view.lkml"
include: "/metrics_memo/memo_paying_customers.view.lkml"
include: "/metrics_memo/memo_new_users.view.lkml"
include: "/metrics_memo/memo_intercom_tags.view.lkml"
include: "/metrics_memo/memo_customer_churn.view.lkml"
include: "/metrics_memo/memo_avg_daily_users.view.lkml"
include: "/metrics_memo/memo_app_usage.view.lkml"


explore: memo_months {
  label: "Metrics Memo"
  case_sensitive: no

  join: memo_paying_customers {
    type: left_outer
    sql_on: 1 = 1;;
    relationship: one_to_many
  }

  join: memo_new_users {
    type: left_outer
    sql_on: 1 = 1;;
    relationship: one_to_many
  }

  join: memo_intercom_tags {
    type: left_outer
    sql_on: 1 = 1;;
    relationship: one_to_many
  }

  join: memo_customer_churn {
    type: left_outer
    sql_on: 1 = 1;;
    relationship: one_to_many
  }

  join: memo_avg_daily_users {
    type: left_outer
    sql_on: 1 = 1;;
    relationship: one_to_many
  }

  join: memo_app_usage {
    type: left_outer
    sql_on: 1 = 1;;
    relationship: one_to_many
  }
}
