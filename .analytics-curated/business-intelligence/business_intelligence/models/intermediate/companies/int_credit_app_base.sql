{{ config(
    materialized='incremental',
    unique_key=['camr_id'], 
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp'],
    post_hook=[
        """
        {% if is_incremental() -%}
        delete from {{ this }}
        where camr_id in (
            select camr_id
            from {{ ref('stg_retool__credit_app_master_retool') }}
            where is_deleted = true
        )
        {%- endif -%}
        """
    ]
) }} 

with app as (
    select *
    from {{ ref('stg_retool__credit_app_master_retool') }}
    WHERE is_deleted = false
    AND ({{filter_source_updates(column_name='date_created_utc', buffer_amount=2, time_unit='hour', append_only=true)}})
)

select
    app.camr_id
    , app.company_id
    , app.company_name
    , app.source

    , app.date_created_utc -- source system watermark
    , app.date_created_ct
    , app.date_received_ct
    , app.date_completed_ct
    , app.app_status
    , CASE
        WHEN app.app_status = 'Approved' THEN 'Credit'
        WHEN app.app_status ILIKE '%cod%' THEN 'COD'
        ELSE NULL
    END AS app_type

    , ue.created_by_employee_user_id
    , app.created_by_email
    , ue.salesperson_user_id
    , app.salesperson
    , app.salesperson_name
    , ue.salesperson_employee_id
    , ue.credit_specialist_user_id
    , app.credit_specialist
    , app.credit_specialist_name
    , ue.credit_specialist_employee_id

    , app.market_id
    , app.market_name

    , app.duns
    , app.fein
    , app.sic
    , app.naics_primary
    , app.naics_secondary
    , app.notes

    , app.has_insurance_info
    , app.coi_received
    , app.insurance_company
    , app.insurance_email
    , app.insurance_phone

    , app.credit_safe_no
    , app.is_government_entity
    , app.has_online_app_status
    , app.is_salesperson_override
    , app.is_initial_web_self_signup
    , app.is_initial_web_unauthenticated
    , app.unauthenticated_dot_com_app_id
    , CASE
        WHEN app.notes = 'Automated record' AND app.source IN ('Branch', 'System')
             AND ROW_NUMBER() OVER (PARTITION BY app.company_id ORDER BY app.date_created_ct) = 1
        THEN TRUE
        ELSE FALSE
    END as is_automated_entry
    , CASE
        WHEN app.source = 'System' AND app.notes = 'Batch added at table initialization'
             AND ROW_NUMBER() OVER (PARTITION BY app.company_id ORDER BY app.date_created_ct) = 1
        THEN TRUE
        ELSE FALSE
    END as is_batch_loaded_entry

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp
    
from app
left join {{ ref('int_credit_app_map_user_employee') }} ue 
    ON app.camr_id = ue.camr_id