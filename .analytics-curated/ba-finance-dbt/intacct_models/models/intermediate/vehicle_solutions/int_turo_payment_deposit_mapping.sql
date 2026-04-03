with bank_deposits as (
    select
        bd.deposit_date,
        bd.amount,
        bd.memo,
        bd.pk_bank_deposit_id
    from {{ ref('stg_analytics_vehicle_solutions__bank_deposits') }} as bd
    where bd.transaction_type = 'rental revenue'
        and bd.platform = 'turo'
),

turo_earnings as (
    select distinct
        te.stripe_payout_id,
        te.batch_amount,
        te.bank_deposit_date
    from {{ ref('stg_analytics_vehicle_solutions__turo_earnings') }} as te
),

matched_deposits as (
    select
        te.stripe_payout_id,
        te.batch_amount,
        te.bank_deposit_date,
        bd.pk_bank_deposit_id,
        bd.deposit_date,
        abs(datediff('day', bd.deposit_date, te.bank_deposit_date)) as day_diff,
        row_number() over (
            partition by bd.pk_bank_deposit_id
            order by abs(datediff('day', bd.deposit_date, te.bank_deposit_date)), bd.deposit_date
        ) as payout_match_rank
    from bank_deposits as bd
        inner join turo_earnings as te
            on bd.amount = te.batch_amount
                and bd.deposit_date >= dateadd('day', -4, te.bank_deposit_date)
                and bd.deposit_date <= dateadd('day', 4, te.bank_deposit_date)
)

, clean_data_set as ( -- correctly includes all deposits by partitioning on pk_bank_deposit_id instead of stripe_payout_id

    select * from matched_deposits
    where payout_match_rank = 1
)

, dupe_stripe_payouts as ( -- identify any stripe dupe payouts

    select
        stripe_payout_id,
        batch_amount
    from clean_data_set
    group by
        all
    having count(*) > 1

)

, correct_stripe_payouts_from_dupes as ( -- get the corret stripe_payout_id by doing the same join as above

    select
        te.stripe_payout_id,
        te.batch_amount,
        te.bank_deposit_date,
        bd.pk_bank_deposit_id,
        bd.deposit_date,
        bd.memo,

        abs(datediff('day', bd.deposit_date, te.bank_deposit_date)) as day_diff,

        -- best payout per bank deposit
        row_number() over (
            partition by bd.pk_bank_deposit_id
            order by
                abs(datediff('day', bd.deposit_date, te.bank_deposit_date)),
                te.bank_deposit_date,
                te.stripe_payout_id
        ) as rn_per_deposit,

        -- best bank deposit per payout
        row_number() over (
            partition by te.stripe_payout_id
            order by
                abs(datediff('day', bd.deposit_date, te.bank_deposit_date)),
                bd.deposit_date,
                bd.pk_bank_deposit_id
        ) as rn_per_payout

    from turo_earnings te
    inner join bank_deposits bd
        on bd.amount = te.batch_amount
       and bd.deposit_date >= dateadd('day', -4, te.bank_deposit_date)
       and bd.deposit_date <= dateadd('day',  4, te.bank_deposit_date)

    where te.batch_amount in (select batch_amount from dupe_stripe_payouts)

)

, exclude_dupe_stripe_payouts as (

    select * 
    from clean_data_set
    where stripe_payout_id not in (
    select stripe_payout_id from dupe_stripe_payouts
    )
)
, corrected_dupes as ( -- janky

    select * from correct_stripe_payouts_from_dupes
    where (day_diff=0 and rn_per_payout =1)
    union all
    select * from correct_stripe_payouts_from_dupes
    where (day_diff=1 and rn_per_payout =2)

)
select
    stripe_payout_id,
    batch_amount,
    bank_deposit_date,
    pk_bank_deposit_id,
    deposit_date
from corrected_dupes

union all

select
    stripe_payout_id,
    batch_amount,
    bank_deposit_date,
    pk_bank_deposit_id,
    deposit_date
from exclude_dupe_stripe_payouts
