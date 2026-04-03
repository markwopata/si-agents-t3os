with oec_by_month as (
    select
        odl.gl_date,
        odl.market_id,
        sum(odl.amount) as amount,
        sum(odl.equipment_charge) as equipment_charge,
        count(*) as asset_count
    from {{ ref('int_branch_earnings_oec_detail_looker') }} as odl
    group by all
)

select
    obm.gl_date,
    obm.market_id,
    round(obm.amount, 2) as amount,
    lag(obm.amount) over (partition by obm.market_id order by obm.gl_date) as previous_month_amount,
    round(obm.amount - previous_month_amount, 2) as amount_difference,
    round(obm.equipment_charge, 2) as equipment_charge,
    lag(obm.equipment_charge) over (partition by obm.market_id order by obm.gl_date) as previous_month_equipment_charge,
    round(obm.equipment_charge - previous_month_equipment_charge, 2) as equipment_charge_difference,
    obm.asset_count,
    lag(obm.asset_count) over (partition by obm.market_id order by obm.gl_date) as previous_month_asset_count,
    obm.asset_count - previous_month_asset_count as asset_count_difference
from oec_by_month as obm
