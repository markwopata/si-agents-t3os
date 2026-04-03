with credit_notes as (
    select * from {{ ref('stg_es_warehouse_public__credit_notes') }}
)

select

    -- ids
    credit_note_id,

    -- measures
    total_credit_amount,
    tax_amount,
    remaining_credit_amount,
    line_item_amount

from credit_notes
