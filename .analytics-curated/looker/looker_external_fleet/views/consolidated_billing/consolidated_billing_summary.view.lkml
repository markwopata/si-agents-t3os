 view: consolidated_billing_summary {
  derived_table: {
    sql: with line_item_start as (
      select
        i.invoice_id
      , i.invoice_no
      , li.asset_id
      , li.rental_id
      , li.line_item_type_id
      , lit.name
      , li.description
      , sum(i.billed_amount) / count(li.line_item_type_id ) as "Total Inv. Amount"
      --, case when li.description ilike '%Tax%' and li.line_item_type_id not in (47, 114) then sum(li.amount) else NULL end as tcco_misc_tax_amount
      , case when li.line_item_type_id in (47, 114) then sum(li.amount) else NULL end as tcco_misc_tax_amount
      , max(i.tax_amount) / count(*) over (partition by i.invoice_id) as "Total Tax Amount"
      , case when li.line_item_type_id in (6, 8, 44, 108, 109) then sum(li.amount) else NULL end as "Rental Amount"
      , case when li.line_item_type_id in (9) then sum(li.amount) else NULL end as "Rental Protection Plan"
      , case when li.line_item_type_id in (5, 117) then sum(li.amount) else NULL end as "Transport"
      , case when li.line_item_type_id in (99, 100, 101, 102, 103, 104, 130, 139, 129, 131, 132) then sum(li.amount) else NULL end as "Fuel"
      , case when li.line_item_type_id in (18, 24, 49, 50, 80, 81, 110, 111, 120, 123, 124, 125, 126, 127, 141, 145, 147, 148, 149, 151, 152, 153) then sum(li.amount) else NULL end as "Sales"
      , case when li.line_item_type_id not in (6, 8, 9, 44, 108, 109, 5, 117, 18, 24, 49, 50, 80, 81, 99, 100, 101, 102, 103, 104, 110, 111, 120, 123, 124, 125, 126, 127, 129, 130, 131, 132, 139, 141, 145, 147, 148, 149, 151, 152, 153, 47, 114) then sum(li.amount) else NULL end as "Misc Charges Amount"
      from
      es_warehouse.public.invoices i
      left join es_warehouse.public.line_items li on li.invoice_id = i.invoice_id
      left join es_warehouse.public.line_item_types lit on lit.line_item_type_id = li.line_item_type_id
      left join es_warehouse.public.rentals r on r.rental_id = li.rental_id
      where
      --invoice_no = 'ABI-5898381-0000' and
      --i.invoice_date >= '2025-12-05' and
      --i.invoice_date < '2026-01-01' and
      (r.rental_status_id is null or r.rental_status_id not in (2, 3, 8)) and
      i.billing_approved = TRUE and
       company_id in
      (SELECT company_id
      FROM BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments
      --where (parent_company_id =  {{ _user_attributes['company_id'] }}::integer
      --or company_id =  {{ _user_attributes['company_id'] }}::integer) )
       where (parent_company_id =  166472::integer
      or company_id =  166472::integer) )
      group by
        i.invoice_id
      , i.invoice_no
      , li.asset_id
      , li.rental_id
      , li.line_item_type_id
      , lit.name
      , li.description
      )
      , invoice_orders as (
      select distinct
        i.invoice_id
      , i.order_id
      , o.company_id
      , o.job_id
      , o.user_id
      , o.purchase_order_id
      , o.sub_renter_id
      from es_warehouse.public.invoices i
      left join es_warehouse.public.orders o on o.order_id = i.order_id
      )
      , invoice_rentals as (
      select distinct
        i.invoice_id
      , r.rental_id
      , r.asset_id
      , r.start_date
      , r.end_date
      , r.price_per_day
      , r.price_per_week
      , r.price_per_month
      , r.quantity
      , r.rental_status_id
      , r.drop_off_delivery_id
      , r.return_delivery_id
      , row_number() over (partition by i.invoice_id order by r.start_date desc nulls last) as rn
      from es_warehouse.public.invoices i
      left join invoice_orders io on io.invoice_id = i.invoice_id
      left join es_warehouse.public.rentals r on r.order_id = io.order_id
      )
      , invoice_purchase_orders as (
      select distinct
        io.invoice_id
      , po.purchase_order_id
      , po.name as po_name
      from invoice_orders io
      left join es_warehouse.public.purchase_orders po on po.purchase_order_id = io.purchase_order_id
      )
      , rental_equipment_assignments as (
      select
        ea.rental_id
      , ea.equipment_assignment_id
      , ea.asset_id
      , row_number() over (partition by ea.rental_id order by ea.equipment_assignment_id desc nulls last) as rn
      from es_warehouse.public.equipment_assignments ea
      )
      , rental_part_assignments as (
      select
        rpa.rental_id
      , rpa.rental_part_assignment_id
      , rpa.part_id
      , row_number() over (partition by rpa.rental_id order by rpa.rental_part_assignment_id desc nulls last) as rn
      from es_warehouse.public.rental_part_assignments rpa
      )

      ------------
---- Manually created rental charges need to be read in the description and classess pulled out by asset_id
---- Rental Spend is the subtotal
--- Credits are listed, but a seperate summary line
----MAF21-6428353-0000
----MAF21-6423169-0000
----MAF21-6344477-0000
----SAO52-6197401-0002
----6409372-000
--- Right now the grouping is description, start_date, end_date, sub contractor, but if the amount if different then they still get different lines

      select
        coalesce(j.name, 'No Job Listed') as "Job #"
      , coalesce(csub.name,'No Sub Renter Listed') as "Sub Renter"
      , csub.company_id as "Sub Renter ID"
      , po.name as "PO #"
      , i.invoice_no as "Invoice #"
      , TO_VARCHAR(CONVERT_TIMEZONE('America/Chicago', i.invoice_date), 'MM/DD/YYYY') as "Date"
      , lis."Total Inv. Amount" as "Original Amount"
      , 0 as "Adjustment Amount"
      , coalesce(lis."Rental Amount", 0) + coalesce(lis."Rental Protection Plan", 0) + coalesce(lis."Transport", 0) + 0 + 0 + coalesce(lis."Fuel", 0) + coalesce(lis."Sales", 0) + coalesce(lis."Misc Charges Amount", 0) + coalesce(lis."Total Tax Amount", 0) + coalesce(lis.tcco_misc_tax_amount, 0) as "Adjusted Amount"

      , case
      when lis."Total Inv. Amount" = 0 then 'Single Bill'
      when i.invoice_date >= coalesce(r.end_date,'2999-12-31') then 'Full Return'
      when lis."Total Inv. Amount" = coalesce(lis."Sales", 0) then 'Single Bill'
      else '4 Week Bill' end as "Invoice Type"

      , coalesce(ai.custom_name,concat('PT-',p.part_type_id),lis.description,lis.name) as "Equipment #"
      , COALESCE(ai.asset_class, pt.description, ai.model, lis.description, lis.name) AS description
      , COALESCE(ai.asset_class, pt.description, ai.model) AS "Equipment Type"
      , c.name as "Customer Name"
      , dl.STREET_1 as "Job Address1"
      , dl.city as "Job City"
      , dls.abbreviation as "Job State"
      , dl.zip_code as "Job ZIP"
      , lis."Rental Amount"
      , lis."Rental Protection Plan" as RPP
      , lis."Transport" as "Transportation Amount"
      , 0 as "Delivery Amount"
      , 0 as "Pickup Amount"
      , lis."Fuel" as "Fuel Amount"
      , lis."Sales" as "Sales Amount"
      , lis.tcco_misc_tax_amount as "State/Emissions Tax Amount"
      , lis."Misc Charges Amount"
      , coalesce(lis."Total Tax Amount", 0) + coalesce(lis.tcco_misc_tax_amount, 0) as "Total Tax Amount"
      , coalesce(r.quantity, 1) as "Quantity"
      , NULL as "Category Number"
      , coalesce(lpad(a.equipment_class_id,5,0),concat('PT-',p.part_type_id)) as "Class Number"
      , ai.serial_number as "Serial #"
      , ai.make as "Make"
      , ai.model as "Model"
      , a.year as "Model Year"
      , r.start_date::date as "Date Rented"
      , r.end_date::date as "Date Returned"
      , i.start_date::date as "Billing Period Start"
      , i.end_date::date as "Billing Period End"
      , r.price_per_day as "Day Rate"
      , r.price_per_week as "Week Rate"
      , r.price_per_month as "4-Week Rate"
      , coalesce(lis."Rental Amount", 0) + coalesce(lis."Rental Protection Plan", 0) + coalesce(lis."Transport", 0) + 0 + 0 + coalesce(lis."Fuel", 0) + coalesce(lis."Sales", 0) + coalesce(lis."Misc Charges Amount", 0) + coalesce(lis."Total Tax Amount", 0) + coalesce(lis.tcco_misc_tax_amount, 0) as "Line-Item Amount"
      , datediff(day, i.start_date, i.end_date) as "Billed Days on Rent"
      , concat(u.first_name, ' ',u.last_name) as "Ordered By"
      , i.company_id
      from
      es_warehouse.public.invoices i
      left join es_warehouse.public.orders o on o.order_id = i.order_id
      left join line_item_start lis on lis.invoice_id = i.invoice_id
      left join es_warehouse.public.rentals r on r.rental_id = lis.rental_id
      left join rental_equipment_assignments rea on rea.rental_id = r.rental_id and rea.rn = 1
      left join business_intelligence.triage.stg_t3__asset_info ai on ai.asset_id = r.asset_id
      left join es_warehouse.public.assets a on a.asset_id = rea.asset_id
      left join es_warehouse.public.users u on u.user_id = o.user_id
      left join es_warehouse.public.sub_renters sb on sb.sub_renter_id = o.sub_renter_id
      left join es_warehouse.public.companies csub on csub.company_id = sb.sub_renter_company_id
      left join es_warehouse.public.companies c on c.company_id = o.company_id
      left join es_warehouse.public.deliveries d on d.delivery_id = r.drop_off_delivery_id
      left join es_warehouse.public.locations dl on dl.location_id = d.location_id
      left join es_warehouse.public.states dls on dls.state_id = dl.state_id
      left join es_warehouse.public.jobs j on j.job_id = o.job_id
      left join rental_part_assignments rpa on rpa.rental_id = r.rental_id and rpa.rn = 1
      left join es_warehouse.inventory.parts p on p.part_id = rpa.part_id
      left join es_warehouse.inventory.part_types pt on pt.part_type_id = p.part_type_id
      left join es_warehouse.public.purchase_orders po on po.purchase_order_id = o.purchase_order_id
      -- left join
      --           (
      --             SELECT rental_id, SUB_RENTER_ID, SUB_RENTER_COMPANY_ID, SUB_RENTING_COMPANY, SUB_RENTING_CONTACT
      --             FROM business_intelligence.triage.stg_t3__company_values
      --           ) cv on r.rental_id = cv.rental_id
      where
      --invoice_no = 'ABI-5898381-0000' and
      --i.invoice_date >= '2025-12-05' and
      --i.invoice_date < '2026-01-01' and
      i.billing_approved = TRUE and
      i.company_id in
      (SELECT company_id
      FROM BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments
     -- where (parent_company_id =  {{ _user_attributes['company_id'] }}::integer
     -- or company_id =  {{ _user_attributes['company_id'] }}::integer))
       where (parent_company_id =  166472::integer
      or company_id =  166472::integer) )
      ;;
  }



  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: job_ {
    type: string
    label: "Job #"
    sql: ${TABLE}."Job #" ;;
  }

  dimension: subrenter {
    type: string
    label: "Sub Renter"
    sql: ${TABLE}."Sub Renter" ;;
  }

  dimension: subrenterid {
    type: string
    label: "Sub Renter ID"
    sql: ${TABLE}."Sub Renter ID" ;;
  }

  dimension: po_ {
    type: string
    label: "PO #"
    sql: ${TABLE}."PO #" ;;
  }

  dimension: invoice_ {
    type: string
    label: "Invoice #"
    sql: ${TABLE}."Invoice #" ;;
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."Date" ;;
  }

  dimension: date_string {
    label: "Date"
    group_label: "Strings"
    type: string
    sql: ${TABLE}."Date" ;;
  }

  dimension: original_amount {
    type: number
    label: "Original Amount"
    sql: ${TABLE}."Original Amount" ;;
  }

  dimension: adjustment_amount {
    type: number
    label: "Adjustment Amount"
    sql: ${TABLE}."Adjustment Amount" ;;
  }

  dimension: adjusted_amount {
    type: number
    label: "Adjusted Amount"
    sql: ${TABLE}."Adjusted Amount" ;;
  }

  measure: adjusted_amount_sum {
    type: sum
    label: "Adjusted Amount"
    sql:${adjusted_amount} ;;
  }


  dimension: invoice_type {
    type: string
    label: "Invoice Type"
    sql: ${TABLE}."Invoice Type" ;;
  }

  dimension: equipment_ {
    type: string
    label: "Equipment #"
    sql: ${TABLE}."Equipment #" ;;
  }

  dimension: description {
    type: string
    label: "Description"
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: equipment_type {
    type: string
    label: "Equipment Type"
    sql: '         ' || ${TABLE}."Equipment Type" ;;
    html: <span style="white-space: pre;">{{ value }}</span> ;;
  }

  dimension: customer_name {
    type: string
    label: "Customer Name"
    sql: ${TABLE}."Customer Name" ;;
  }

  dimension: job_address1 {
    type: string
    label: "Job Address1"
    sql: ${TABLE}."Job Address1" ;;
  }

  dimension: job_city {
    type: string
    label: "Job City"
    sql: ${TABLE}."Job City" ;;
  }

  dimension: job_state {
    type: string
    label: "Job State"
    sql: ${TABLE}."Job State" ;;
  }

  dimension: job_zip {
    type: string
    label: "Job ZIP"
    sql: ${TABLE}."Job ZIP" ;;
  }

  dimension: rental_amount {
    type: number
    label: "Rental Amount"
    sql: ${TABLE}."Rental Amount" ;;
  }

  dimension: rpp {
    label: "RPP"
    type: number
    sql: ${TABLE}."RPP" ;;
  }

  dimension: transportation_amount {
    type: number
    label: "Transportation Amount"
    sql: ${TABLE}."Transportation Amount" ;;
  }

  dimension: delivery_amount {
    type: number
    label: "Delivery Amount"
    sql: ${TABLE}."Delivery Amount" ;;
  }

  dimension: pickup_amount {
    type: number
    label: "Pickup Amount"
    sql: ${TABLE}."Pickup Amount" ;;
  }

  dimension: fuel_amount {
    type: number
    label: "Fuel Amount"
    sql: ${TABLE}."Fuel Amount" ;;
  }

  dimension: sales_amount {
    type: number
    label: "Sales Amount"
    sql: ${TABLE}."Sales Amount" ;;
  }

  dimension: state_emission_tax_amount {
    type: number
    label: "State/Emissions Tax Amount"
    sql: ${TABLE}."State/Emissions Tax Amount" ;;
  }

  dimension: misc_charges_amount {
    type: number
    label: "Misc Charges Amount"
    sql: ${TABLE}."Misc Charges Amount" ;;
  }

  dimension: total_tax_amount {
    type: number
    label: "Total Tax Amount"
    sql: ${TABLE}."Total Tax Amount" ;;
  }

# --- RPP Measure ---
  measure: rpp_sum {
    type: sum
    label: "RPP"
    sql: ${rpp} ;;
  }

  # --- Aggregated Measures ---
  measure: transportation_amount_sum {
    type: sum
    label: "Transportation Amount"
    sql: ${transportation_amount} ;;
  }

  measure: rental_amount_sum {
    type: sum
    label: "Rental Amount"
    sql: ${rental_amount} ;;
  }

  measure: delivery_amount_sum {
    type: sum
    label: "Delivery Amount"
    sql: ${delivery_amount} ;;
  }

  measure: pickup_amount_sum {
    type: sum
    label: "Pickup Amount"
    sql: ${pickup_amount} ;;
  }

  measure: fuel_amount_sum {
    type: sum
    label: "Fuel Amount"
    sql: ${fuel_amount} ;;
  }

  measure: sales_amount_sum {
    type: sum
    label: "Sales Amount"
    sql: ${sales_amount} ;;
  }

  measure: state_emission_tax_amount_sum {
    type: sum
    label: "State/Emissions Tax Amount"
    sql: ${state_emission_tax_amount} ;;
  }

  measure: misc_charges_amount_sum {
    type: sum
    label: "Misc Charges Amount"
    sql: ${misc_charges_amount} ;;
  }

  measure: total_tax_amount_sum {
    type: sum
    label: "Total Tax Amount"
    sql: ${total_tax_amount} ;;
  }

  measure: lineitem_amount_sum {
    type: sum
    label: "Line-Item Amount"
    sql: ${lineitem_amount} ;;
  }


  dimension: quantity {
    type: number
    sql: ${TABLE}."Quantity" ;;
  }

  dimension: category_number {
    type: number
    label: "Category Number"
    sql: ${TABLE}."Category Number" ;;
  }

  dimension: class_number {
    type: string
    label: "Class Number"
    sql: ${TABLE}."Class Number" ;;
  }

  dimension: serial_ {
    type: string
    label: "Serial #"
    sql: ${TABLE}."Serial #" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."Make" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."Model" ;;
  }

  dimension: model_year {
    type: number
    label: "Model Year"
    sql: ${TABLE}."Model Year" ;;
  }

  dimension: date_rented {
    type: date
    label: "Date Rented"
    sql: ${TABLE}."Date Rented" ;;
  }

  dimension: date_returned {
    type: date
    label: "Date Returned"
    sql: ${TABLE}."Date Returned" ;;
  }

  dimension: billing_period_start {
    type: date
    label: "Billing Period Start"
    sql: ${TABLE}."Billing Period Start" ;;
  }

  dimension: billing_period_end {
    type: date
    label: "Billing Period End"
    sql: ${TABLE}."Billing Period End" ;;
  }

  dimension: day_rate {
    type: number
    label: "Day Rate"
    sql: ${TABLE}."Day Rate" ;;
  }

  dimension: week_rate {
    type: number
    label: "Week Rate"
    sql: ${TABLE}."Week Rate" ;;
  }

  dimension: 4week_rate {
    type: number
    label: "4-Week Rate"
    sql: ${TABLE}."4-Week Rate" ;;
  }

  dimension: lineitem_amount {
    type: number
    label: "Line-Item Amount"
    sql: ${TABLE}."Line-Item Amount" ;;
  }

  dimension: billed_days_on_rent {
    type: number
    label: "Billed Days on Rent"
    sql: ${TABLE}."Billed Days on Rent" ;;
  }

  dimension: ordered_by {
    type: string
    label: "Ordered By"
    sql: ${TABLE}."Ordered By" ;;
  }

  set: detail {
    fields: [
      job_,
      po_,
      invoice_,
      original_amount,
      adjustment_amount,
      adjusted_amount,
      invoice_type,
      equipment_,
      equipment_type,
      customer_name,
      job_address1,
      job_city,
      job_state,
      job_zip,
      rental_amount,
      rpp,
      transportation_amount,
      delivery_amount,
      pickup_amount,
      fuel_amount,
      sales_amount,
      misc_charges_amount,
      total_tax_amount,
      quantity,
      category_number,
      class_number,
      serial_,
      make,
      model,
      model_year,
      date_rented,
      date_returned,
      day_rate,
      week_rate,
      4week_rate,
      lineitem_amount,
      billed_days_on_rent,
      ordered_by
    ]
  }
}
