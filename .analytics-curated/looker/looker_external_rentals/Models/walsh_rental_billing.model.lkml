connection: "reportingc_warehouse"

include: "/views/walsh_rental_export/*.view.lkml"

 explore: walsh_rental_export {
  label: "Walsh On Rent Report"
}

explore: walsh_rental_history_spend {
  label: "Walsh Rental Historical Spend"
}
