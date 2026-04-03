include: "/_base/fleet_optimization/dim_locations_fleet_opt.view.lkml"

view: +dim_locations_fleet_opt {
  label: "Dim Locations Fleet Opt"

  dimension: location_lat_long {
    type: location
    sql_latitude: ${location_latitude} ;;
    sql_longitude: ${location_longitude} ;;
  }
}
