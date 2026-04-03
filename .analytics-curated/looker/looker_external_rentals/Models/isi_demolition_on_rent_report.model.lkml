connection: "es_warehouse"

include: "/views/isi_demolition_on_rent_report/isi_demolition_on_rent_report.view.lkml"

explore: isi_demolition_on_rent_report {
  group_label: "Rentals"
  label: "ISI Demolition On Rent Report"
  description: "Custom Report for ISI Demolition"
  case_sensitive: no
}
