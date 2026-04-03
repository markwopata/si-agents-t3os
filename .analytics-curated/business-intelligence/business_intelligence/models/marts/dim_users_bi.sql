{{ config( 
    materialized='incremental',
    unique_key=['user_key'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

with users as (
    select 
        u.*
        , COALESCE(uf.is_support_user, FALSE) as user_is_support_user
        , COALESCE(e.employee_key,
            {{ get_default_key_from_dim(model_name='dim_employees') }}
        ) as user_employee_key
        , case when e.employee_id IS NOT NULL THEN TRUE ELSE FALSE END AS user_is_employee
    from {{ ref('platform', 'dim_users') }} u
    LEFT JOIN {{ref('bridge_user_employee') }} br
        ON u.user_key = br.user_key
    LEFT JOIN {{ ref('dim_employees')}} e 
        ON br.employee_key = e.employee_key
    LEFT JOIN {{ ref('int_user_flags') }} uf
        ON u.user_id = uf.user_id

    {% if is_incremental() -%}
    where u.user_recordtimestamp > (select max(this._updated_recordtimestamp) from {{ this }} this )
    {%- endif -%}
)

SELECT 
    user_key
    , user_source
    , user_id
    , user_username
    , user_deleted
    , user_company_key
    , user_first_name
    , user_last_name
    , user_full_name
    , user_timezone
    , user_accepted_terms
    , user_approved_for_purchase_orders
    , user_is_salesperson
    , user_can_access_camera
    , user_can_create_asset_financial_records
    , user_can_grant_permissions
    , user_can_read_asset_financial_records
    , user_can_rent
    , user_sms_opted_out
    , user_read_only

    -- fields only in business_intelligence
    , user_employee_key
    , user_is_employee
    , user_is_support_user
    
    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM users