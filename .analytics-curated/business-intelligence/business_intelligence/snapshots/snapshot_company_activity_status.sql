{% snapshot snapshot_company_activity_status %}
{{
    config(
        strategy='check',
        unique_key='company_id',
        check_cols=['company_activity_status'],
        dbt_valid_to_current="to_date('9999-12-31')",
        hard_deletes='new_record'
    )
}}

select
    company_id,
    company_activity_status

from {{ ref('int_company_activity_status') }}

{% endsnapshot %}
