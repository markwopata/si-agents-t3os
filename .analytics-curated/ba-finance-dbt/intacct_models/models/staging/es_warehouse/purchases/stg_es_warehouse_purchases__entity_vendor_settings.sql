with source as (select * from {{ source('es_warehouse_purchases', 'entity_vendor_settings') }}),

renamed as (
    select
        entity_vendor_settings_id,
        entity_id,
        ap_address_id,
        external_erp_vendor_ref,
        entity_net_terms_id,
        credit_limit,
        notes,
        w9_on_file,
        entity_tax_classification_id,
        _es_update_timestamp

    from source
)

select * from renamed
