-- Rentals Section
with rentals as (
    select
        r.rental_id,
        r.asset_id,
        r.order_id,
        r.date_created,
        r.start_date,
        r.end_date,
        r.job_description,
        r.equipment_class_id,
        r.drop_off_delivery_id,
        r.return_delivery_id,
        r.rental_protection_plan_id,
        r.taxable,
        r.rental_status_id,
        rs.name as rental_status,
        r.deleted as rental_is_deleted,
        r.rental_type_id,
        rt.name as rental_type,
        r.rental_purchase_option_id,
        rpp.name as rental_protection_plan,
        r.part_type_id,
        r.has_re_rent,
        r.is_below_floor_rate,
        r.rate_type_id,
        rate.name as rate_type,
        r.price_per_hour,
        r.price_per_day,
        r.price_per_week,
        r.price_per_month,
        r.is_flat_monthly_rate,
        r.is_flexible_rate,
        r.inventory_product_id,
        r.inventory_product_name,
        r.rental_pricing_structure_id,
        r.shift_type_id,
        r.off_rent_date_requested,
        r.url_admin
    from {{ ref("stg_es_warehouse_public__rentals") }} as r
        inner join {{ ref("stg_es_warehouse_public__rental_statuses") }} as rs
            on r.rental_status_id = rs.rental_status_id
        -- There are 2 rentals with null rental_type_id
        left join {{ ref("stg_es_warehouse_public__rental_types") }} as rt
            on r.rental_type_id = rt.rental_type_id
        left join {{ ref("stg_es_warehouse_public__rental_protection_plans") }} as rpp
            on r.rental_protection_plan_id = rpp.rental_protection_plan_id
        left join {{ ref("int_assets") }} as a
            on r.asset_id = a.asset_id
        left join {{ ref("stg_es_warehouse_public__equipment_classes") }} as ec
            on r.equipment_class_id = ec.equipment_class_id
        left join {{ ref("stg_es_warehouse_public__rental_purchase_options") }} as rpo
            on r.rental_purchase_option_id = rpo.rental_purchase_option_id
        left join {{ ref("stg_es_warehouse_public__rate_types") }} as rate
            on r.rate_type_id = rate.rate_type_id
),

-- Orders Section
orders as (
    select
        o.order_id,
        o.order_status_id,
        os.name as order_status,
        o.user_id as order_user_id,
        concat(u.first_name, ' ', u.last_name) as order_user_name,
        u.company_id as order_company_id,
        c.company_name as order_company_name,
        o.is_deleted as order_is_deleted
    from {{ ref("stg_es_warehouse_public__orders") }} as o
        left join {{ ref("stg_es_warehouse_public__order_statuses") }} as os
            on o.order_status_id = os.order_status_id
        left join {{ ref("stg_es_warehouse_public__users") }} as u
            on o.user_id = u.user_id
        left join {{ ref("stg_es_warehouse_public__companies") }} as c
            on u.company_id = c.company_id
),

-- Deliveries Section
deliveries as (
    select
        d.delivery_id,
        d.delivery_status_id,
        ds.name as delivery_status,
        d.driver_user_id,
        concat(u.first_name, ' ', u.last_name) as driver_name,
        d.facilitator_type_id,
        dft.name as facilitator_type,
        d.contact_name,
        d.contact_phone_number,
        d.location_id,
        l.nickname,
        l.street_1,
        l.street_2,
        l.city,
        l.state_id,
        s.name as state_name,
        s.abbreviation as state_abbreviation,
        l.zip_code,
        l.latitude,
        l.longitude,
        l.jobsite as is_jobsite,
        l.description as location_description,
        d.charge,
        d.scheduled_date,
        d.completed_date
    from {{ ref("stg_es_warehouse_public__deliveries") }} as d
        inner join {{ ref("stg_es_warehouse_public__delivery_statuses") }} as ds
            on d.delivery_status_id = ds.delivery_status_id
        inner join {{ ref("stg_es_warehouse_public__delivery_facilitator_types") }} as dft
            on d.facilitator_type_id = dft.delivery_facilitator_type_id
        left join {{ ref("stg_es_warehouse_public__users") }} as u
            on d.driver_user_id = u.user_id
        left join {{ ref("stg_es_warehouse_public__locations") }} as l
            on d.location_id = l.location_id
        left join analytics.ls_dbt.stg_es_warehouse_public__states as s
            on l.state_id = s.state_id
),

-- Invoices Section
invoices as (
    select
        rental_id,
        min_by(invoice_id, billing_approved_date) as first_invoice_id,
        max_by(invoice_id, billing_approved_date) as last_invoice_id,
        sum(amount) as total_invoiced_amount -- Total invoiced amount net credits
    from {{ ref("int_admin_invoice_and_credit_line_detail") }}
    where rental_id is not null
    group by rental_id
)

-- Main Query
select
    r.* exclude (order_id, drop_off_delivery_id, return_delivery_id), -- Exclude order_id to avoid duplication
    o.*,
    i.* exclude (rental_id), -- Exclude rental_id to avoid duplication
    drop_off_delivery.delivery_id as drop_off_delivery_id,
    drop_off_delivery.delivery_status as drop_off_delivery_status,
    drop_off_delivery.driver_name as drop_off_delivery_driver_name,
    drop_off_delivery.facilitator_type as drop_off_delivery_facilitator_type,
    drop_off_delivery.contact_name as drop_off_delivery_contact_name,
    drop_off_delivery.contact_phone_number as drop_off_delivery_contact_phone_number,
    drop_off_delivery.location_id as drop_off_delivery_location_id,
    drop_off_delivery.nickname as drop_off_delivery_location_nickname,
    drop_off_delivery.street_1 as drop_off_delivery_street_1,
    drop_off_delivery.street_2 as drop_off_delivery_street_2,
    drop_off_delivery.city as drop_off_delivery_city,
    drop_off_delivery.state_name as drop_off_delivery_state_name,
    drop_off_delivery.state_abbreviation as drop_off_delivery_state_abbreviation,
    drop_off_delivery.zip_code as drop_off_delivery_zip_code,
    drop_off_delivery.latitude as drop_off_delivery_latitude,
    drop_off_delivery.longitude as drop_off_delivery_longitude,
    drop_off_delivery.is_jobsite as drop_off_delivery_is_jobsite,
    drop_off_delivery.location_description as drop_off_delivery_location_description,
    drop_off_delivery.charge as drop_off_delivery_charge,
    drop_off_delivery.scheduled_date as drop_off_delivery_scheduled_date,
    drop_off_delivery.completed_date as drop_off_delivery_completed_date,
    return_delivery.delivery_id as return_delivery_id,
    return_delivery.delivery_status as return_delivery_status,
    return_delivery.driver_name as return_delivery_driver_name,
    return_delivery.facilitator_type as return_delivery_facilitator_type,
    return_delivery.contact_name as return_delivery_contact_name,
    return_delivery.contact_phone_number as return_delivery_contact_phone_number,
    return_delivery.location_id as return_delivery_location_id,
    return_delivery.nickname as return_delivery_location_nickname,
    return_delivery.street_1 as return_delivery_street_1,
    return_delivery.street_2 as return_delivery_street_2,
    return_delivery.city as return_delivery_city,
    return_delivery.state_name as return_delivery_state_name,
    return_delivery.state_abbreviation as return_delivery_state_abbreviation,
    return_delivery.zip_code as return_delivery_zip_code,
    return_delivery.latitude as return_delivery_latitude,
    return_delivery.longitude as return_delivery_longitude,
    return_delivery.is_jobsite as return_delivery_is_jobsite,
    return_delivery.location_description as return_delivery_location_description,
    return_delivery.charge as return_delivery_charge,
    return_delivery.scheduled_date as return_delivery_scheduled_date,
    return_delivery.completed_date as return_delivery_completed_date,
    current_timestamp as _es_update_timestamp
from rentals as r
    inner join orders as o
        on r.order_id = o.order_id
    left join deliveries as drop_off_delivery
        on r.drop_off_delivery_id = drop_off_delivery.delivery_id
    left join deliveries as return_delivery
        on r.return_delivery_id = return_delivery.delivery_id
    left join invoices as i
        on r.rental_id = i.rental_id
