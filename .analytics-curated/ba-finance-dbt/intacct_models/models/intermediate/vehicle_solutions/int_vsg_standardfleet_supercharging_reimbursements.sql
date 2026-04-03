with supabase_reservations as (
    select
        r.prefixed_id,
        r.vehicle_vin
    from {{ ref('stg_analytics_vsg_postgres__public__reservations') }} as r
    qualify row_number() over (partition by r.prefixed_id order by r.created_at desc) = 1
)

select
    ssr.tesla_invoice_number,
    coalesce(ssr.vin, sr.vehicle_vin) as vin,
    ssr.reservation_id,
    ssr.rn,
    ssr.period_start_date,
    coalesce(ssr.payment_status, ssr.status) as status,
    coalesce(ssr.reservation_charges_category, ssr.category) as category,
    ssr.currency,
    ssr.kwh,
    case
        when ssr.period_start_date = '2024-07-01' then round(ssr.supercharge_amount / 100, 2)
        else ssr.supercharge_amount
    end as supercharge_amount,
    case
        when ssr.period_start_date = '2024-07-01' then round(ssr.amount_cents / 100, 2)
        else ssr.total_cost
    end as total_cost,
    case
        when ssr.period_start_date = '2024-07-01' then round(ssr.upcharge_cents / 100, 2)
        else ssr.upcharge
    end as upcharge,
    case
        when ssr.period_start_date = '2024-07-01' then round(ssr.sf_processing_fee_cents / 100, 2)
        else ssr.sf_fee
    end as standard_fleet_fee,
    case
        when ssr.period_start_date = '2024-07-01' then round((ssr.amount_cents - ssr.sf_processing_fee_cents) / 100, 2)
        else ssr.net_payout
    end as net_payout,
    ssr.ck_payments_enabled,
    coalesce(ssr.charge_session_id, ssr.session_id) as session_id,
    ssr.payment_intent_id,
    ssr.sf_account_id,
    ssr.file_name,
    ssr._es_update_timestamp
from {{ ref('stg_analytics_vehicle_solutions__standardfleet_supercharging_reimbursements') }} as ssr
    left join supabase_reservations as sr on ssr.partner_reference = sr.prefixed_id
