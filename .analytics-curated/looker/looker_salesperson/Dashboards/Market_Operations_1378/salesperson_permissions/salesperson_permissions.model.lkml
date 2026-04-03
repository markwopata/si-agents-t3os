connection: "es_snowflake_analytics"

include: "/Dashboards/Market_Operations_1378/salesperson_permissions/*.view.lkml"


explore: salesperson_permissions {
  group_label: "Permissions"
  label: "Salesperson Permissions"
  description: "Permissions determining which salesperson page the logged in user can see"
  case_sensitive: no
  sql_always_where: ${salesperson_permissions.employee_title} IN ('Territory Account Manager', 'Strategic Account Manager', 'Rental Territory Manager');;
}
