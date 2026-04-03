connection: "es_snowflake_analytics"

include: "command_audit.view.lkml"

explore: command_audit {
  label: "Command Audit Line Item ID"
  description: "Looks up command audit based on Line Item ID."
}
