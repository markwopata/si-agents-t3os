with sales_line as (
    select * from {{ ref('stg_analytics_microsoft_dynamics__sales_line') }}
),

inventory_transactions as (
    select * from {{ ref('stg_analytics_microsoft_dynamics__inventory_transactions') }}
),

inventory_dimension as (
    select * from {{ ref('stg_analytics_microsoft_dynamics__inventory_dimension') }}
),

wms_location as (
    select * from {{ ref('stg_analytics_microsoft_dynamics__wms_location') }}
),

inventory_table as (
    select * from {{ ref('stg_analytics_microsoft_dynamics__inventory_table') }}
),

inventory_parts as (
    select * from {{ ref('stg_es_warehouse_inventory__parts') }}
),

branch_stores as (
    select * from {{ ref('int_branch_stores_mapping') }}
),


d365_most_recent_product_name as (
    --Finds the most recent ship date via Item ID in D365--
    select
        itemid as item_id,
        MAX(shippingdaterequested) as max_date
    from sales_line
    group by
        itemid
)

, d365_product as (
    --Finds the most recent product name via the most recent ship date in d365_most_recent_product_name
    --From the most recent shipment record, the following details are populated: Item ID Product Name* Most recent shipment date by Item ID
    select
        sales_line.itemid as item_id,
        sales_line.name as product_name,
        d365_most_recent_product_name.max_date
    from sales_line
    inner join
        d365_most_recent_product_name
        on sales_line.itemid = d365_most_recent_product_name.item_id
        and sales_line.shippingdaterequested = d365_most_recent_product_name.max_date
    group by
        sales_line.itemid,
        sales_line.name,
        d365_most_recent_product_name.max_date
)

,   d365_kck_distinct_oh_inventory as (
    --Pulls the inventory transaction details for the products in KCK--
    --Populates the following details for products from inventory transaction, dimension tables: ItemID, Bin Location, Item Name,
    --Old Part Number, Product Name, Inventory Location ID, Status Receipt, Status Issue, Quantity, Location Profile ID, Inventory Status,
    --Product Lifecycle State, ESDB Part ID, ESDB Part Name, ESDB Manufacturer Number
    select distinct
        inventory_transactions.recid as it_rec_id,
        inventory_transactions.itemid as item_id,
        inventory_dimension.wmslocationid as wms_location_id,
        inventory_table.namealias as name_alias,
        inventory_table.wfsoldpartnumber as old_part_number,
        d365_product.product_name,
        inventory_dimension.inventlocationid as invent_location_id,
        inventory_transactions.statusreceipt as status_receipt,
        inventory_transactions.statusissue as status_issue,
        inventory_transactions.qty as it_qty,
        wms_location.locprofileid as loc_profile_id,
        inventory_dimension.inventstatusid as invent_status,
        inventory_table.productlifecyclestateid as product_lifecycle_state,
        inventory_parts.part_id as esdb_part_id,
        inventory_parts.description as esdb_part_name,
        inventory_parts.manufacturer_number as esdb_manufacturer_number
    from inventory_transactions
    left join inventory_dimension
        on inventory_transactions.inventdimid = inventory_dimension.inventdimid
        and inventory_transactions.dataareaid = inventory_dimension.dataareaid
    left join wms_location
        on wms_location.wmslocationid = inventory_dimension.wmslocationid
    left join inventory_table
        on inventory_table.item_id = inventory_transactions.itemid
    left join inventory_parts
        on inventory_parts.part_id = inventory_table.esdbpartid_custom
    left join d365_product
        on d365_product.item_id = inventory_table.item_id
    where
        inventory_dimension.inventsiteid = 'KCK'
)

, tele_warehouse_inventory_raw as (
--From the inventory transactions, this query populates on hand quantity using status_receipt and status_issue and then excludes non-necessary transaction details. 
--This then becomes totals by Bin Location (WMS LOCATION ID)--
    select
        item_id as d365_item_id,
        name_alias as d365_item_name,
        old_part_number,
        product_name,
        invent_status,
        product_lifecycle_state,
        SUM(case
              when status_receipt in (1, 2, 3) then it_qty 
              when status_issue in (1, 2, 3) then it_qty
              else 0 end) as on_hand_quantity,
        invent_location_id,
        esdb_part_id,
        esdb_part_name,
        esdb_manufacturer_number
from d365_kck_distinct_oh_inventory
where
    loc_profile_id <> 'User'
    and wms_location_id <> 'DONOTUSE'
group by
    item_id,
    invent_location_id,
    wms_location_id,
    name_alias,
    old_part_number,
    product_name,
    product_lifecycle_state,
    invent_status,
    esdb_part_id,
    esdb_part_name,
    esdb_manufacturer_number
)

, tele_warehouse_inventory_totals as (
--From tele_warehouse_inventory_raw, this query takes results for all valid warehouse locations--
--Inventory status ‘AVAILABLE’ Dependent on actual location within the system; Product Lifecycle State ‘Operational’ Released Products Page toggle.
    select
        d365_item_id,
        d365_item_name,
        old_part_number,
        product_name,
        invent_status,
        product_lifecycle_state,
        sum(on_hand_quantity) as warehouse_quantity,
        esdb_part_id,
        esdb_part_name,
        esdb_manufacturer_number
    from tele_warehouse_inventory_raw
    group by
        d365_item_id,
        d365_item_name,
        old_part_number,
        product_name,
        invent_status,
        product_lifecycle_state,
        esdb_part_id,
        esdb_part_name,
        esdb_manufacturer_number
    having
        invent_status = 'AVAILABLE'
        and product_lifecycle_state = 'Operational'
    order by
            d365_item_id
)

, store_parts as (
--Finds inventory quantities for each branch_stores record--
    select
        part_id,
        to_varchar(store_id) as store_id,
        quantity,
        available_quantity,
        date_updated
    from {{ ref('stg_es_warehouse_inventory__store_parts') }}
)

, d365_invent_table as (
--Finds Items in D365 that are linked to the ordering app via a custom field--
    select
        esdbpartid_custom as esdb_part_id,
        item_id as d365_item_id
    from inventory_table
    where
        esdbpartid_custom is not null
)

, store_parts_mapping as (
--Maps store_parts sums to D365 for items--
    select
        store_parts.store_id,
        store_parts.part_id as esdb_part_id,
        d365_invent_table.d365_item_id,
        store_parts.quantity,
        store_parts.available_quantity
    from store_parts
    left join d365_invent_table
        on store_parts.part_id = d365_invent_table.esdb_part_id
)

, department as (
--Bringing in appropriate Branch name as it is known in D365--
    select
        to_varchar(department_id) as department_id,
        department_name as title
    from {{ ref('stg_analytics_intacct__department') }}
)

, branch_store_inventory as (
--Mapping individual store records to D365 Item and Department Title and removing records not included in the warehouse app--
    select
        branch_stores.store_id,
        branch_stores.store_name,
        branch_stores.branch_id,
        department.title as branch_name,
        store_parts_mapping.d365_item_id,
        store_parts_mapping.quantity as branch_quantity
    from branch_stores
    left join store_parts_mapping
        on branch_stores.store_id = store_parts_mapping.store_id
    left join department
        on department.department_id = branch_stores.branch_id
    where
        store_parts_mapping.d365_item_id is not null
)

, branch_telematics_inventory as (
--Summing branch quantity--
    select
        branch_id,
        branch_name,
        d365_item_id,
        sum(branch_quantity) as branch_quantity
    from branch_store_inventory
    group by
        branch_id,
        branch_name,
        d365_item_id
)

select
    branch_telematics_inventory.branch_id,
    branch_telematics_inventory.branch_name,
    tele_warehouse_inventory_totals.esdb_part_id,
    branch_telematics_inventory.branch_quantity as branch_onhand_quantity,
    tele_warehouse_inventory_totals.d365_item_id,
    tele_warehouse_inventory_totals.d365_item_name as warehouse_item_name,
    tele_warehouse_inventory_totals.warehouse_quantity,
    concat(branch_telematics_inventory.branch_id, 'TELE', tele_warehouse_inventory_totals.d365_item_id) as unique_identifier
from branch_telematics_inventory
left join
    tele_warehouse_inventory_totals
    on branch_telematics_inventory.d365_item_id = tele_warehouse_inventory_totals.d365_item_id
