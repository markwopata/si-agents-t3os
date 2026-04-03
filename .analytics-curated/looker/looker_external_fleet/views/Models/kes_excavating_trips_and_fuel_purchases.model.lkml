connection: "es_warehouse"

include: "/views/kes_excavating_trips_and_fuel_purchases/*.view.lkml"

explore: kes_excavating_trips_and_fuel_purchases {
  group_label: "Fleet"
  label: "Trips and Fuel Purchases"
  description: "Used for KES Excavating for Wisconsin Logging"
  case_sensitive: no
  persist_for: "30 minutes"
}
