with source as (
    select * from {{ source('analytics_intacct', 'contact') }}
),

renamed as (
    select
        -- ids
        recordno as pk_contact_id,
        taxid as tax_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,
        megaentitykey,
        megaentityid,
        megaentityname,

        -- strings
        contactname as contact_name,
        companyname as contact_company_name,
        prefix,
        firstname,
        lastname,
        initial,
        printas,
        phone1,
        phone2,
        cellphone,
        pager,
        fax,
        email1,
        email2,
        url1,
        url2,
        mailaddress_address1,
        mailaddress_address2,
        mailaddress_city,
        mailaddress_state,
        mailaddress_zip,
        mailaddress_country,
        mailaddress_countrycode,
        status as contact_status,

        -- numerics
        discount,

        -- booleans
        taxable,
        visible,

        -- timestamps
        whenmodified as date_updated,
        whencreated as date_created,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp

    from source
)

select * from renamed
