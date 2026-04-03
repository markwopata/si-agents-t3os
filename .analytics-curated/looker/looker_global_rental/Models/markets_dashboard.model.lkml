connection: "es_warehouse"

include: "/views/markets/*.view.lkml"

explore: booked_rental_rate {
  group_label: "RentOps"
  label: "Booked Rental Rate"
  description: "Explore contains by day effective daily rate"
  case_sensitive: no
  persist_for: "45 minutes"
}

explore: rental_detail_information {
  group_label: "RentOps"
  label: "Rental Details"
  description: "Explore contains rental detail information"
  case_sensitive: no
  persist_for: "45 minutes"
}

explore: asset_info {
  group_label: "RentOps"
  label: "Assets"
  description: "Explore contains asset information for asset aggregation"
  case_sensitive: no
  persist_for: "45 minutes"
}

explore:line_items {
  group_label: "RentOps"
  label: "Line Items"
  description: "Explore contains information regarding line items"
  case_sensitive: no
  persist_for: "45 minutes"
}
