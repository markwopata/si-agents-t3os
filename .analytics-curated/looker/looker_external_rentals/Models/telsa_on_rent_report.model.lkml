connection: "es_warehouse"

include: "/views/telsa_on_rent_report/telsa_on_rent_report.view.lkml"

explore: telsa_on_rent_report {
  group_label: "Rentals"
  label: "Telsa On Rent Report"
  description: "Custom Report for Telsa"
  case_sensitive: no
}
