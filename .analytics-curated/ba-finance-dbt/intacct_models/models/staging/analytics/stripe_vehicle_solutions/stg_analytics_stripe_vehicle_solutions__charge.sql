with source as (

    select * from {{ source('analytics_stripe_vehicle_solutions', 'charge') }}

),

revenue_corrections as (

    select * from {{ ref('stg_analytics_vehicle_solutions__hq_rental_reservations') }}
    qualify row_number() over (partition by reservation_id::int order by pick_up_time desc) = 1

)

select
    c.id,
    regexp_substr(c.description, '\\d+$') as reservation_id,
    c.connected_account_id,
    c.amount as amount_in_cents,
    round(c.amount / 100.0, 2) as amount,
    c.amount_refunded as amount_refunded_in_cents,
    round(c.amount_refunded / 100.0, 2) as amount_refunded,
    c.application,
    c.billing_detail_address_city,
    c.billing_detail_address_country,
    c.billing_detail_address_line_1,
    c.billing_detail_address_line_2,
    c.billing_detail_address_postal_code,
    c.billing_detail_address_state,
    c.billing_detail_email,
    c.billing_detail_name,
    c.billing_detail_phone,
    c.application_fee_amount as application_fee_amount_in_cents,
    round(c.application_fee_amount / 100.0, 2) as application_fee_amount,
    c.calculated_statement_descriptor,
    c.captured,
    c.created as payment_charge_created_at,
    min(payment_charge_created_at) over (partition by reservation_id) as earliest_charge_date,
    max(payment_charge_created_at) over (partition by reservation_id) as latest_charge_date,
    count(case when description not ilike '%deposit%' then c.id end)
        over (partition by reservation_id)
        as num_non_deposit_charges,
    c.currency,
    c.description,
    c.destination,
    c.failure_code,
    c.failure_message,
    c.fraud_details_user_report,
    c.fraud_details_stripe_report,
    c.livemode as is_live_mode,
    c.metadata,
    c.on_behalf_of,
    c.outcome_network_status,
    c.outcome_reason,
    c.outcome_risk_level,
    c.outcome_risk_score,
    c.outcome_seller_message,
    c.outcome_type,
    c.paid as is_paid,
    c.receipt_email,
    c.receipt_number,
    c.receipt_url,
    c.refunded as is_refunded,
    c.shipping_address_city,
    c.shipping_address_country,
    c.shipping_address_line_1,
    c.shipping_address_line_2,
    c.shipping_address_postal_code,
    c.shipping_address_state,
    c.shipping_carrier,
    c.shipping_name,
    c.shipping_phone,
    c.shipping_tracking_number,
    c.card_id,
    c.bank_account_id,
    c.source_id,
    c.source_transfer,
    c.statement_descriptor,
    c.status,
    c.transfer_data_destination,
    c.transfer_group,
    c.balance_transaction_id,
    c.customer_id,
    c.invoice_id,
    c.payment_intent_id,
    c.payment_method_id,
    c.transfer_id,
    c._fivetran_synced,
    c.rule_rule,
    c.metadata:"customer_name"::string as metadata__customer_name,
    lower(
        coalesce(
            -- prefer equipmentshare email
            max(
                case
                    when lower(c.metadata:"email"::string) like '%@equipmentshare.com'
                        then c.metadata:"email"::string
                end
            ) over (partition by reservation_id),

            -- otherwise any email for the reservation
            max(c.metadata:"email"::string) over (partition by reservation_id)
        )
    ) as metadata__email,
    try_to_decimal(replace(c.metadata:"total_insurances", '"', ''), 10, 2) as metadata__total_insurances,
    c.metadata:"pick_up_location" as metadata__pick_up_location,
    c.metadata:"brand" as metadata__brand,
    c.metadata:"return_date" as metadata__return_date,
    try_to_decimal(replace(c.metadata:"total_taxes", '"', ''), 10, 2) as metadata__total_taxes,
    c.metadata:"phone" as metadata__phone,
    c.metadata:"pick_up_date" as metadata__pick_up_date,
    try_to_decimal(replace(c.metadata:"total_extras", '"', ''), 10, 2) as metadata__total_extras,
    c.metadata:"transaction_id" as metadata__transaction_id,
    try_to_decimal(replace(c.metadata:"total_price", '"', ''), 10, 2) as metadata__total_price,
    coalesce(rc.total_revenue, try_to_decimal(replace(c.metadata:"total_revenue", '"', ''), 10, 2))
        as metadata__total_revenue,
    c.metadata:"return_location" as metadata__return_location,
    try_to_decimal(replace(c.metadata:"total_rack_rate", '"', ''), 10, 2) as metadata__total_rack_rate,
    c.metadata:"prefixed_id" as metadata__prefixed_id,
    c.metadata:"transaction_type" as metadata__transaction_type,
    c.metadata:"vehicle" as metadata__vehicle,
    c.metadata:"transaction_uuid" as metadata__transaction_uuid
from source as c
    left join revenue_corrections as rc
        on regexp_substr(c.description, '\\d+$') = rc.reservation_id
