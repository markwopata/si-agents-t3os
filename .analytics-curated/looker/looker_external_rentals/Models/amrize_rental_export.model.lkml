connection: "es_warehouse"

include: "/views/amrize_on_rent_export/amrize_on_rent_export.view.lkml"

explore: amrize_on_rent_export {
  group_label: "Rentals"
  label: "Amrize Rental Export"
  description: "Custom Export for Amrize National Account"
  case_sensitive: no
}
