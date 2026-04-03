select
    row_number() over (partition by bd.deposit_date, bd.memo, bd.amount order by bd.deposit_date) as rn,
    md5(bd.deposit_date || bd.memo || bd.amount || rn) as pk_bank_deposit_id,
    bd.deposit_date::date as deposit_date,
    bd.memo,
    bd.amount,
    bd.transaction_type_accounting,
    bd.bank,
    bd.file_name,
    bd.cash_flow_type,
    bd.deposit_month,
    bd.account_number,
    bd.department_id,
    bd.claim_number,
    bd.is_posted_to_sage,
    case
        when lower(bd.memo) regexp 'turo inc.*(turo inc|reversal).*'
            then 'claim'
        when memo like '%Turo Inc Vehicle So%' then 'claim'
        when
            regexp_like(lower(bd.memo), '^turo.*st-[a-z0-9]{12,}.*$') -- standard stripe payment
            -- these don't have the st-<id>, but appear to be payouts
            or regexp_like(lower(bd.memo), '^turo +8667352901 +(turo +[0-9]{12}[0-9]*|vehicle +so[0-9]+) *$')
            then 'rental revenue'
    end as transaction_type,
    case when bd.memo ilike '%turo%' then 'turo' end as platform,
    bd._es_update_timestamp
from {{ source('analytics_vehicle_solutions', 'bank_deposits') }} as bd
