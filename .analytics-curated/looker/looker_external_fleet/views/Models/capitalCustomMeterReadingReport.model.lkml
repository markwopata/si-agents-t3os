connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: capitalcustommeterreadingreport {
  group_label: "Fleet"
  label: "Custom Hours/ Odometer Import"
  case_sensitive: no

  }
