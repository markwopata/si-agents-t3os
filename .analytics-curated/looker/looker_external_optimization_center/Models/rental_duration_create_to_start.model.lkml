connection: "es_warehouse"

include: "/views/rental_duration_create_to_start_date/*.view.lkml"                # include all views in the views/ folder in this project

explore: rental_duration_create_to_start_date {
  group_label: "Ad Hoc"
  label: "Rental Duration from Create Date to On Rent Status"
  case_sensitive: no


}
