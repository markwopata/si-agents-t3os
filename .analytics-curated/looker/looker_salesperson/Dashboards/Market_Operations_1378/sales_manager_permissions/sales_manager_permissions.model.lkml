connection: "es_snowflake_analytics"

include: "/Dashboards/Market_Operations_1378/sales_manager_permissions/*.view.lkml"


explore: sales_manager_permissions {
  group_label: "Permissions"
  label: "Sales Manager Permissions"
  description: "Permissions determining what reps the logged in user can see"
  case_sensitive: no
  persist_for: "8 hours"
  sql_always_where: ${sales_manager_permissions.employee_title} IN ('Territory Account Manager', 'Strategic Account Manager', 'Rental Territory Manager','Market Consultant Manager')
;;
}



explore: sales_retail_permissions {
  group_label: "Permissions"
  label: "Sales Manager + Retail Manager Permissions"
  description: "Permissions determining what reps the logged in user can see"
  case_sensitive: no
  persist_for: "8 hours"
  sql_always_where: ${sales_retail_permissions.employee_title} IN ('Territory Account Manager', 'Strategic Account Manager', 'Rental Territory Manager','Market Consultant Manager', 'Retail Account Manager')
    ;;
}
