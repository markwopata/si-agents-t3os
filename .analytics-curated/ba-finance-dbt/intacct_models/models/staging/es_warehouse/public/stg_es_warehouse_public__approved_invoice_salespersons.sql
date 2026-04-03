WITH source AS (
    SELECT * FROM {{ ref('base_es_warehouse_public__approved_invoice_salespersons') }}
),
union_primary_and_secondary_salespersons as (
    select
        invoice_id,
        primary_salesperson_id                as salesperson_id,
        'Primary Salesperson'                 as sales_person_type,
        1                                     as salesperson_type_id,
        array_size(secondary_salesperson_ids) as secondary_rep_count,
        _es_update_timestamp
    from source

    union all

    select
        invoice_id,
        f.value::INT                          as salesperson_id,
        'Secondary Salesperson'               as sales_person_type,
        2                                     as salesperson_type_id,
        array_size(secondary_salesperson_ids) as secondary_rep_count,
        _es_update_timestamp
    from source,
            lateral flatten(input => secondary_salesperson_ids) f
)
select 
    invoice_id,
    salesperson_id,
    sales_person_type,
    salesperson_type_id,
    secondary_rep_count,
    _es_update_timestamp
from union_primary_and_secondary_salespersons
