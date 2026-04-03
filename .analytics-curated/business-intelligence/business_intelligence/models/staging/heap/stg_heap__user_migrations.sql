-- logically, anything that was already migrated would not alter or get removed
-- but Heap can do multiple migrations --> migrate already migrated accounts to another account
    --> this means using merge strategy instead of append
-- so incremental model should capture any new records that didn't previously exist
-- posthook on downstream models will run macro that will remove migrated records


{{ config(
    materialized='incremental'
    , incremental_strategy = 'merge'
    , unique_key='from_user_id'
    , on_schema_change="sync_all_columns"
) }}

with 

source as (
 
    select * from {{ source('heap', 'user_migrations') }}

),

renamed as (

    select
        from_user_id,
        to_user_id,
        {{ dbt_run_started_at_formatted() }}

    from source

)

select *
from renamed

{% if is_incremental() %}

where not exists (
    select 1
    from {{this}} t
    where renamed.from_user_id = t.from_user_id
    and md5(concat_ws('|', renamed.from_user_id, renamed.to_user_id)) =md5(concat_ws('|', t.from_user_id, t.to_user_id))
)

{% endif %}