with combined as (
    select
        p.arrival_date as bank_statement_date,
        date_trunc(month, p.arrival_date) as period_start_date,
        p.amount as total_payout_amount,
        p.id as payout_id,
        bt.description as balance_transaction_description,
        bt.type as balance_transaction_type,
        bt.reporting_category,
        bt.created as balance_transaction_date,
        bt.amount,
        bt.fee_amount,
        bt.net_amount,
        bt.source,
        coalesce(c.reservation_id, c_d.reservation_id, c_r.reservation_id) as reservation_id,
        coalesce(c.platform_id, c_d.platform_id, c_r.platform_id) as prefixed_id,
        'resla.com' as stripe_account
    from {{ ref('stg_analytics_stripe_vsg_resla_com__payout') }} as p
        inner join {{ ref('stg_analytics_stripe_vsg_resla_com__payout_balance_transaction') }} as pbt
            on p.id = pbt.payout_id
        inner join {{ ref('stg_analytics_stripe_vsg_resla_com__balance_transaction') }} as bt
            on pbt.balance_transaction_id = bt.id
                and bt.type != 'payout'
        left join {{ ref('stg_analytics_stripe_vsg_resla_com__charge') }} as c
            on bt.source = c.id
        left join {{ ref('stg_analytics_stripe_vsg_resla_com__dispute') }} as d
            on bt.source = d.id
        left join {{ ref('stg_analytics_stripe_vsg_resla_com__charge') }} as c_d
            on d.charge_id = c_d.id
        left join {{ ref('stg_analytics_stripe_vsg_resla_com__refund') }} as r
            on bt.source = r.id
        left join {{ ref('stg_analytics_stripe_vsg_resla_com__charge') }} as c_r
            on r.charge_id = c_r.id

    union all

    select
        p.arrival_date as bank_statement_date,
        date_trunc(month, p.arrival_date) as period_start_date,
        p.amount as total_payout_amount,
        p.id as payout_id,
        bt.description as balance_transaction_description,
        bt.type as balance_transaction_type,
        bt.reporting_category,
        bt.created as balance_transaction_date,
        bt.amount,
        bt.fee_amount,
        bt.net_amount,
        bt.source,
        null as reservation_id,
        null as prefixed_id,
        'standard fleet reimbursements' as stripe_account
    from {{ ref('stg_analytics_stripe_vsg_charge_key__payout') }} as p
        inner join {{ ref('stg_analytics_stripe_vsg_charge_key__payout_balance_transaction') }} as pbt
            on p.id = pbt.payout_id
        inner join {{ ref('stg_analytics_stripe_vsg_charge_key__balance_transaction') }} as bt
            on pbt.balance_transaction_id = bt.id
                and bt.type != 'payout'
        left join {{ ref('stg_analytics_stripe_vsg_charge_key__charge') }} as c
            on bt.source = c.id
        left join {{ ref('stg_analytics_stripe_vsg_charge_key__dispute') }} as d
            on bt.source = d.id
        left join {{ ref('stg_analytics_stripe_vsg_charge_key__charge') }} as c_d
            on d.charge_id = c_d.id
        left join {{ ref('stg_analytics_stripe_vsg_charge_key__refund') }} as r
            on bt.source = r.id
        left join {{ ref('stg_analytics_stripe_vsg_charge_key__charge') }} as c_r
            on r.charge_id = c_r.id

    union all

    select
        p.arrival_date as bank_statement_date,
        date_trunc(month, p.arrival_date) as period_start_date,
        p.amount as total_payout_amount,
        p.id as payout_id,
        bt.description as balance_transaction_description,
        bt.type as balance_transaction_type,
        bt.reporting_category,
        bt.created as balance_transaction_date,
        bt.amount,
        bt.fee_amount,
        bt.net_amount,
        bt.source,
        null as reservation_id,
        coalesce(
            c.metadata__prefixed_id, c_d.metadata__prefixed_id,
            c_r.metadata__prefixed_id
        ) as prefixed_id,
        'hq rental' as stripe_account
    from {{ ref('stg_analytics_stripe_vehicle_solutions__payout') }} as p
        inner join {{ ref('stg_analytics_stripe_vehicle_solutions__payout_balance_transaction') }} as pbt
            on p.id = pbt.payout_id
        inner join {{ ref('stg_analytics_stripe_vehicle_solutions__balance_transaction') }} as bt
            on pbt.balance_transaction_id = bt.id
                and bt.type != 'payout'
        left join {{ ref('stg_analytics_stripe_vehicle_solutions__charge') }} as c
            on bt.source = c.id
        left join {{ ref('stg_analytics_stripe_vehicle_solutions__dispute') }} as d
            on bt.source = d.id
        left join {{ ref('stg_analytics_stripe_vehicle_solutions__charge') }} as c_d
            on d.charge_id = c_d.id
        left join {{ ref('stg_analytics_stripe_vehicle_solutions__refund') }} as r
            on bt.source = r.id
        left join {{ ref('stg_analytics_stripe_vehicle_solutions__charge') }} as c_r
            on r.charge_id = c_r.id
)

select * from combined
