with source as (
    select * from {{ source('analytics_intacct', 'ar_line') }}
),

renamed as (
    select
        -- ids
        recordno as pk_ar_line_id,
        recordkey as fk_ar_header_id,
        customerdimkey as fk_customer_id,
        customerid as customer_id,
        parententry as fk_parent_ar_line_id,
        locationkey as fk_entity_id,
        locationid as entity_id,
        departmentkey as fk_department_id,
        departmentid as department_id,
        ar_inv_lineitemid::int as fk_admin_line_item_id,
        coalesce(ar_inv_assetid::int, nullif(ar_adj_assetid, '-')::int) as fk_admin_asset_id,
        ar_adj_lineitemid::int as fk_admin_adj_line_item_id,

        -- strings
        recordtype as ar_line_type,
        entrydescription as line_description,

        -- numerics
        gloffset as debit_credit_sign,
        line_no::int as line_number,
        accountno as account_number,
        offsetglaccountno as offset_account_number,
        round(amount, 2) as amount,
        row_number() over (partition by recordkey, gloffset, amount order by recordno) as secondary_line_number,

        -- timestamps
        entry_date as gl_date,
        whencreated as date_created,
        whenmodified as date_updated,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp

    from source
)

select * from renamed
