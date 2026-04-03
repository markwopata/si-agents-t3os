connection: "es_warehouse"

include: "/views/rentals_search_report/*.view.lkml"

explore: rentals_search {
  group_label: "RentOps"
  label: "Rental Search"
  description: "Explore used for RentOps Rental Search Report"
  case_sensitive: no
  persist_for: "20 minutes"

}
