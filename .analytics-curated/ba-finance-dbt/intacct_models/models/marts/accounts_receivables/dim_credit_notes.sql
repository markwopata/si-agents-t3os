with credit_notes as (
    select * from {{ ref('stg_es_warehouse_public__credit_notes') }}
),

users as (
    select * from {{ ref('stg_es_warehouse_public__users') }}
),

credit_note_status as (

    select * from {{ ref('stg_es_warehouse_public__credit_note_statuses') }}

)

select

    -- ids

    c.credit_note_id,
    c.company_id,
    c.originating_invoice_id,
    c.market_id,
    c.credit_note_type_id,
    c.created_by_user_id,
    c.credit_note_status_id,

    -- strings
    cns.credit_note_status_name,
    c.url_credit_note_admin,
    c.reference as invoice_number,
    c.credit_note_number,
    u.full_name as created_by,

    -- dates
    c.date_created

from credit_notes as c
    left join users as u
        on c.created_by_user_id = u.user_id
    inner join credit_note_status as cns
        on c.credit_note_status_id = cns.credit_note_status_id
