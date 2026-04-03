with source as (
    select * from {{ source('analytics_intacct', 'customer') }}
)


, renamed as (
    select
        -- ids
        recordno as pk_customer_id,
        customerid as customer_id,
        taxid as tax_id,
        parentkey as fk_parent_customer_id,
        contactkey as fk_contact_id,
        termskey as fk_terms_id,
        accountkey as fk_account_id,
        custtypekey as fk_customer_type_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,
        market_id,
        vendor_id_ref as vendor_id,

        -- strings
        name as customer_name,
        termname as terms_name,
        status as customer_status,
        collector as collector_name,
        'https://admin.equipmentshare.com/#/home/companies/' || customer_id as url_admin,

        -- booleans
        case
            when reporting_category = 'Related Party' then TRUE
            else FALSE
        end as is_related_party, 
        
        -- timestamps
        activationdate as date_activated,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp,
        whencreated as date_created,
        whenmodified as date_updated
    from source
)

select * from renamed
