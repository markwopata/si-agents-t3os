{{ config(
    materialized='incremental',
    unique_key=['company_id', 'reactivated_timestamp'],
    incremental_strategy='delete+insert'
) }}

-- filter for only companies that were reactivated from Dormant/Inactive to Active
with reactivations as (
    select
        company_id,
        previous_dbt_valid_from as churned_timestamp,
        dbt_valid_from as reactivated_timestamp,
    from {{ ref('int_company_activity_status_changes') }}
    where is_reactivated = true
    and ({{ filter_transformation_updates('_updated_recordtimestamp') }})
),

-- Find the invoice created during the dormant/inactive period that triggered reactivation
reactivation_invoice as (
    select
        r.company_id,
        r.churned_timestamp,
        r.reactivated_timestamp,
        i.invoice_id,
        i.order_id,
        i.end_date as invoice_cycle_end_date
    from reactivations r
    inner join {{ ref('platform', 'invoices') }} i
        on r.company_id = i.company_id
        -- Invoice was created during the dormant/inactive period
        and i.date_created > r.churned_timestamp
        and i.date_created <= r.reactivated_timestamp
        -- Exclude deleted invoices
        and i._invoices_effective_delete_utc_datetime is null
    qualify row_number() over (
        partition by r.company_id, r.reactivated_timestamp
        order by i.end_date desc
    ) = 1
)

select
    company_id,
    churned_timestamp,
    reactivated_timestamp,
    invoice_id,
    order_id,
    invoice_cycle_end_date,

    {{ get_current_timestamp() }} as _updated_recordtimestamp

from reactivation_invoice
