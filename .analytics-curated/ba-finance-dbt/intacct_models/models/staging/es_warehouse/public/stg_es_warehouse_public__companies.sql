with source as (
    select * from {{ source('es_warehouse_public', 'companies') }} 
)

, renamed as (
select
    -- ids
    company_id,
    owner_user_id,
    billing_location_id,
    logo_photo_id,
    billing_provider_id,
    white_label_application_id,
    net_terms_id,
    xero_id,
    elogs_id,
    ou_id,
    home_office_location_id,
    hours_of_service_type_id,
    crm_entity_id,
    external_billing_provider_id,
    universal_entity_id,
    authorized_signer_id,
    employer_identification_number,

    -- strings
    i18n_locale,
    i18n_unit,
    i18n_temperature,
    name as customer_name,
    name as company_name,
    case
        when do_not_rent = TRUE then 'Yes'
        else 'No'
    end as do_not_rent_flag,
    'https://admin.equipmentshare.com/#/home/companies/' || company_id as url_admin,

    -- numerics
    credit_limit, -- for COD (cash on delivery customers - the branches should be collecting payments/deposits up front), their credit limit should be 0
    dot_number,

    -- booleans
    is_telematics_service_provider,
    is_eligible_for_payouts,
    has_fleet,
    has_rentals,
    has_msa,
    do_not_rent as is_do_not_rent,
    delivery_vendor as is_delivery_vendor,
    service_vendor as is_service_vendor,
    supply_vendor as is_supply_vendor,
    is_rsp_partner,
    has_fleet_cam,

    -- timestamps
    _es_update_timestamp
    
    from source
    
)

select * from renamed
