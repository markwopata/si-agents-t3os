with source as (
    select * from {{ source('analytics_intacct', 'department') }}
),

renamed as (
    select
        -- ids
        recordno as pk_department_id,
        departmentid as department_id,
        parentkey as fk_parent_department_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,

        -- strings
        title as department_name,
        custtitle as department_custom_name,
        status as department_status,
        department_type,
        state_id,
        build_to_suit_type,
        prevent_new_purchasing_trans as prevent_new_purchasing_transactions,
        t3_platform_inactive,
        sga_segment,

        -- timestamps
        date_vic_migration,
        acct_start_date as date_accounting_start,
        acct_end_date as date_accounting_end,
        whenmodified as date_updated,
        whencreated as date_created,
        date_no_longer_new_market,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp

    from source

)

select * from renamed
