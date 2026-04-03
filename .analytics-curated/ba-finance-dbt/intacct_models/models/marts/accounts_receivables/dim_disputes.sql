with disputes as (
    select * from {{ ref('stg_es_warehouse_public__disputes') }}
),

dispute_events as (
    select * from {{ ref('stg_es_warehouse_public__dispute_events') }}
),

dispute_event_types as (
    select * from {{ ref('stg_es_warehouse_public__dispute_event_types') }}
),

dispute_details as (
    select * from {{ ref('stg_analytics_treasury__dispute_summary') }}
),

users as (
    select * from {{ ref('stg_es_warehouse_public__users') }}
)

select
    d.dispute_id,
    d.date_created as dispute_date_creation,
    d.invoice_id,
    d.created_by_user_id,
    u.full_name as created_by,
    t.dispute_event_description,
    dd.status,
    dd.branch_id,
    dd.created_by_email,
    dd.resolved_by_email,
    dd.resolved_by_title,
    dd.general_manager,
    dd.dispute_category
from disputes as d
    left join dispute_events as e
        on d.dispute_id = e.dispute_id
    left join dispute_event_types as t
        on e.dispute_event_type_id = t.dispute_event_type_id
    left join dispute_details as dd
        on d.dispute_id = dd.dispute_id
    left join users as u
        on d.created_by_user_id = u.user_id
