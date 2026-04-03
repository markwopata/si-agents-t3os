{{ config(
    materialized='incremental'
    , incremental_strategy='merge'
    , unique_key='user_id'
    , merge_exclude_columns=['_created_recordtimestamp']
    , pre_hook=[
      "{{ create_url_encode_udf() }}"
    ]
) }}

with updated_users as (
    select user_id
    from {{ ref('platform', 'users') }}
    where ({{ filter_source_updates('_users_effective_start_utc_datetime', buffer_amount=1) }})
    OR ({{ filter_source_updates('_users_effective_delete_utc_datetime', buffer_amount=1) }}) 
)

select 
    user_id,
    company_id,
    first_name, 
    last_name,
    email_address,
    security_level_id,

    case 
        when (company_id is not null and security_level_id is not null and email_address is not null)
        then 
        'https://mimic.estrack.com/mimic-link?' ||
        'userId=' || user_id ||
        '&companyId=' || company_id ||
        '&securityLevelId=' || security_level_id ||
        '&destination=' || {{ target.database }}.silver.urlencodestring('https://app.estrack.com/') ||
        '&email=' || {{ target.database }}.silver.urlencodestring(email_address) ||
        '&fullName=' || {{ target.database }}.silver.urlencodestring(coalesce(first_name, '') || ' ' || coalesce(last_name, '')) 
        else null
    end as fleet_mimic_link,
    
    case 
        when (company_id is not null and security_level_id is not null and email_address is not null)
        then 
        'https://mimic.estrack.com/mimic-link?' ||
        'userId=' || user_id ||
        '&companyId=' || company_id ||
        '&securityLevelId=' || security_level_id ||
        '&destination=' || {{ target.database }}.silver.urlencodestring('https://analytics.estrack.com/') ||
        '&email=' || {{ target.database }}.silver.urlencodestring(email_address) ||
        '&fullName=' || {{ target.database }}.silver.urlencodestring(coalesce(first_name, '') || ' ' || coalesce(last_name, ''))
        else null
    end as analytics_mimic_link,
    _users_effective_delete_utc_datetime IS NOT NULL or deleted = true as is_deleted,
    
    current_timestamp() as _created_recordtimestamp,
    current_timestamp() as _updated_recordtimestamp

from {{ ref('platform', 'users') }}
where user_id in (select user_id from updated_users)