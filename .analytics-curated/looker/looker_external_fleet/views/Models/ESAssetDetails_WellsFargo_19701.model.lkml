connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: esassetdetails_wellsfargo_19701 {
  group_label: "Fleet"
  label: "EquipmentShare Asset Details for Wells Fargo"
  case_sensitive: no

  }
