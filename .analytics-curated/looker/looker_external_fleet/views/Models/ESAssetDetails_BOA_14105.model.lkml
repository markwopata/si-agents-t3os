connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: esassetdetails_boa_14105 {
  group_label: "Fleet"
  label: "EquipmentShare Asset Details for Bank of America"
  case_sensitive: no
}
