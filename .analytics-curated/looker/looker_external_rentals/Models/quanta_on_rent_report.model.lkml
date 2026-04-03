connection: "es_warehouse"

include: "/views/quanta_on_rent_report/quanta_on_rent_report.view.lkml"

explore: quanta_on_rent_report {
  group_label: "Rentals"
  label: "Quanta On Rent Report"
  description: "Custom Report for Quanta"
  case_sensitive: no
}
