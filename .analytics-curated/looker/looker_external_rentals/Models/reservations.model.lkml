connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: rentals {
  sql_always_where:
  (${companies.company_id} = {{ _user_attributes['company_id'] }}
  and
  ${rentals.rental_id} in (select r.rental_id from rentals r
  join orders o on o.order_id = r.rental_id
  join rental_location_assignments la on la.rental_id = r.rental_id
  join geofences g on g.location_id = la.location_id
  join organization_geofence_xref x on x.geofence_id = g.geofence_id
  join organization_user_xref ux on ux.organization_id = x.organization_id
  where ux.user_id = {{ _user_attributes['user_id'] }}
  ))
  OR (${users.company_id} = {{ _user_attributes['company_id'] }}
  and {{ _user_attributes['user_id'] }} = (select user_id from users where user_id = {{ _user_attributes['user_id'] }} and security_level_id in (1,2))
  );;
  group_label: "Rentals"
  label: "Reservation Info"
  case_sensitive: no
  persist_for: "10 minutes"

  join: equipment_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_assignments.asset_id} = ${assets.asset_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_classes.equipment_class_id} = ${rentals.equipment_class_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: rental_location_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_location_assignments.rental_id} = ${rentals.rental_id} and ${rental_location_assignments.end_date} is null ;;
  }

  join: locations {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_location_assignments.location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${states.state_id} = ${locations.state_id} ;;
  }

  join: orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${orders.order_id} ;;
  }

  join: purchase_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${purchase_orders.purchase_order_id} = ${orders.purchase_order_id} ;;
  }

  join: contracts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${contracts.order_id} ;;
  }

  join: users {
    type: inner
    relationship: many_to_one
    sql_on: ${users.user_id} = ${orders.user_id} ;;
  }

  join: companies {
    from: users
    type: inner
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${users.company_id} ;;
  }
}
