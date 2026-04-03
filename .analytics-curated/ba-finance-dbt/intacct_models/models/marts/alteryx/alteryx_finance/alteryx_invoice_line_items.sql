with line_items as (
    select * from {{ ref('stg_es_warehouse_public__line_items') }}
),

invoices as (
    select * from {{ ref('stg_es_warehouse_public__invoices') }}
),

created_by_users as (
    select * from {{ ref('stg_es_warehouse_public__users') }}
),

billing_approved_by_users as (
    select * from {{ ref('stg_es_warehouse_public__users') }}
),

line_item_types as (
    select * from {{ ref('stg_es_warehouse_public__line_item_types') }}
),

salesperson_info as (
    select
        user_id,
        min(name) as name,
        min(email_address) as email_address
    from {{ ref('stg_analytics_bi_ops__salesperson_info') }}
    group by user_id
)

-- invoice line items --
select
    line_items.line_item_id as line_item_id,
    invoices.invoice_no as invoice_no,
    invoices.invoice_id as invoice_id,
    line_item_types.line_item_type_name as line_item_type,
    line_items.description as description,
    line_items.rental_id as rental_id,
    line_items.asset_id as asset_id,
    line_items.tax_amount as tax_amount,
    line_items.number_of_units as number_of_units,
    line_items.price_per_unit as price_per_unit,
    (line_items.number_of_units * line_items.price_per_unit) as amount,
    invoices.date_created as gl_date_created,
    invoices.salesperson_user_id as salesperson_user_id,
    salesperson_info.name as salesperson_name,
    salesperson_info.email_address as email_address,
    initcap(lower(created_by_users.first_name)) || ' ' || initcap(lower(created_by_users.last_name)) as invoice_created_by,
    initcap(lower(billing_approved_by_users.first_name)) || ' ' || initcap(lower(billing_approved_by_users.last_name)) as invoice_approved_by
from line_items
inner join invoices on line_items.invoice_id = invoices.invoice_id
left join created_by_users on invoices.created_by_user_id = created_by_users.user_id
left join billing_approved_by_users on invoices.billing_approved_by_user_id = billing_approved_by_users.user_id
left join line_item_types on line_items.line_item_type_id = line_item_types.line_item_type_id
left join salesperson_info on invoices.salesperson_user_id = salesperson_info.user_id
order by invoices.date_created desc
