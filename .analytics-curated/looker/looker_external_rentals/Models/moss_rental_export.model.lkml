connection: "es_warehouse"

include: "/views/moss_rental_export/moss_rental_export.view.lkml"

explore: moss_rental_export {
  group_label: "Rentals"
  label: "Moss Rental Export"
  description: "Custom Export for Moss"
  case_sensitive: no
}
