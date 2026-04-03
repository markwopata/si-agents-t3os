connection: "es_snowflake_analytics"

include: "/views/custom_sql/new_sage_loan_id.view.lkml"

explore:  new_sage_loan_id {case_sensitive: no}
