connection: "s_works"

include: "/Dashboards/Vehicle_Mileage_Reporting/views/vehicle_lease_value.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/Dashboards/Vehicle_Mileage_Reporting/views/annual_vehicle_lease_value.view.lkml"
include: "/Dashboards/Vehicle_Mileage_Reporting/views/asset_physical.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/SWORKS/*.view.lkml"

explore: mileage_detail {
  from: company_directory
  # Per David Beach, managers should not be able to see the detailed trips because it includes personal mileage. -Jack G 2022-09-14
  # God View is excluded from this because many managers have it.
  sql_always_where:
  ${es_vehicle_trips.end_timestamp_date} >= ${user_asset_assignments.report_start_date}
  AND
  ${es_vehicle_trips.end_timestamp_date} < ${user_asset_assignments.report_end_date}

  AND
  ${es_vehicle_trips.trip_distance_miles} > 0

  AND
  (${asset_physical.model} not in
  (
  'Transit-250 Telematics',
  'Transit 2WD Jose Ruiz',
  '5500 Heavy Crane',
  '567',
  'Transit 2WD',
  '5500 Standard Crane',
  '2500 Standard Lube')
  OR ${asset_physical.model} IS NULL)

  AND
  (
  ${users.email_address} = '{{ _user_attributes['email'] }}'
  OR '{{ _user_attributes['email'] }}' = 'david.beach@equipmentshare.com'
  OR '{{ _user_attributes['email'] }}' = 'jabbok@equipmentshare.com'
  OR {{ _user_attributes['department'] }} = 'developer'
    );;

  join: users {
    type: inner
    relationship: one_to_many
    # company_id needs to be specified here or you'll pull in external users that have matching employee_ids
    sql_on: ${mileage_detail.employee_id} = TRY_TO_NUMBER(${users.employee_id}) and ${users.company_id} = 1854 ;;
  }

  # this is the table that maps users to their trips
  join: user_trips {
    type: left_outer
    relationship: one_to_many
    sql_on: ${users.user_id} = ${user_trips.user_id} ;;
  }

  # this table is replicated from the tracker source data from T3. It shows the assets and their trips, but the user is in user_trips.
  join: es_vehicle_trips {
    type: left_outer
    relationship: one_to_one
    sql_on: ${user_trips.trip_id} = ${es_vehicle_trips.trip_id} ;;
  }

  # Has the start and end dates for assets assigned to users. Fleet can update these dates after the fact, leading to confusing data
  # that shows drivers approved trips after their assignment end date.
  join: user_asset_assignments {
    type: inner
    relationship: one_to_one
    sql_on: ${users.user_id} = ${user_asset_assignments.user_id}
            AND ${es_vehicle_trips.asset_id} = ${user_asset_assignments.asset_id}
            AND ${es_vehicle_trips.end_timestamp_time} BETWEEN ${user_asset_assignments.start_raw} AND COALESCE(${user_asset_assignments.end_raw}, '2099-12-31');;
  }

  # This is a derived table based on analytics.tax.annual_vehicle_lease_value that is sourced from the IRS. See documentation file for link.
  join: vehicle_lease_value {
    type: inner
    relationship: one_to_many
    sql_on: ${user_asset_assignments.asset_id} = ${vehicle_lease_value.asset_id};;
  }

  join: asset_physical {
    type: inner
    relationship: one_to_one
    sql_on: ${es_vehicle_trips.asset_id} = ${asset_physical.asset_id} ;;
  }

  join: employee_market {
    from: market_region_xwalk
    type: inner
    relationship: many_to_one
    sql_on: ${mileage_detail.market_id} = ${employee_market.market_id} ;;
  }
}
