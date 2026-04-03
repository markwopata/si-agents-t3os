include: "/_standard/custom_sql/workday_region_cleanup.view.lkml"

view: +workday_region_cleanup {}

explore: workday_region_cleanup {
  label: "Workday Region Cleanup"
}
