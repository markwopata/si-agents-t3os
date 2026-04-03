view: telsa_on_rent_report {
  derived_table: {
    sql: SELECT
          '179084' as "Supplier Code",
          'EquipmentShare' as "Supplier",
          r.rental_id as "Rental Contract Number",
          a.asset_id as "Supplier Unit/Equipment ID",
          a.serial_number as "Serial Number",
          coalesce(a.make,'Bulk Item') as "Unit Make",
          coalesce(a.model::text, p.part_id::text) as "Unit Model",
          coalesce(concat(cat.name,'/',a.asset_class), pt.description) as "Unit Description",
          po.name as "Current PO Number",
          concat(dl.street_1,' ',ifnull(dl.street_2,' ')) as "Delivery Street",
          dl.city as "Delivery City",
          s.abbreviation as "Delivery State",
          dl.zip_code as "Delivery Zip",
          r.start_date::date as "Rental Contract Start Date",
          r.end_date::date as "Rental Contract End Date",
          r.end_date::date as "Estimated Return Date",
          ' ' as "Actual Returned Date",
          ac.last_cycle_inv_date::date as "Last Invoice Date",
          ac.next_cycle_inv_date::date as "Next Bill Cycle/Date",
          r.price_per_day as "Daily Rate",
          r.price_per_week as "Weekly Rate",
          r.price_per_month as "28-day Rate",
          r.price_per_month as "Actual Bill Rate",
          '28-day' as "Current Billing Cycle",
          '' as "Overtime Rate",
          'Eligble' as "Eligible for Overtime",
          ' ' as "Geolocation",
          h.hours as "Count of Operating Hours",
          datediff(months,date_from_parts(a.year,1,1),current_date) as "Equipment Age"
      from
          rentals r
          left join equipment_assignments ea on r.rental_id = ea.rental_id
          left join assets a on a.asset_id = ea.asset_id
          left join rental_part_assignments rpa on rpa.rental_id = r.rental_id
          left join inventory.parts p on p.part_id = rpa.part_id
          left join inventory.part_types pt on pt.part_type_id = p.part_type_id
          left join admin_cycle ac on ac.rental_id = r.rental_id and ac.asset_id = ea.asset_id
          left join orders o on r.order_id = o.order_id
          left join purchase_orders po on po.purchase_order_id = o.purchase_order_id
          left join users u on u.user_id = o.user_id
          join companies c on c.company_id = u.company_id
          left join deliveries d on d.delivery_id = r.drop_off_delivery_id
          left join locations dl on dl.location_id = d.location_id
          left join states s on s.state_id = dl.state_id
          left join deliveries dr on dr.delivery_id = r.return_delivery_id
          left join categories cat on cat.category_id = a.category_id
          left join (select asset_id, round(value,1) as hours from asset_status_key_values where name = 'hours') h on h.asset_id = r.asset_id
      where
          po.company_id = 38082
          AND c.company_id = 38082
          AND (
          (r.rental_status_id = 5 AND (ea.end_date >= current_timestamp() or ea.end_date is null))
          OR (ea.end_date >= current_timestamp AND ea.start_date <= current_timestamp)
          OR r.rental_status_id = 5 AND r.asset_id is null
          )
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: supplier_code {
    type: string
    label: "Supplier Code"
    sql: ${TABLE}."Supplier Code" ;;
  }

  dimension: supplier {
    type: string
    sql: ${TABLE}."Supplier" ;;
  }

  dimension: rental_contract_number {
    type: number
    label: "Rental Contract Number"
    sql: ${TABLE}."Rental Contract Number" ;;
    value_format_name: id
  }

  dimension: supplier_unitequipment_id {
    type: number
    label: "Supplier Unit/Equipment ID"
    sql: ${TABLE}."Supplier Unit/Equipment ID" ;;
    value_format_name: id
  }

  dimension: serial_number {
    type: string
    label: "Serial Number"
    sql: ${TABLE}."Serial Number" ;;
  }

  dimension: unit_make {
    type: string
    label: "Unit Make"
    sql: ${TABLE}."Unit Make" ;;
  }

  dimension: unit_model {
    type: string
    label: "Unit Model"
    sql: ${TABLE}."Unit Model" ;;
  }

  dimension: unit_description {
    type: string
    label: "Unit Description"
    sql: ${TABLE}."Unit Description" ;;
  }

  dimension: current_po_number {
    type: string
    label: "Current PO Number"
    sql: ${TABLE}."Current PO Number" ;;
  }

  dimension: delivery_street {
    type: string
    label: "Delivery Street"
    sql: ${TABLE}."Delivery Street" ;;
  }

  dimension: delivery_city {
    type: string
    label: "Delivery City"
    sql: ${TABLE}."Delivery City" ;;
  }

  dimension: delivery_state {
    type: string
    label: "Delivery State"
    sql: ${TABLE}."Delivery State" ;;
  }

  dimension: delivery_zip {
    type: number
    label: "Delivery Zip"
    sql: ${TABLE}."Delivery Zip" ;;
    value_format_name: id
  }

  dimension: rental_contract_start_date {
    type: date
    label: "Rental Contract Start Date"
    sql: ${TABLE}."Rental Contract Start Date" ;;
  }

  dimension: rental_contract_end_date {
    type: date
    label: "Rental Contract End Date"
    sql: ${TABLE}."Rental Contract End Date" ;;
  }

  dimension: estimated_return_date {
    type: date
    label: "Estimated Return Date"
    sql: ${TABLE}."Estimated Return Date" ;;
  }

  dimension: actual_returned_date {
    type: string
    label: "Actual Returned Date"
    sql: ${TABLE}."Actual Returned Date" ;;
  }

  dimension: last_invoice_date {
    type: date
    label: "Last Invoice Date"
    sql: ${TABLE}."Last Invoice Date" ;;
  }

  dimension: next_bill_cycledate {
    type: date
    label: "Next Bill Cycle/Date"
    sql: ${TABLE}."Next Bill Cycle/Date" ;;
  }

  dimension: daily_rate {
    type: number
    label: "Daily Rate"
    sql: ${TABLE}."Daily Rate" ;;
    value_format_name: usd_0
  }

  dimension: weekly_rate {
    type: number
    label: "Weekly Rate"
    sql: ${TABLE}."Weekly Rate" ;;
    value_format_name: usd_0
  }

  dimension: 28day_rate {
    type: number
    label: "28-day Rate"
    sql: ${TABLE}."28-day Rate" ;;
    value_format_name: usd_0
  }

  dimension: actual_bill_rate {
    type: number
    label: "Actual Bill Rate"
    sql: ${TABLE}."Actual Bill Rate" ;;
    value_format_name: usd_0
  }

  dimension: current_billing_cycle {
    type: string
    label: "Current Billing Cycle"
    sql: ${TABLE}."Current Billing Cycle" ;;
  }

  dimension: overtime_rate {
    type: string
    label: "Overtime Rate"
    sql: ${TABLE}."Overtime Rate" ;;
  }

  dimension: eligible_for_overtime {
    type: string
    label: "Eligible for Overtime"
    sql: ${TABLE}."Eligible for Overtime" ;;
  }

  dimension: geolocation {
    type: string
    sql: ${TABLE}."Geolocation" ;;
  }

  dimension: operating_hours {
    type: string
    sql: ${TABLE}."Count of Operating Hours" ;;
  }

  dimension: equipment_age {
    label: "Equipment Age (months)"
    type: string
    sql: ${TABLE}."Equipment Age" ;;
  }


  set: detail {
    fields: [
      supplier_code,
      supplier,
      rental_contract_number,
      supplier_unitequipment_id,
      serial_number,
      unit_make,
      unit_model,
      unit_description,
      current_po_number,
      delivery_street,
      delivery_city,
      delivery_state,
      delivery_zip,
      rental_contract_start_date,
      rental_contract_end_date,
      estimated_return_date,
      actual_returned_date,
      last_invoice_date,
      next_bill_cycledate,
      daily_rate,
      weekly_rate,
      28day_rate,
      actual_bill_rate,
      current_billing_cycle,
      overtime_rate,
      eligible_for_overtime,
      geolocation
    ]
  }
}
