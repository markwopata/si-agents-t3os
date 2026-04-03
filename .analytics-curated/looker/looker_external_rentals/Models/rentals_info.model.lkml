connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

datagroup: on_rent_update {
  sql_trigger: select max(DATA_REFRESH_TIMESTAMP) from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ON_RENT ;;
  max_cache_age: "2 hours"
  description: "Looking at triage on rent for latest update. Will update data when it detects a new update time."
}

explore: rentals {
  sql_always_where:
  {{ _user_attributes['company_id'] }} = ${companies.company_id}
  --and {{ _user_attributes['company_id'] }} = ${purchase_orders.company_id}
  and (${assets.asset_id} in

  (
  SELECT
      coalesce(ea.asset_id, r.asset_id) as asset_id
    FROM
    orders o
    join users u on u.user_id = o.user_id -- perf: pull in viewing user ID at join level for some sec_levels?
    join rentals r on r.order_id = o.order_id
    left join equipment_assignments ea on ea.rental_id = r.rental_id and ea.end_date is null
    join rental_types rt on rt.rental_type_id = r.rental_type_id
    WHERE

        --overlaps(
            --coalesce(ea.start_date,r.start_date),
            --coalesce(ea.end_date, r.end_date, CURRENT_TIMESTAMP),
            --current_timestamp::date,
            --current_timestamp
        --)
        r.rental_status_id = 5
    AND
        u.company_id
            IN (
            SELECT u.company_id
            FROM users u
            WHERE u.user_id = {{ _user_attributes['user_id'] }}::numeric
            )
    AND (
        u.user_id =
            CASE
                WHEN (
                    SELECT security_level_id
                    FROM users u
                    WHERE u.user_id = {{ _user_attributes['user_id'] }}::numeric
                )
                IN (1, 2)
                THEN u.user_id
                ELSE {{ _user_attributes['user_id'] }}::numeric
                END
                OR
                r.rental_id in (
                select r.rental_id
                  from rentals r
                  join orders o on o.order_id = r.order_id
                  join rental_location_assignments la on la.rental_id = r.rental_id
                  join geofences g on g.location_id = la.location_id
                  join organization_geofence_xref x on x.geofence_id = g.geofence_id
                  join organization_user_xref ux on ux.organization_id = x.organization_id
                  where ux.user_id = {{ _user_attributes['user_id'] }}::numeric
                )
        )
  )


  or ${asset_id} is null)
  ;;
  # Current rentals only; will need to add parameters to pull by date
  group_label: "Rentals"
  label: "Rental Info"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: equipment_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_assignments.asset_id} = ${assets.asset_id} ;;
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
    sql_on: ${rental_location_assignments.rental_id} = ${equipment_assignments.rental_id} and ${rental_location_assignments.end_date} is null ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental_location_assignments.location_id} = ${locations.location_id} ;;
  }

  join: admin_cycle {
    type: left_outer
    relationship: one_to_one
    sql_on: ${admin_cycle.rental_id} = ${rentals.rental_id} and ${admin_cycle.asset_id} = ${equipment_assignments.asset_id} ;;
  }

  join: orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.order_id} = ${orders.order_id} ;;
  }

  join: purchase_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${purchase_orders.purchase_order_id} = ${orders.purchase_order_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${invoices.order_id} ;;
  }

  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} AND ${line_items.asset_id} = ${assets.asset_id} ;;
  }

  join: line_item_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id} and ${line_items.domain_id} = ${line_item_types.domain_id} ;;
  }

  join: remaining_rental_cost {
    type: inner
    relationship: one_to_one
    sql_on: ${remaining_rental_cost.rental_id} = ${rentals.rental_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${orders.user_id} ;;
  }

  join: companies {
    type: inner
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${users.company_id} ;;
  }

  join: deliveries {
    type: left_outer
    relationship: many_to_one
    sql_on: ${deliveries.order_id} = ${orders.order_id} and ${deliveries.rental_id} = ${equipment_assignments.rental_id} and ${deliveries.location_id} is not null and ${equipment_assignments.drop_off_delivery_id} = ${deliveries.delivery_id} ;;
  }

  join: delivery_statuses {
    type: inner
    relationship: one_to_one
    sql_on: ${delivery_statuses.delivery_status_id} = ${deliveries.delivery_status_id} ;;
  }

  join: delivery_location {
    from: locations
    type: left_outer
    relationship: many_to_one
    sql_on: ${delivery_location.location_id} = ${deliveries.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: one_to_one
    sql_on: ${states.state_id} = ${delivery_location.state_id} ;;
  }

  join: payments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${payments.invoice_id} = ${invoices.invoice_id} and ${payments.company_id} = ${companies.company_id} ;;
  }

  join: contracts {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.order_id} = ${contracts.order_id} ;;
  }

  join: items {
    from: max_invoice_and_rental_id
    type: left_outer
    relationship: many_to_one
    sql_on: ${items.invoice_id} = ${invoices.invoice_id} ;;
  }

  join: current_rentals_asset_usage_last_7_days {
    type: left_outer
    relationship: one_to_one
    sql_on: ${current_rentals_asset_usage_last_7_days.asset_id} = ${equipment_assignments.asset_id} and ${current_rentals_asset_usage_last_7_days.rental_id} = ${equipment_assignments.rental_id} ;;
  }
}

explore: rentals_spend_by {
  #sql_always_where:
  #{{ _user_attributes['company_id'] }} = ${purchase_orders.company_id}
  #and ${rentals.asset_id} in (select asset_id from table(rental_asset_list({{ _user_attributes['user_id'] }}, convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', current_date::timestamp_ntz), convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', current_date::timestamp_ntz), '{{ _user_attributes['user_timezone'] }}')));;
  group_label: "Rentals"
  label: "Rental Spend By Info"
  case_sensitive: no
  # persist_for: "10 minutes"

  # join: purchase_orders {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${rentals_spend_by.po_name} = ${purchase_orders.name} and purchase_orders. ;;
  # }

  join: budget_remaining_by_invoice {
    type: left_outer
    relationship: many_to_one
    sql_on: ${budget_remaining_by_invoice.invoice_id} = ${rentals_spend_by.invoice_id} and ${budget_remaining_by_invoice.name} = ${rentals_spend_by.po_name} ;;
  }

  # join: equipment_assignments {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${rentals_spend_by.rental_id} = ${equipment_assignments.rental_id} ;;
  # }

  # join: hourly_asset_usage_date_filter {
  #   type: inner
  #   relationship: many_to_one
  #   sql_on: ${rentals_spend_by.asset_id} = ${hourly_asset_usage_date_filter.asset_id} ;;
  # }

  # join: assets {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${assets.asset_id} = ${equipment_assignments.asset_id} ;;
  # }

  # join: asset_types {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  # }

  # join: organization_asset_xref {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
  # }

  # join: rental_location_assignments {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${rental_location_assignments.rental_id} = ${equipment_assignments.rental_id} and ${rental_location_assignments.end_date} is null ;;
  # }

  # join: locations {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${rental_location_assignments.location_id} = ${locations.location_id} ;;
  # }

  # join: admin_cycle {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${admin_cycle.rental_id} = ${rentals_spend_by.rental_id} ;;
  # }

  # join: states {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${states.state_id} = ${locations.state_id} ;;
  # }

  # join: rentals {
  #   type: inner
  #   relationship: many_to_one
  #   sql_on: ${rentals.rental_id} = ${rentals_spend_by.rental_id} ;;
  # }

  # join: orders {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${rentals.order_id} = ${orders.order_id} ;;
  # }

  # join: invoices {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${orders.order_id} = ${invoices.order_id} ;;
  # }

  # join: line_items {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} AND ${rentals_spend_by.asset_id} = ${assets.asset_id} ;;
  # }

  # join: remaining_rental_cost {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${remaining_rental_cost.rental_id} = ${rentals_spend_by.rental_id} ;;
  # }

  # join: purchase_orders {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${purchase_orders.purchase_order_id} = ${orders.purchase_order_id} ;;
  # }
}

explore: orders {
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
  label: "Waiting for Pick Up Info"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: rentals {
    type: inner
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${rentals.order_id} ;;
  }

  join: equipment_assignments {
    type: inner
    relationship: many_to_one
    sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} ;;
  }

  join: assets {
    type: inner
    relationship: one_to_one
    sql_on: ${equipment_assignments.asset_id} = ${assets.asset_id} ;;
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
    sql_on: ${rental_location_assignments.rental_id} = ${equipment_assignments.rental_id} and ${rental_location_assignments.end_date} is null ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental_location_assignments.location_id} = ${locations.location_id} ;;
  }

  join: admin_cycle {
    type: inner
    relationship: one_to_one
    sql_on: ${admin_cycle.rental_id} = ${rentals.rental_id} ;;
  }

  join: purchase_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${purchase_orders.purchase_order_id} = ${orders.purchase_order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${orders.user_id} ;;
  }

  join: companies {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.company_id} = ${companies.company_id};;
  }

  join: deliveries {
    type: left_outer
    relationship: many_to_one
    sql_on: ${deliveries.order_id} = ${orders.order_id} and ${deliveries.rental_id} = ${equipment_assignments.rental_id} and ${rentals.return_delivery_id} = ${deliveries.delivery_id} ;;
  }

  join: delivery_statuses {
    type: inner
    relationship: one_to_one
    sql_on: ${delivery_statuses.delivery_status_id} = ${deliveries.delivery_status_id} ;;
  }

  join: delivery_location {
    from: locations
    type: left_outer
    relationship: many_to_one
    sql_on: ${delivery_location.location_id} = ${deliveries.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: one_to_one
    sql_on: ${states.state_id} = ${delivery_location.state_id} ;;
  }

}

explore: orders_hourly {
  from: orders
  # hourly_asset_usage_date_filter {
  sql_always_where:
  ${assets.asset_id} in (select asset_id from table(rental_asset_list({{ _user_attributes['user_id'] }}, convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', {% date_start rentals_spend_by.date_filter %}::timestamp_ntz), convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', {% date_end rentals_spend_by.date_filter %}::timestamp_ntz), '{{ _user_attributes['user_timezone'] }}')))
  and {{ _user_attributes['company_id'] }} = ${purchase_orders.company_id} ;;
  # Current rentals only; will need to add parameters to pull by date
  group_label: "Rentals"
  label: "Utilization Rental Info"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: equipment_assignments {
    type: inner
    relationship: many_to_one
    sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} ;;
  }

  join: rentals {
    type: inner
    relationship: many_to_one
    sql_on: ${rentals.order_id} = ${orders_hourly.order_id}  ;;
  }

  join: hourly_asset_usage_date_filter {
    type: inner
    relationship: many_to_one
    sql_on: ${hourly_asset_usage_date_filter.asset_id} = ${equipment_assignments.asset_id} AND ${equipment_assignments.start_date} >= {% date_start rentals_spend_by.date_filter %} ;;
  }

  join: purchase_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${purchase_orders.purchase_order_id} = ${orders_hourly.purchase_order_id} ;;
  }

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${hourly_asset_usage_date_filter.asset_id} ;;
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
    sql_on: ${rental_location_assignments.rental_id} = ${equipment_assignments.rental_id} and ${rental_location_assignments.end_date} is null ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental_location_assignments.location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: one_to_one
    sql_on: ${states.state_id} = ${locations.state_id} ;;
  }

  join: rentals_spend_by {
    type: left_outer
    relationship: many_to_one
    sql_on: ${purchase_orders.name} = ${rentals_spend_by.po_name} ;;
  }

  join: budget_remaining_by_invoice {
    type: left_outer
    relationship: many_to_one
    sql_on: ${budget_remaining_by_invoice.invoice_id} = ${rentals_spend_by.invoice_id} and ${budget_remaining_by_invoice.name} = ${purchase_orders.name} ;;
  }
}

explore: line_items {
  from: stg_t3_invoice_information
  group_label: "Rentals"
  label: "Invoice Information"
  case_sensitive: no
  sql_always_where:
    ${line_items.company_id} = {{ _user_attributes['company_id'] }}
    OR (
      ${line_items.user_id} = {{ _user_attributes['user_id'] }}
      AND {{ _user_attributes['user_id'] }} = (
        SELECT user_id
        FROM users
        WHERE user_id = {{ _user_attributes['user_id'] }}
        AND security_level_id IN (1,2)
      )
    ) ;;
  # Uses materialized table instead of dynamic joins for better performance

 }



explore: rental_history_by_date {
  group_label: "Rentals"
  label: "Rental History by Date"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental_history_by_date.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: contracts {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental_history_by_date.order_id} = ${contracts.order_id} ;;
  }

  join: rentals {
    type: inner
    relationship: one_to_one
    sql_on: ${rental_history_by_date.rental_id} = ${rentals.rental_id} ;;
  }

  join: equipment_assignments {
    type: inner
    relationship: many_to_one
    sql_on: ${equipment_assignments.rental_id} = ${rental_history_by_date.rental_id} ;;
  }
}

explore: deliveries_to_be_completed_by_date {
  group_label: "Rentals"
  label: "Deliveries to be Completed by Date"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${deliveries_to_be_completed_by_date.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: rental_location_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_location_assignments.rental_id} = ${deliveries_to_be_completed_by_date.rental_id} and ${rental_location_assignments.end_date} is null ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental_location_assignments.location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: one_to_one
    sql_on: ${states.state_id} = ${locations.state_id} ;;
  }

}

explore: on_rent_report {
  group_label: "Rentals"
  label: "On Rent Report"
  case_sensitive: no
  persist_with: on_rent_update

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${on_rent_report.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${on_rent_report.renting_company_id} = ${companies.company_id} ;;
  }

  join: orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${on_rent_report.order_id} = ${orders.order_id} ;;
  }

  join: jobs {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.job_id} = ${jobs.job_id} and (${jobs.asset_id} = ${on_rent_report.asset_id} OR ${jobs.asset_id} IS NULL);;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.approver_user_id} = ${users.user_id};;
  }
  # Proably Not needed if we can just put days_used and days_unused in On Rent
  # join: asset_utilization_by_day {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${on_rent_report.asset_id} = ${asset_utilization_by_day.asset_id}
  #   and ${on_rent_report.rental_start_date_and_time_date} >= ${asset_utilization_by_day.day}
  #   and ${on_rent_report.scheduled_off_rent_date_and_time_date} <= ${asset_utilization_by_day.day} ;;
  # }

}

explore: on_rent_report_parent_and_child {
  group_label: "Rentals"
  label: "On Rent Report Parent and Child"
  case_sensitive: no
  persist_with: on_rent_update

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${on_rent_report_parent_and_child.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${on_rent_report_parent_and_child.renting_company_id} = ${companies.company_id} ;;
  }

}

explore: rentals_per_po {
  group_label: "Rentals"
  label: "Rentals Per PO"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: remaining_rental_cost {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals_per_po.rental_id}::text = ${remaining_rental_cost.rental_id}::text ;;
  }

  join: line_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.rental_id} = ${remaining_rental_cost.rental_id} ;;
  }

}

explore: rentals_off_rent_report {
  group_label: "Rentals"
  label: "Off Rent Report"
  case_sensitive: no
  #sql_always_where: (${assets.asset_id} in (select asset_id from table(rental_asset_list({{ _user_attributes['user_id'] }}, convert_timezone('UTC','{{ _user_attributes['user_timezone'] }}', current_date::timestamp_ntz), convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', current_date::timestamp_ntz), '{{ _user_attributes['user_timezone'] }}')))
  #  or ${asset_id} is null) ;;
  # persist_for: "10 minutes"

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rentals_off_rent_report.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }
}
