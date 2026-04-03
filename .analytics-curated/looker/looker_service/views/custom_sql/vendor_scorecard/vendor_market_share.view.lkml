view: vendor_market_share {
  derived_table: {
    sql:
/*README
Last Edited: February 24, 2026
The purpose of this code is to calculate a single number that represents our financial relationship with a given Vendor, both individually and relative to their peers. It is split into four sections. Each of the four sections can be evaluated individually or in conjunction with the other three.

The resulting table is unique at the Date, Vendor, Vendor Type, Part Subcategory, Part Container, and Gl Account level
    - Part Subcategory/Container & GL Account are mutually exclusive

Sections/Variables:
    - OEM Part Usage on OEM Assets (Part Subcategory - Container Level)
        - What percent of parts put on an OEM's assets were manufactured by the OEM?
        - Numerator = $/Units of parts from the asset's OEM put on a work order
        - Denominator = Total $/Units put on that OEM's assets
    - OEM Manufactured Part Reception (Part Subcategory - Container Level)
        - What percent of OEM parts were bought directly from that OEM?
        - Numerator = $/Units of parts bought from the OEM
        - Denominator = Total $/Units of that OEM's parts bought
    - Vendor's Share of Spend with Part Subcategories and Containers (Part Subcategory - Container Level of Detail) - Green
        - What percent of ES spend on parts within subcategory X was with this Vendor?
        - Numerator = Spend on Parts with Vendor
        - Denominator = Total Spend on Parts within the same categorization
    - ES Vendor Spend within Shared Vendor Type Group (GL Account)
        - What percent of ES spend with this Vendor's Type was with this Vendor?
        - Numerator = Spend with the Vendor
        - Denominator = Aggregate Spend with every Vendor of the same Vendor Type
        - 2024 forward

Market Share is then calculated by summing the numerators and denominators and then dividing the sum of the numerators by the sum of the denominators.
*/
-- Part OEM based variables
with vendor_subcat_spend_prep as (
    select tvm.vendorid
        , tvm.vendor_type
        , por.date_received::DATE as reference_date -- Standardizing for union and aggregation
        , pcs.subcategory as subcategory
        , coalesce(pcs.part_containers, 'No Container Assigned') as container
        , sum((pori.accepted_quantity * poli.price_per_unit)) as vendor_subcat_cont_spend
    from PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
    join PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS poli
        on poli.purchase_order_id = po.purchase_order_id
            and poli.date_archived is null
    join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS pori
        on pori.purchase_order_line_item_id = poli.purchase_order_line_item_id
            and pori.date_archived is null
    join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVERS por
        on por.purchase_order_receiver_id = pori.purchase_order_receiver_id
            and por.date_received is not null
    JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs
        ON PO.VENDOR_ID = evs.ENTITY_ID
    JOIN ANALYTICS.INTACCT.VENDOR v -- Who we bought from
        ON evs.EXTERNAL_ERP_VENDOR_REF = v.VENDORID
    left join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm -- Mapped name of who we bought from
        on tvm.vendorid = v.vendorid
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm -- ES PO's only
        on dm.market_id = po.requesting_branch_id
            and dm.reporting_market -- BE Markets
    join FLEET_OPTIMIZATION.GOLD.DIM_PARTS_FLEET_OPT dp
        on dp.item_id = poli.item_id
            and dp.part_reporting_category = 'none' -- Not telematics, bulk etc
    join "ANALYTICS"."PARTS_INVENTORY"."PARTS_ATTRIBUTES" pa
        on pa.part_id = dp.part_id
            and pa.END_DATE::date = '2999-01-01' -- Current
            and pa.part_categorization_id is not null -- Been Categorized
    join ANALYTICS.PARTS_INVENTORY.PART_CATEGORIZATION_STRUCTURE pcs
        on pcs.part_categorization_id = pa.part_categorization_id
    where year(por.date_received::DATE) >= 2025
    group by all
)

, es_subcat_spend as (
    select reference_date
        , subcategory
        , container
        , sum(vendor_subcat_cont_spend) as es_subcat_cont_spend
    from vendor_subcat_spend_prep
    group by 1,2,3
)

, part_share as (
    -- OEM Part Usage on OEM Assets (Part Subcategory - Container Level)
    select v.vendorid
        , v.vendor_type
        , wo.work_order_completed_date::DATE as reference_date -- Standardizing for union and aggregation
        , coalesce(pcs.subcategory, 'No Subcategory Assigned') as subcategory -- Do not want these to be null because these being null is what tells us we are looking at an AP Detail (3rd metric) based line
        , coalesce(pcs.part_containers, 'No Container Assigned') as container -- Do not want these to be null because these being null is what tells us we are looking at an AP Detail (3rd metric) based line
        , sum(iff(upper(dp.part_provider_name) = upper(da.asset_equipment_make), wol.work_order_line_number_of_units, 0)) as oem_parts_used -- numerator - sum if the part OEM is the asset's OEM
        , sum(iff(upper(dp.part_provider_name) = upper(da.asset_equipment_make), wol.work_order_line_amount, 0)) as oem_parts_used_cost -- numerator - sum if the part OEM is the asset's OEM
        , sum(wol.work_order_line_number_of_units) as parts_used -- denominator
        , sum(wol.work_order_line_amount) as parts_used_cost
        , 0 as oem_parts_received -- 0'd for union and sum
        , 0 as oem_parts_received_cost
        , 0 as parts_received
        , 0 as parts_received_cost
        , 0 as vendor_subcat_cont_spend
    from FLEET_OPTIMIZATION.GOLD.DIM_WORK_ORDERS_FLEET_OPT wo
    join PLATFORM.GOLD.FACT_WORK_ORDER_LINES wol
        on wol.work_order_line_work_order_key = wo.work_order_key
            and wol.work_order_line_type ilike 'Parts'
    join FLEET_OPTIMIZATION.GOLD.DIM_PARTS_FLEET_OPT dp
        on dp.part_key = wol.work_order_line_part_key
            and dp.part_reporting_category = 'none' -- No telematics, bulk, etc
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm -- ES Work Orders
        on dm.market_key = wo.work_order_market_key
            and dm.reporting_market -- BE markets
    join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT da
        on da.asset_key = wo.work_order_asset_key
    join ( -- Only care about vendors mapped to an OEM/Part Provider. Primary vendor only to avoid duplication
            select vendorid
                , coalesce(vendor_type, 'No Type Assigned') as vendor_type
                , iff(mapped_vendor_name <> 'Doosan / Bobcat', mapped_vendor_name, 'DOOSAN') as join1
                , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
            from "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
            where primary_vendor ilike 'yes' and mapped_vendor_name is not null
            ) v
        on upper(join1) = da.asset_equipment_make or upper(join2) = da.asset_equipment_make
    left join "ANALYTICS"."PARTS_INVENTORY"."PARTS_ATTRIBUTES" pa
        on pa.part_id = dp.part_id
            and pa.END_DATE::date = '2999-01-01' -- Current
            and pa.part_categorization_id is not null -- Has been categorized
    left join ANALYTICS.PARTS_INVENTORY.PART_CATEGORIZATION_STRUCTURE pcs
        on pcs.part_categorization_id = pa.part_categorization_id
    where wo.work_order_date_archived = '0001-01-01'
        and wo.work_order_status_name not ilike 'open' -- Billed or closed
    group by all

union all

    -- OEM Manufactured Part Reception (Part Subcategory - Container Level)
    select part_mapped_name.vendorid -- Who we bought the part from
        , part_mapped_name.vendor_type
        , por.date_received::DATE as reference_date -- Standardizing for union and aggregation
        , coalesce(pcs.subcategory, 'No Subcategory Assigned') as subcategory -- Do not want these to be null because these being null is what tells us we are looking at an AP Detail (3rd metric) based line
        , coalesce(pcs.part_containers, 'No Container Assigned') as container
        , 0 as oem_parts_used -- 0'd for union and sum
        , 0 as oem_parts_used_cost
        , 0 as parts_used
        , 0 as parts_used_cost
        , sum(iff(part_mapped_name.mapped_vendor_name = pv.mapped_vendor_name, pori.accepted_quantity, 0)) as oem_parts_received -- numerator - sum if the vendor we bought from is under the same mapped name as the part's provider
        , sum(iff(part_mapped_name.mapped_vendor_name = pv.mapped_vendor_name, (pori.accepted_quantity * poli.price_per_unit), 0)) oem_parts_received_cost
        , sum(pori.accepted_quantity) as parts_received -- denominator
        , sum((pori.accepted_quantity * poli.price_per_unit)) as parts_received_cost
        , 0 as vendor_subcat_cont_spend
    from PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
    join PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS poli
        on poli.purchase_order_id = po.purchase_order_id
            and poli.date_archived is null
    join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS pori
        on pori.purchase_order_line_item_id = poli.purchase_order_line_item_id
            and pori.date_archived is null
    join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVERS por
        on por.purchase_order_receiver_id = pori.purchase_order_receiver_id
            and por.date_received is not null
    JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs
        ON PO.VENDOR_ID = evs.ENTITY_ID
    JOIN ANALYTICS.INTACCT.VENDOR v -- Who we bought from
        ON evs.EXTERNAL_ERP_VENDOR_REF = v.VENDORID
    join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm -- Mapped name of who we bought from
        on tvm.vendorid = v.vendorid
            and mapped_vendor_name is not null
    left join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING pv -- primary vendor ID of that mapped name we bought from
        on pv.mapped_vendor_name = tvm.mapped_vendor_name
            and pv.primary_vendor ilike 'yes'
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm -- ES PO's only
        on dm.market_id = po.requesting_branch_id
            and dm.reporting_market -- BE Markets
    join FLEET_OPTIMIZATION.GOLD.DIM_PARTS_FLEET_OPT dp
        on dp.item_id = poli.item_id
            and dp.part_reporting_category = 'none' -- Not telematics, bulk etc
    left join ( -- The vendor who made the part
            select vendorid
                , coalesce(vendor_type, 'No Type Assigned') as vendor_type
                , mapped_vendor_name
                , iff(mapped_vendor_name <> 'Doosan / Bobcat', mapped_vendor_name, 'DOOSAN') as join1
                , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
            from "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
            where primary_vendor ilike 'yes' and mapped_vendor_name is not null
            ) part_mapped_name
        on upper(join1) = upper(dp.part_provider_name)  or upper(join2) = upper(dp.part_provider_name)
    left join "ANALYTICS"."PARTS_INVENTORY"."PARTS_ATTRIBUTES" pa
        on pa.part_id = dp.part_id
            and pa.END_DATE::date = '2999-01-01' -- Current
            and pa.part_categorization_id is not null -- Been Categorized
    left join ANALYTICS.PARTS_INVENTORY.PART_CATEGORIZATION_STRUCTURE pcs
        on pcs.part_categorization_id = pa.part_categorization_id
    where po.date_archived is null
    group by all

union all

    select vssp.vendorid -- Who we bought the part from
        , vssp.vendor_type
        , vssp.reference_date -- Standardizing for union and aggregation
        , vssp.subcategory
        , vssp.container
        , 0 as oem_parts_used -- 0'd for union and sum
        , 0 as oem_parts_used_cost
        , 0 as parts_used
        , 0 as parts_used_cost
        , 0 as oem_parts_received
        , 0 as oem_parts_received_cost
        , 0 as parts_received
        , 0 as parts_received_cost
        , vssp.vendor_subcat_cont_spend -- numerator
    from vendor_subcat_spend_prep vssp

union all

    select tvm.vendorid
        , tvm.vendor_type
        , dt_date as reference_date
        , pcs.subcategory
        , pcs.part_containers as container
        , 0 as oem_parts_used -- 0'd for union and sum
        , 0 as oem_parts_used_cost
        , 0 as parts_used
        , 0 as parts_used_cost
        , 0 as oem_parts_received
        , 0 as oem_parts_received_cost
        , 0 as parts_received
        , 0 as parts_received_cost
        , 0 as vendor_subcat_cont_spend
    from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT dt
    full outer join ANALYTICS.PARTS_INVENTORY.PART_CATEGORIZATION_STRUCTURE  pcs
    full outer join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
    left join vendor_subcat_spend_prep vssp
        on vssp.vendorid = tvm.vendorid
            and vssp.subcategory = pcs.subcategory
            and vssp.container = pcs.part_containers
            and dt.dt_date = vssp.reference_date
    join ( -- We have spend in that subcategory that day
            select distinct vendorid, subcategory
            from vendor_subcat_spend_prep
            where year(reference_date) >= 2025
        ) subcat
        on subcat.vendorid = tvm.vendorid
            and subcat.subcategory = pcs.subcategory
    where part_containers is not null
        and year(dt_date) >= 2025
        and dt_date < dateadd(day, 1, current_date) -- Don't need future dates
        and vssp.vendorid is null
)
-- Next 3 CTES are calculating for variable 3: ES Vendor Spend within Shared Vendor Type Group (GL Account)
, type_spend as ( -- Total Spend in each GL for every Vendor Type every day
    select tvm.vendor_type
        , apd.account_number
        , apd.account_name
        , apd.gl_date::DATE as reference_date
        , sum(apd.amount) as vendor_type_spend
    from ANALYTICS.INTACCT_MODELS.AP_DETAIL apd
    join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
        on tvm.vendorid = apd.vendor_id
            and tvm.vendor_type is not null -- Only vendors assigned to a vendor type
            and apd.account_number not in (1316, 6026, 2390, 2303) -- Supplier Performance Account Exclusions
            and apd.ap_header_type = 'apbill'
    group by all
)

, vendor_type_spend_prep as (
    select vendorid -- Vendor bought from
    , apd.gl_date::DATE as reference_date -- Standardizing for union and aggregation
    , null as subcategory -- No parts to reference here, tells is this is an AP Detail line
    , null as container
    , 0 as oem_parts_used -- 0'd for union
    , 0 as oem_parts_used_cost
    , 0 as parts_used
    , 0 as parts_used_cost
    , 0 as oem_parts_received
    , 0 as oem_parts_received_cost
    , 0 as parts_received
    , 0 as parts_received_cost
    , tvm.vendor_type -- Vendor bought from's group
    , apd.account_number -- account spend was in
    , apd.account_name
    , sum(apd.amount) as vendor_spend -- spend for this line's (day's) vendor and GL
    , ts.vendor_type_spend -- spend for this vendor's group in relevant GL that day
    , 0 as vendor_subcat_cont_spend
    , 0 as es_subcat_cont_spend
from ANALYTICS.INTACCT_MODELS.AP_DETAIL apd
join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
    on tvm.vendorid = apd.vendor_id
        and tvm.vendor_type is not null
        and apd.account_number not in (1316, 6026, 2390, 2303) -- Supplier Performance Account Exclusions
        and apd.ap_header_type = 'apbill'
        and year(apd.gl_date) >= 2024 -- Limiting to help loading times
left join type_spend ts -- spend for this vendor's group in relevant GL that day
    on ts.vendor_type = tvm.vendor_type
        and ts.account_number = apd.account_number
        and ts.reference_date = apd.gl_date::DATE
group by all
)

, every_vendor_every_day as ( -- Adding a line for every vendor (within a type group) that doesn't have spend in that GL that day. Eliminates summing issues when filtering within looker
    select tvm.vendorid
    , dt.dt_date reference_date
    , null as subcategory
    , null as container
    , 0 as oem_parts_used
    , 0 as oem_parts_used_cost
    , 0 as parts_used
    , 0 as parts_used_cost
    , 0 as oem_parts_received
    , 0 as oem_parts_received_cost
    , 0 as parts_received
    , 0 as parts_received_cost
    , tvm.vendor_type
    , gla.account_number
    , gla.account_name
    , 0 as vendor_spend
    , gla.vendor_type_spend
    , 0 as vendor_subcat_cont_spend
    , 0 as es_subcat_cont_spend
    from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT dt
    full outer join ( -- Every vendor within a vendor type group
            select vendorid
                , vendor_type
            from ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING
            where vendor_type is not null) tvm
    join ( -- Fanning for GL's that have spend for that type group that day
            select distinct reference_date, vendor_type, account_number, account_name, vendor_type_spend
            from type_spend
            ) gla
        on gla.reference_date = dt.dt_date
            and gla.vendor_type = tvm.vendor_type
    left join vendor_type_spend_prep vtsp -- Vendor not already present for that day and GL
        on vtsp.vendorid = tvm.vendorid
            and vtsp.account_number = gla.account_number
            and vtsp.reference_date = dt.dt_date
    where dt.dt_year >= 2024 -- Limiting to help loading times
        and dt_date < dateadd(day, 1, current_date) -- Don't need future dates
        and vtsp.vendorid is null -- Vendor not already present for that day and GL

    union -- Adding dummy lines to full table

    select * from vendor_type_spend_prep
)

-- , all_spend as (
-- Final union bringing the three variables together
select * from every_vendor_every_day

union

select ps.vendorid
    , ps.reference_date
    , ps.subcategory
    , ps.container
    , sum(ps.oem_parts_used) as oem_parts_used
    , sum(ps.oem_parts_used_cost) as oem_parts_used_cost
    , sum(ps.parts_used) as parts_used
    , sum(ps.parts_used_cost) as parts_used_cost
    , sum(ps.oem_parts_received) as oem_parts_received
    , sum(ps.oem_parts_received_cost) as oem_parts_received_cost
    , sum(ps.parts_received) as parts_received
    , sum(ps.parts_received_cost) as parts_received_cost
    , ps.vendor_type
    , null as account_number
    , null as account_name
    , 0 as vendor_spend
    , 0 as vendor_type_spend
    , sum(ps.vendor_subcat_cont_spend) as vendor_subcat_cont_spend
    , ess.es_subcat_cont_spend
from part_share ps
left join es_subcat_spend ess
    on ess.subcategory = ps.subcategory
        and ess.container = ps.container
        and ess.reference_date = ps.reference_date
group by all
;;
  }
 dimension: vendorid {
  type: string
  description: "Vendor associated with the Make of the asset on the work order, the Provider of the Part on a PO, or AP Detail Spend where applicable."
  sql: ${TABLE}.vendorid ;;
 }
  dimension_group: reference {
    type: time
    description: "Work Order Completed Date, Part Reception Date, or GL Date in Ap Detail where applicable."
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.reference_date ;;
  }
  dimension: vendor_type {
    type: string
    description: "Vendor Type as it is mapped in the Procurement Spreadsheet. Coalesced with 'No Type' for primary key creation."
    sql: coalesce(${TABLE}.vendor_type, 'No Type') ;;
  }
# dimension: category {
#   type: string
#   description: "Part Category as assigned through the Retool App"
#   sql: ${TABLE}.category ;;
# }
  dimension: subcategory {
    type: string
    description: "Part Subcategory as assigned through the Retool App. Coalesced with 'No Subcat' for primary key creation."
    sql: coalesce(${TABLE}.subcategory, 'No Subcat') ;;
  }
  dimension: container {
    type: string
    description: "Part Container as assigned through the Retool App. Coalesced with 'No Subcat' for primary key creation."
    sql: coalesce(${TABLE}.container, 'No Container') ;;
  }
  dimension: part_line {
    type: yesno
    description: "Identifies if this line is for the part based metrics or AP Detail based metric."
    sql: iff(${TABLE}.subcategory is null, false, true) ;;
  }
dimension: primary_key {
  type: string
  primary_key: yes
  description: "Vendor ID, Date, Vendor Type, Part Subcategory, Part Container, GL Account, where coalesced with dummy strings where applicable."
  sql: concat(${vendorid}, ${reference_date}, ${subcategory}, ${container}, ${vendor_type}, ${account_name}) ;;
}
  dimension: account_number {
    type: number
    value_format_name: id
    description: "GL Account Number associated with Vendor Spend for that Day."
    sql: ${TABLE}.account_number ;;
  }
  dimension: account_name {
    type: string
    description: "GL Account Number associated with Vendor Spend for that Day. Coalesced with 'No Account' for primary key creation."
    sql: coalesce(${TABLE}.account_name, 'No Account') ;;
  }
  dimension: account_full_name {
    type: string
    description: "Account Number - Name. For presentation."
    sql: concat(${account_number},  ' - ', ${TABLE}.account_name) ;;
  }
  dimension: subcat_account_field {
    type: string
    description: "For drills. Coalesced part subcat and GL account if showing on same axis."
    sql: coalesce(${TABLE}.subcategory, ${account_full_name}) ;;
  }
  dimension: container_account_field {
    type: string
    description: "For drills. Coalesced part container and GL account if showing on same axis."
    sql: coalesce(${TABLE}.container, ${account_full_name}) ;;
  }
  dimension: vendor_spend {
    type: number
    value_format_name: usd
    description: "Vendor Spend on that day for a particular GL."
    sql: ${TABLE}.vendor_spend ;;
  }
  dimension: distinct_key_for_type_spend {
    type: string
    description: "For summing vendor type spend across many days, Gls, and vendors without creating duplication."
    sql: concat(${reference_date}, ${vendor_type}, ${account_number}) ;;
  }
  measure: total_vendor_spend {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "no"]
    value_format_name: usd_0
    description: "Summing Vendor Spend across days, Gls, and vendors."
    sql: ${vendor_spend} ;;
  }
  dimension: vendor_type_spend {
    type: number
    value_format_name: usd
    description: "Aggregated Vendor Type (group) Spend on that day for a particular GL."
    sql: ${TABLE}.vendor_type_spend ;;
  }
  measure: total_vendor_type_spend {
    type: sum_distinct
    sql_distinct_key: ${distinct_key_for_type_spend};;
    filters: [part_line: "no"]
    value_format_name: usd_0
    sql: ${vendor_type_spend} ;;
    description: "Summing Vendor Type (group) Spend across days, Gls, and vendors."
    drill_fields: [
      , vendor_type
      , total_vendor_type_spend_drill
    ]
  }
  measure: total_vendor_type_spend_drill {
    type: sum_distinct
    sql_distinct_key: ${distinct_key_for_type_spend};;
    filters: [part_line: "no"]
    value_format_name: usd_0
    sql: ${vendor_type_spend} ;;
    description: "Summing Vendor Type (group) Spend across days, Gls, and vendors. For second level drill."
    drill_fields: [
      , account_full_name
      , total_vendor_type_spend
    ]
  }
  measure: perc_vendor_type_spend_no_html {
    type: number
    value_format_name: percent_1
    sql: ${total_vendor_spend} / nullifzero(${total_vendor_type_spend}) ;;
    description: "Total Vendor Spend over the Vendor's Group's Total Spend."
    drill_fields: [
      , account_full_name
      , perc_vendor_type_spend_no_html
      , total_vendor_spend
      , total_vendor_type_spend
    ]
  }
  measure: perc_vendor_type_spend {
    type: number
    value_format_name: percent_1
    html: <p style="font-size:12px"> {{perc_vendor_type_spend._rendered_value}} of {{total_vendor_type_spend._rendered_value}} Total ES Spend in Vendor's Type Group </p>;;
    sql: ${total_vendor_spend} / nullifzero(${total_vendor_type_spend}) ;;
    description: "Total Vendor Spend over the Vendor's Group's Total Spend."
    drill_fields: [
      , account_full_name
      , perc_vendor_type_spend_no_html
      , total_vendor_spend
      , total_vendor_type_spend
    ]
  }
  dimension: oem_parts_used {
    type: number
    value_format_name: decimal_0
    description: "Quantity of Parts on Work Orders where the Provider matches the OEM of the asset"
    sql: ${TABLE}.oem_parts_used ;;
  }
  measure: total_oem_parts_used {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    description: "Summed Quantity of Parts on Work Orders where the Provider matches the OEM of the asset"
    sql: ${oem_parts_used} ;;
  }
  dimension: oem_parts_used_cost {
    type: number
    value_format_name: usd
    description: "Value of Parts on Work Orders where the Provider matches the OEM of the asset"
    sql: ${TABLE}.oem_parts_used_cost ;;
  }
  measure: total_oem_parts_used_cost {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${oem_parts_used_cost} ;;
    description: "Summed value of Parts on Work Orders where the Provider matches the OEM of the asset"
    drill_fields: [
      , subcategory
      , total_oem_parts_used_cost_drill
    ]
  }
  measure: total_oem_parts_used_cost_drill {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${oem_parts_used_cost} ;;
    description: "Summed value of Parts on Work Orders where the Provider matches the OEM of the asset. Second level drill for by container."
    drill_fields: [
      , container
      , total_oem_parts_used_cost_drill
    ]
  }
  dimension: parts_used {
    type: number
    value_format_name: decimal_0
    description: "Parts used on Work Orders."
    sql: ${TABLE}.parts_used ;;
  }
  measure: total_parts_used {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    description: "Total parts used on Work Orders."
    sql: ${parts_used} ;;
  }
  dimension: parts_used_cost {
    type: number
    value_format_name: usd
    description: "Value of parts used on Work Orders."
    sql: ${TABLE}.parts_used_cost ;;
  }
  measure: total_parts_used_cost {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${parts_used_cost} ;;
    description: "Total value of parts used on Work Orders."
    drill_fields: [
      , subcategory
      , total_parts_used_cost_drill
    ]
  }
  measure: total_parts_used_cost_drill {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${parts_used_cost} ;;
    description: "Total value of parts used on Work Orders. Second level drill for container."
    drill_fields: [
      , container
      , total_parts_used_cost
    ]
  }
  measure: perc_oem_parts_used {
    type: number
    description: "Percent of Parts on Work Orders where the Provider is the same as the Asset's OEM"
    value_format_name: percent_1
    html: <p style="font-size:12px"> {{perc_oem_parts_used._rendered_value}} of {{total_parts_used._rendered_value}} in parts consumed on Work Orders </p>;;
    sql: ${total_oem_parts_used} / nullifzero(${total_parts_used}) ;;
  }
  measure: perc_oem_parts_used_no_html {
    type: number
    description: "Percent of Parts on Work Orders where the Provider is the same as the Asset's OEM"
    value_format_name: percent_1
    sql: ${total_oem_parts_used} / nullifzero(${total_parts_used}) ;;
  }
  measure: perc_oem_parts_used_cost {
    type: number
    description: "Percent of Part Value on Work Orders where the Provider is the same as the Asset's OEM"
    value_format_name: percent_1
    html: <p style="font-size:12px"> {{perc_oem_parts_used_cost._rendered_value}} of {{total_parts_used_cost._rendered_value}} in Parts Consumed on Work Orders for OEM's Assets</p>;;
    sql: ${total_oem_parts_used_cost} / nullifzero(${total_parts_used_cost}) ;;
    drill_fields: [
      , subcategory
      , perc_oem_parts_used_cost_no_html_drill
      , total_oem_parts_used_cost_drill
      , total_parts_used_cost_drill
    ]
  }
  measure: perc_oem_parts_used_cost_no_html {
    type: number
    description: "Percent of Parts Cost on Work Orders where the Provider is the same as the Asset's OEM"
    value_format_name: percent_1
    sql: ${total_oem_parts_used_cost} / nullifzero(${total_parts_used_cost}) ;;
    drill_fields: [
      , subcategory
      , perc_oem_parts_used_cost_no_html_drill
      , total_oem_parts_used_cost_drill
      , total_parts_used_cost_drill
    ]
  }
  measure: perc_oem_parts_used_cost_no_html_drill {
    type: number
    description: "Percent of Parts Cost on Work Orders where the Provider is the same as the Asset's OEM"
    value_format_name: percent_1
    sql: ${total_oem_parts_used_cost} / nullifzero(${total_parts_used_cost}) ;;
    drill_fields: [
      , container
      , perc_oem_parts_used_cost_no_html
      , total_oem_parts_used_cost_drill
      , total_parts_used_cost_drill
    ]
  }
  dimension: oem_parts_received {
    type: number
    description: "Parts received on PO's where the provider of the part matches the vendor it was bought from."
    sql: ${TABLE}.oem_parts_received ;;
  }
  measure: total_oem_parts_received {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    description: "Total parts received on PO's where the provider of the part matches the vendor it was bought from."
    sql: ${oem_parts_received} ;;
  }
  dimension: oem_parts_received_cost {
    type: number
    value_format_name: usd
    description: "Value of parts received on PO's where the provider of the part matches the vendor it was bought from."
    sql: ${TABLE}.oem_parts_received_cost ;;
  }
  measure: total_oem_parts_received_cost {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${oem_parts_received_cost} ;;
    description: "Total Value of parts received on PO's where the provider of the part matches the vendor it was bought from."
    drill_fields: [
      , subcategory
      , total_oem_parts_received_cost_drill
    ]
  }
  measure: total_oem_parts_received_cost_drill {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${oem_parts_received_cost} ;;
    description: "Total Value of parts received on PO's where the provider of the part matches the vendor it was bought from. Second level drill for container."
    drill_fields: [
      , container
      , total_oem_parts_received_cost_drill
    ]
  }
  dimension: parts_received {
    type: number
    description: "Parts received manufactured by this line's vendor."
    sql: ${TABLE}.parts_received ;;
  }
  measure: total_parts_received {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    description: "Total parts received manufactured by the vendor."
    sql: ${parts_received} ;;
  }
  dimension: parts_received_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.parts_received_cost ;;
  }
  measure: total_parts_received_cost {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${parts_received_cost} ;;
    description: "Total parts value received manufactured by the vendor."
    drill_fields: [
      , subcategory
      , total_parts_received_cost_drill
    ]
  }
  measure: total_parts_received_cost_drill {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${parts_received_cost} ;;
    description: "Total parts value received manufactured by the vendor. Second level drill for container."
    drill_fields: [
      , container
      , total_parts_received_cost_drill
    ]
  }
  measure: perc_oem_parts_received {
    type: number
    description: "Percent of Parts received on PO's where the provider of the part matches the vendor it was bought from"
    value_format_name: percent_1
    html: <p style="font-size:12px"> {{perc_oem_parts_received._rendered_value}} with {{total_parts_received_cost._rendered_value}} in total OEM Parts Bought </p>;;
    sql: ${total_oem_parts_received} / nullifzero(${total_parts_received}) ;;
  }
  measure: perc_oem_parts_received_no_html {
    type: number
    description: "Percent of Parts received on PO's where the provider of the part matches the vendor it was bought from"
    value_format_name: percent_1
    sql: ${total_oem_parts_received} / nullifzero(${total_parts_received}) ;;
  }
  measure: perc_oem_parts_received_cost {
    type: number
    description: "Percent of Part Value received on PO's where the provider of the part matches the vendor it was bought from"
    value_format_name: percent_1
    html: <p style="font-size:12px"> {{perc_oem_parts_received._rendered_value}} of {{total_parts_received_cost._rendered_value}} in Total OEM Manufactured Parts Bought </p>;;
    sql: ${total_oem_parts_received_cost} / nullifzero(${total_parts_received_cost}) ;;
    drill_fields: [
      subcategory
      , perc_oem_parts_received_cost_no_html_drill
      , total_oem_parts_received_cost_drill
      , total_parts_received_cost_drill
    ]
  }
  measure: perc_oem_parts_received_cost_no_html {
    type: number
    description: "Percent of Part Value received on PO's where the provider of the part matches the vendor it was bought from"
    value_format_name: percent_1
    sql: ${total_oem_parts_received_cost} / nullifzero(${total_parts_received_cost}) ;;
    drill_fields: [
      subcategory
      , perc_oem_parts_received_cost_no_html_drill
      , total_oem_parts_received_cost_drill
      , total_parts_received_cost_drill
    ]
  }
  measure: perc_oem_parts_received_cost_no_html_drill {
    type: number
    description: "Percent of Parts Value received on PO's where the provider of the part matches the vendor it was bought from"
    value_format_name: percent_1
    sql: ${total_oem_parts_received_cost} / nullifzero(${total_parts_received_cost}) ;;
    drill_fields: [
      container
      , perc_oem_parts_received_cost_no_html
      , total_oem_parts_received_cost_drill
      , total_parts_received_cost_drill
    ]
  }
  # es_subcat_cont_spend
  dimension: vendor_subcat_cont_spend {
    type: number
    value_format_name: usd
    description: "Value of parts bought from a Vendor in a certain subcategory and container on a given day"
    sql: ${TABLE}.vendor_subcat_cont_spend ;;
  }
  measure: total_vendor_subcat_cont_spend {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${vendor_subcat_cont_spend} ;;
    description: "Summed value of parts bought from a Vendor in a certain subcategory and container"
    drill_fields: [
      , subcategory
      , total_vendor_subcat_cont_spend_drill
    ]
  }
  measure: total_vendor_subcat_cont_spend_drill {
    type: sum_distinct
    sql_distinct_key: ${primary_key} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${vendor_subcat_cont_spend} ;;
    description: "Summed value of parts bought from a Vendor in a certain subcategory and container. Second level drill for by container."
    drill_fields: [
      , container
      , total_vendor_subcat_cont_spend_drill
    ]
  }
  dimension: distinct_key_for_subcat_cont_spend {
    type: string
    description: "For summing vendor type spend across many days, Gls, and vendors without creating duplication."
    sql: concat(${reference_date}, ${subcategory}, ${container}) ;;
  }
  dimension: es_subcat_cont_spend {
    type: number
    value_format_name: usd
    description: "Value of parts bought by ES in a certain subcategory and container on a given day"
    sql: ${TABLE}.es_subcat_cont_spend ;;
  }
  measure: total_es_subcat_cont_spend {
    type: sum_distinct
    sql_distinct_key: ${distinct_key_for_subcat_cont_spend} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${es_subcat_cont_spend} ;;
    description: "Summed value of parts bought by ES in a certain subcategory and container on a given day"
    drill_fields: [
      , subcategory
      , total_es_subcat_cont_spend_drill
    ]
  }
  measure: total_es_subcat_cont_spend_drill {
    type: sum_distinct
    sql_distinct_key: ${distinct_key_for_subcat_cont_spend} ;;
    filters: [part_line: "yes"]
    value_format_name: usd_0
    sql: ${es_subcat_cont_spend} ;;
    description: "Summed value of parts bought by ES in a certain subcategory and container on a given daySecond level drill for container."
    drill_fields: [
      , container
      , total_es_subcat_cont_spend_drill
    ]
  }
  measure: perc_vendor_subcat_cont_spend {
    type: number
    description: "Percent of Part Value received on PO's where the provider of the part matches the vendor it was bought from"
    value_format_name: percent_1
    html: <p style="font-size:12px"> {{perc_vendor_subcat_cont_spend._rendered_value}} of {{total_es_subcat_cont_spend._rendered_value}} in Vendor Subcategory and Part Container Spend</p>;;
    sql: ${total_vendor_subcat_cont_spend} / nullifzero(${total_es_subcat_cont_spend}) ;;
    drill_fields: [
      subcategory
      , perc_vendor_subcat_cont_spend_no_html_drill
      , total_vendor_subcat_cont_spend_drill
      , total_es_subcat_cont_spend_drill
    ]
  }
  measure: perc_vendor_subcat_cont_spend_no_html {
    type: number
    description: "Percent of Part Value received on PO's where the provider of the part matches the vendor it was bought from"
    value_format_name: percent_1
    sql: ${total_vendor_subcat_cont_spend} / nullifzero(${total_es_subcat_cont_spend}) ;;
    drill_fields: [
      subcategory
      , perc_vendor_subcat_cont_spend_no_html_drill
      , total_vendor_subcat_cont_spend_drill
      , total_es_subcat_cont_spend_drill
    ]
  }
  measure: perc_vendor_subcat_cont_spend_no_html_drill {
    type: number
    description: "Percent of Parts Value received on PO's where the provider of the part matches the vendor it was bought from"
    value_format_name: percent_1
    sql: ${total_vendor_subcat_cont_spend} / nullifzero(${total_es_subcat_cont_spend}) ;;
    drill_fields: [
      container
      , perc_vendor_subcat_cont_spend_no_html
      , total_vendor_subcat_cont_spend_drill
      , total_es_subcat_cont_spend_drill
    ]
  }
  measure: market_share_cost {
    type: number
    value_format_name: usd_0
    sql: ${total_parts_used_cost} + ${total_parts_received_cost} + ${total_vendor_type_spend} + ${total_es_subcat_cont_spend} ;;
    description: "The denominator for the Market Share percentage."
    drill_fields: [
      container_account_field
      , market_share_cost
      , total_parts_used_cost_drill
      , total_parts_received_cost_drill
      , total_vendor_type_spend_drill
      , total_es_subcat_cont_spend
    ]
  }
  measure: market_share {
    type: number
    description: "Combination of perc_oem_parts_received_cost, perc_oem_parts_used_cost, perc_vendor_type_spend, and perc_vendor_subcat_cont_spend"
    value_format_name: percent_1
    html: <p style="font-size:12px"> {{market_share._rendered_value}} of {{market_share_cost._rendered_value}} in Work Order Consumption on OEM Assets, OEM Parts Bought, Vendor Share of Subcategories, and Vendor Type Spend </p>;;
    sql: (${total_oem_parts_received_cost} + ${total_oem_parts_used_cost} + ${total_vendor_spend} + ${total_vendor_subcat_cont_spend}) / (nullifzero(${market_share_cost})) ;;
    drill_fields: [
      subcat_account_field
        , market_share_no_html
        , market_share_cost
        , perc_oem_parts_used_no_html
        , perc_oem_parts_received_cost_no_html
        , perc_vendor_type_spend_no_html
        , perc_vendor_subcat_cont_spend_no_html
    ]
  }
  measure: market_share_container_drill {
    type: number
    description: "Combination of perc_oem_parts_received_cost, perc_oem_parts_used_cost, perc_vendor_type_spend, and perc_vendor_subcat_cont_spend"
    value_format_name: percent_1
    html: <p style="font-size:12px"> {{market_share._rendered_value}} of {{market_share_cost._rendered_value}} in Work Order Consumption on OEM Assets, OEM Parts Bought, Vendor Share of Subcategories, and Vendor Type Spend </p>;;
    sql: (${total_oem_parts_received_cost} + ${total_oem_parts_used_cost} + ${total_vendor_spend} + ${total_vendor_subcat_cont_spend}) / (nullifzero(${market_share_cost})) ;;
    drill_fields: [
      container
      , market_share_no_html
      , market_share_cost
      , perc_oem_parts_used_no_html
      , perc_oem_parts_received_no_html
      , perc_vendor_subcat_cont_spend_no_html
    ]
  }
  measure: market_share_no_html {
    type: number
    description: "Combination of perc_oem_parts_received_cost, perc_oem_parts_used_cost, perc_vendor_type_spend, and perc_vendor_subcat_cont_spend"
    value_format_name: percent_1
    sql: (${total_oem_parts_received_cost} + ${total_oem_parts_used_cost} + ${total_vendor_spend} + ${total_vendor_subcat_cont_spend}) / (nullifzero(${market_share_cost})) ;;
    drill_fields: [
      subcat_account_field
      , market_share_no_html
      , market_share_cost
      , perc_oem_parts_used_no_html
      , perc_oem_parts_received_cost_no_html
      , perc_vendor_type_spend_no_html
      , perc_vendor_subcat_cont_spend_no_html
    ]
  }
  measure: count_distinct_vendorid {
    type: count_distinct
    sql: ${vendorid} ;;
  }
  measure: total_market_share_numerator {
    type: number
    value_format_name: usd_0
    description: "The aggregate value associated with the Vendor on that line"
    sql: ${total_vendor_spend} + ${total_oem_parts_used_cost} + ${total_oem_parts_received_cost} + ${total_vendor_subcat_cont_spend} ;;
  }
}
