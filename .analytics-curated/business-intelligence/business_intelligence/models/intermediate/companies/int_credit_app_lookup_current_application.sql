{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }} 

with companies_post_retool as (
        select distinct company_id
        from {{ ref('int_credit_app_base') }}
        WHERE date_created_ct::date > '{{ var("credit_app_retool_date") }}'::date
        AND company_id IS NOT NULL
        AND {{ filter_transformation_updates('_updated_recordtimestamp') }}
    )

    -- this is basically a one time load on the first run
    {% if not is_incremental() -%}
    , companies_pre_retool as (
        select distinct pre.company_id
        from {{ ref('int_credit_app_base') }} pre
        WHERE date_created_ct::date <= '{{ var("credit_app_retool_date") }}'::date
        and not exists (
            select 1
            from  companies_post_retool post
            where pre.company_id = post.company_id
        )
    )

    , pre_retool as (
        select *
        FROM {{ ref('int_credit_app_base') }}
        WHERE date_created_ct::date <= '{{ var("credit_app_retool_date") }}'::date
        and company_id in (select company_id from companies_pre_retool)
    )
    {%- endif -%}

    , latest_app as (
        select *
        from (
            select *
            from {{ ref('int_credit_app_base') }}
            where company_id in (select company_id from companies_post_retool)

            {% if not is_incremental() -%}
            UNION ALL
            select *
            from pre_retool
            {%- endif -%}
        ) combined

        QUALIFY ROW_NUMBER() OVER (
            PARTITION BY company_id
            ORDER BY
                date_created_ct DESC NULLS LAST
                , date_completed_ct DESC NULLS LAST
                , date_received_ct DESC NULLS LAST
        ) = 1
    )


select 
    company_id
    , camr_id
    
    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp 

from latest_app