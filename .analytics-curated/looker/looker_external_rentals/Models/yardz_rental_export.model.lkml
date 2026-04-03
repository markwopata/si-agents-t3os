connection: "es_warehouse"

include: "/views/yardz_rental_export/yardz_rental_export.view.lkml"

explore: yardz_rental_export {
  group_label: "Rentals"
  label: "Yardz Rental Export"
  description: "Custom Export for Yardz"
  case_sensitive: no
}
