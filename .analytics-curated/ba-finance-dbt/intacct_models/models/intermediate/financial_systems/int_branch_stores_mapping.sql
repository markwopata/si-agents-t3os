with inventory_stores as (
    select * from {{ ref('stg_es_warehouse_inventory__stores') }}
)

, branches as (
--ESDB Stores table details for the Branch itself--
    select
        to_varchar(store_id) as store_id,
        NAME as store_name,
        to_varchar(branch_id) as branch_id,
        NAME as branch_name
    from
        inventory_stores
    where
        store_type_id = 1
)
, stores as (
--ESDB Stores table for dependents to the branch--
    select
        to_varchar(parent_id) as parent_id,
        to_varchar(store_id) as store_id,
        to_varchar(branch_id) as branch_id,
        NAME as store_name
    from
        inventory_stores
    where
        store_type_id > 1
)

, branch_stores_mapping as (
--Mapping stores to their branches and formatting for union--
    select
        stores.store_id as store_id,
        stores.store_name as store_name,
        branches.branch_id as branch_id,
        branches.branch_name as branch_name
    from
        stores
    left join
        branches
        on branches.store_id = stores.branch_id
)

--Unioning records from branches and dependents (stores) as inventory could be split between the branch itself and the store(s)--
select
    store_id,
    store_name,
    branch_id,
    branch_name
from
    branches
union
select
    store_id,
    store_name,
    branch_id,
    branch_name
from
    branch_stores_mapping
