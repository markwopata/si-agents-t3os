with source as (

  select * 
  from {{ source('rental_order_request_public','rental_requests') }}

),

renamed as (

  select
    -- metadata
    _es_update_timestamp,
    _es_load_timestamp,

    -- identifiers
    id                            as request_id,
    quote_id,
    --company_id,
    branch_id,
    user_id                       as web_user_id,
    user_uuid,

    -- timing
    created_at                    as request_created_at,
    updated_at                    as request_updated_at,
    deleted_at,

    -- flags
    guest_user_request            as is_guest_request,

    -- financials
    dropoff_fee,
    delivery_fee,
    equipment_charges,
    rental_subtotal,
    rpp_cost,
    order_total,
    taxes,
    rpp_percentage,
    shift_plan_multiplier,

    -- quote/order linkage
    po_number,
    quote_id,
    shift_id,
    shift_plan_name,
    shift_plan_description,

    -- logistics
    delivery_instructions,
    delivery_option,
    dropoff_option,
    receiver_option,
    receiver_contact_name,
    receiver_contact_phone,

    -- location
    jobsite_address_id,
    city,
    state                           as state_abbrev,
    state_name,
    latitude,
    longitude,
    timezone,
    get_directions_link,

    -- equipment/protection
    rental_protection_plan,
    shift_plan_name,
    shift_plan_description,
    type                              as request_type,
    status                            as request_status

  from source

)

select * from renamed