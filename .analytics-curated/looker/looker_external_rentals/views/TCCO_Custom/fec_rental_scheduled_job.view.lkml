view: fec_rental_scheduled_job {
  derived_table: {
    sql: {% raw %} with line_item_start as (
      select
        i.invoice_id
      , i.invoice_no
      , li.asset_id
      , li.rental_id
      , li.line_item_type_id
      , lit.name
      , sum(i.billed_amount) / count(li.line_item_type_id ) as "Total Inv. Amount"
      --, case when li.description ilike '%Tax%' and li.line_item_type_id not in (47, 114) then sum(li.amount) else NULL end as tcco_misc_tax_amount
      , case when li.line_item_type_id in (47, 114) then sum(li.amount) else NULL end as tcco_misc_tax_amount
      , max(i.tax_amount) / count(*) over (partition by i.invoice_id) as "Total Tax Amount"
      , case when li.line_item_type_id in (6, 8, 44, 108, 109) then sum(li.amount) else NULL end as "Rental Amount"
      , case when li.line_item_type_id in (9) then sum(li.amount) else NULL end as "Rental Protection Plan"
      , case when li.line_item_type_id in (5, 117) then sum(li.amount) else NULL end as "Transport"
      , case when li.line_item_type_id in (99, 100, 101, 102, 103, 104, 130, 139, 129, 131, 132) then sum(li.amount) else NULL end as "Fuel"
      , case when li.line_item_type_id not in (6, 8, 9, 44, 108, 109, 5, 117, 99, 100, 101, 102, 103, 104, 130, 139, 129, 131, 132, 47, 114) then sum(li.amount) else NULL end as "Misc Charges Amount"
      from
      es_warehouse.public.invoices i
      left join es_warehouse.public.line_items li on li.invoice_id = i.invoice_id
      left join es_warehouse.public.line_item_types lit on lit.line_item_type_id = li.line_item_type_id
      left join es_warehouse.public.rentals r on r.rental_id = li.rental_id
      where
      (r.rental_status_id is null or r.rental_status_id not in (2, 3, 8)) and
      i.billing_approved = TRUE and
      i.company_id in
      (SELECT company_id
      FROM BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments
      where (parent_company_id =  18395::integer
      or company_id =  18395::integer) )
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
      , line_item_aggregated as (
      select
        invoice_id
      , invoice_no
      , asset_id
      , rental_id
      , sum("Total Inv. Amount") as "Total Inv. Amount"
      , sum(tcco_misc_tax_amount) as tcco_misc_tax_amount
      , sum("Total Tax Amount") as "Total Tax Amount"
      , sum("Rental Amount") as "Rental Amount"
      , sum("Rental Protection Plan") as "Rental Protection Plan"
      , sum("Transport") as "Transport"
      , sum("Fuel") as "Fuel"
      , sum("Misc Charges Amount") as "Misc Charges Amount"
      from line_item_start
      group by invoice_id, invoice_no, asset_id, rental_id
      )
      , equipment_aggregated as (
      select
        lis.invoice_id
      , lis.invoice_no
      , lis.asset_id
      , max(lis.rental_id) as rental_id
      , sum(lis."Total Inv. Amount") as "Total Inv. Amount"
      , sum(lis.tcco_misc_tax_amount) as tcco_misc_tax_amount
      , sum(lis."Total Tax Amount") as "Total Tax Amount"
      , sum(lis."Rental Amount") as "Rental Amount"
      , sum(lis."Rental Protection Plan") as "Rental Protection Plan"
      , sum(lis."Transport") as "Transport"
      , sum(lis."Fuel") as "Fuel"
      , sum(lis."Misc Charges Amount") as "Misc Charges Amount"
      from line_item_aggregated lis
      group by lis.invoice_id, lis.invoice_no, lis.asset_id
      )
      , asset_last_service_date as (
      select
        wo.asset_id
      , max(wo.date_completed) as last_service_date
      from es_warehouse.work_orders.work_orders wo
      where wo.date_completed is not null
      group by wo.asset_id
      )

      ------------
--- sub category (es_Warehouse.public.categories) ...needs the join... for equipmentcatrogry

, final_data as (
select
  o.order_id as order_id
, r.rental_id
, c.company_id as company_id
, TRIM(COALESCE(NULLIF(REGEXP_SUBSTR(c.name, '-(.*)', 1, 1, 'e'), ''), c.name)) as ACCOUNTNAME
, (TRIM(COALESCE(NULLIF(TRIM(SPLIT_PART(c.name, ' - ', 2)), ''), c.name)) ILIKE '%project%'
   OR TRIM(COALESCE(NULLIF(TRIM(SPLIT_PART(c.name, ' - ', 2)), ''), c.name)) ILIKE '%10x Onsite%') as OERP
, coalesce(csub.name,
--, l.nickname
 'No Sub Renter Listed') as JOBNAME
, l.nickname as JOBSITENAME
, o.sub_renter_id as sub_renter_id
, o.job_id as job_id
, COALESCE(ai.asset_class, pt.description, ai.model) AS EQPDESCRIPTION
, ai.make as EQUIPMENTMAKE
, ai.model as EQUIPMENTMODEL
, coalesce(r.quantity, 1) as QUANTITY
, r.start_date::date as DATEOUT
, TO_VARCHAR(CONVERT_TIMEZONE('America/Chicago', i.invoice_date), 'MM/DD/YYYY') as LASTBILLEDDATE
, datediff(day, r.start_date, current_date()) as "Days on Rent"
, r.price_per_day as DAILYRATE
, r.price_per_week as WEEKLYRATE
, r.price_per_month as MONTHLYRATE
, coalesce(lis."Rental Amount", 0) + coalesce(lis."Rental Protection Plan", 0) + coalesce(lis."Transport", 0) + 0 + 0 + coalesce(lis."Fuel", 0) + 0 + coalesce(lis."Misc Charges Amount", 0) + coalesce(lis."Total Tax Amount", 0) + coalesce(lis.tcco_misc_tax_amount, 0) as TOTALAMOUNTBILLED
, r.rental_id as CONTRACTNUMBER
, coalesce(ai.custom_name,'Bulk Item') as EQUIPMENTNUMBER
, ai.serial_number as EQUIPMENTSERIALNUM
, lpad(a.equipment_class_id,5,0) as EQUIPMENTCLASS
--, coalesce(cat.name, case when ast.name is not null then null else 'Bulk Items' end) as EQUIPMENTSUBCATEGORY
--, coalesce(cp2.name, case when ast.name is not null then null else 'Bulk Items' end) as EQUIPMENTCATEGORY
, SUBCAT.name as EQUIPMENTSUBCATEGORY
, PARENTCAT.name as EQUIPMENTCATEGORY
, po.name as PURCHASEORDERNUMBER
, o.company_id as ACCOUNTNUMBER
, dls.abbreviation as ACCOUNTSTATE
, concat(u.first_name, ' ',u.last_name) as ORDEREDBY
, alsd.last_service_date::date as LASTSERVICEDATE
, row_number() over (partition by i.invoice_no, COALESCE(ai.asset_class, pt.description, ai.model) order by coalesce(lis."Rental Amount", 0) + coalesce(lis."Rental Protection Plan", 0) + coalesce(lis."Transport", 0) + 0 + 0 + coalesce(lis."Fuel", 0) + 0 + coalesce(lis."Misc Charges Amount", 0) + coalesce(lis."Total Tax Amount", 0) + coalesce(lis.tcco_misc_tax_amount, 0) desc) as rn
from
es_warehouse.public.rentals r
left join es_warehouse.public.orders o on o.order_id = r.order_id
left join equipment_aggregated lis on lis.rental_id = r.rental_id
left join es_warehouse.public.invoices i on i.invoice_id = lis.invoice_id
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
left join asset_last_service_date alsd on alsd.asset_id = r.asset_id and alsd.last_service_date >= r.start_date
left join es_warehouse.public.rental_location_assignments rla on rla.rental_id = r.rental_id and (rla.end_date >= current_timestamp OR rla.end_date is null)
left join es_warehouse.public.locations l on l.location_id = rla.location_id
left join es_warehouse.public.equipment_models em on em.equipment_model_id = a.equipment_model_id
left join es_warehouse.public.equipment_classes_models_xref emx on emx.equipment_model_id = em.equipment_model_id
left join es_warehouse.public.equipment_classes ec on ec.equipment_class_id = emx.equipment_class_id
LEFT JOIN ES_WAREHOUSE.PUBLIC.CATEGORIES SUBCAT ON EC.CATEGORY_ID = SUBCAT.CATEGORY_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.CATEGORIES PARENTCAT ON SUBCAT.PARENT_CATEGORY_ID = PARENTCAT.CATEGORY_ID
----
-- left join
--           (
--             SELECT rental_id, SUB_RENTER_ID, SUB_RENTER_COMPANY_ID, SUB_RENTING_COMPANY, SUB_RENTING_CONTACT
--             FROM business_intelligence.triage.stg_t3__company_values
--           ) cv on r.rental_id = cv.rental_id
where
--r.start_date >= DATEADD(day, -7, CURRENT_DATE())
--and r.start_date < CURRENT_DATE()
r.rental_status_id = 5
--and i.billing_approved = TRUE
and o.company_id in
(SELECT company_id
FROM BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments
where (parent_company_id =  18395::integer
or company_id =  18395::integer) )
)
select
  order_id
, rental_id
, ACCOUNTNAME
, OERP
, JOBNAME
, JOBSITENAME
, sub_renter_id
, EQPDESCRIPTION
, EQUIPMENTMAKE
, EQUIPMENTMODEL
, QUANTITY
, DATEOUT
, LASTBILLEDDATE
, "Days on Rent"
, DAILYRATE
, WEEKLYRATE
, MONTHLYRATE
, TOTALAMOUNTBILLED
, CONTRACTNUMBER
, EQUIPMENTNUMBER
, EQUIPMENTSERIALNUM
, EQUIPMENTCLASS
, EQUIPMENTCATEGORY
, EQUIPMENTSUBCATEGORY
, PURCHASEORDERNUMBER
, ACCOUNTNUMBER
, ACCOUNTSTATE
, ORDEREDBY
, LASTSERVICEDATE
from final_data
where rn = 1
and EQPDESCRIPTION is not null
       {% endraw %} ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: accountname {
    type: string
    sql: ${TABLE}."ACCOUNTNAME" ;;
  }

  dimension: jobname {
    type: string
    sql: ${TABLE}."JOBNAME" ;;
  }

  dimension: jobsitename {
    type: string
    sql: ${TABLE}."JOBSITENAME" ;;
  }

  dimension: eqpdescription {
    type: string
    sql: ${TABLE}."EQPDESCRIPTION" ;;
  }

  dimension: equipmentmake {
    type: string
    sql: ${TABLE}."EQUIPMENTMAKE" ;;
  }

  dimension: equipmentmodel {
    type: string
    sql: ${TABLE}."EQUIPMENTMODEL" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: dateout {
    type: date
    sql: ${TABLE}."DATEOUT" ;;
  }

  dimension: lastbilleddate {
    type: string
    sql: ${TABLE}."LASTBILLEDDATE" ;;
  }

  dimension: days_on_rent {
    type: number
    label: "Days on Rent"
    sql: ${TABLE}."Days on Rent" ;;
  }

  dimension: dailyrate {
    type: number
    sql: ${TABLE}."DAILYRATE" ;;
  }

  dimension: weeklyrate {
    type: number
    sql: ${TABLE}."WEEKLYRATE" ;;
  }

  dimension: monthlyrate {
    type: number
    sql: ${TABLE}."MONTHLYRATE" ;;
  }

  dimension: totalamountbilled {
    type: number
    sql: ${TABLE}."TOTALAMOUNTBILLED" ;;
  }

  dimension: contractnumber {
    type: string
    sql: ${TABLE}."CONTRACTNUMBER" ;;
  }

  dimension: equipmentnumber {
    type: string
    sql: ${TABLE}."EQUIPMENTNUMBER" ;;
  }

  dimension: equipmentserialnum {
    type: string
    sql: ${TABLE}."EQUIPMENTSERIALNUM" ;;
  }

  dimension: equipmentclass {
    type: string
    sql: ${TABLE}."EQUIPMENTCLASS" ;;
  }

  dimension: equipmentcategory {
    type: string
    sql: ${TABLE}."EQUIPMENTCATEGORY" ;;
  }

  dimension: equipmentsubcategory {
    type: string
    sql: ${TABLE}."EQUIPMENTSUBCATEGORY" ;;
  }

  dimension: purchaseordernumber {
    type: string
    sql: ${TABLE}."PURCHASEORDERNUMBER" ;;
  }

  dimension: accountnumber {
    type: string
    sql: ${TABLE}."ACCOUNTNUMBER" ;;
  }

  dimension: accountstate {
    type: string
    sql: ${TABLE}."ACCOUNTSTATE" ;;
  }

  dimension: orderedby {
    type: string
    sql: ${TABLE}."ORDEREDBY" ;;
  }

  dimension: lastservicedate {
    type: date
    sql: ${TABLE}."LASTSERVICEDATE" ;;
  }

  dimension: OERP {
    type: string
    sql: ${TABLE}."OERP" ;;
  }

  set: detail {
    fields: [
      accountname,
      jobname,
      eqpdescription,
      equipmentmake,
      equipmentmodel,
      quantity,
      dateout,
      lastbilleddate,
      days_on_rent,
      dailyrate,
      weeklyrate,
      monthlyrate,
      totalamountbilled,
      contractnumber,
      equipmentnumber,
      equipmentserialnum,
      equipmentclass,
      equipmentcategory,
      purchaseordernumber,
      accountnumber,
      accountstate,
      orderedby,
      lastservicedate
    ]
  }
}
