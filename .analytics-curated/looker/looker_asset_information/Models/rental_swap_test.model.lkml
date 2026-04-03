connection: "es_snowflake"

include: "/views/ANALYTICS/rental_swap_test.view.lkml"

explore: rental_swap_test {
  group_label: "Rental Swap Test"
  label: "Testing Rental Swaps"
  case_sensitive: no
}
