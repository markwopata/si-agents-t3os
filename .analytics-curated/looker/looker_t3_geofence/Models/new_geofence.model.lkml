connection: "reportingc_warehouse"

## include: "/views/*.view.lkml"              # include all views in the views/ folder in this project
include: "/**/*.view.lkml"                 # include all views in this project

explore: new_geofence {
  label: "New Geofence Dashboard"
  description: "Time in Geofence per asset per day"
}


explore: geofence_competition {
  label: "Geofence Competition"
  description: "Time in Geofence per asset per day"
}

explore: geofence_usage_dips {
  label: "Geofence Usage Dips"
  description: "Time in Geofence per asset per day"
}

explore: performing_geofences {
  label: "Performing Geofences"
  description: "Time in Geofence per asset per day"
}

explore: time_windows {
  label: "Time Windows"
  description: "Time in Geofence per asset per day"
}

explore: rental_alerts {
  label: "Rental Alerts"
  description: "Time in Geofence per asset per day"
}

explore: asset_dependency_risk {
  label: "Asset Dependency Risk"
  description: "Time in Geofence per asset per day"
}

explore: geofence_transfers {
  label: "Geofence Transfers"
  description: "Time in Geofence per asset per day"
}

explore: rental_overages {
  label: "Rental Overages"
  description: "Time in Geofence per asset per day"
}

explore: rental_backup_savings {
  label: "Rental Backup Savings"
  description: "Time in Geofence per asset per day"
}

explore: rental_backup_savings_ideal {
  label: "Rental Backup Savings Ideal"
  description: "Time in Geofence per asset per day"
}

explore: priority_actions {
  label: "Priority Actions"
  description: "Time in Geofence per asset per day"
}
