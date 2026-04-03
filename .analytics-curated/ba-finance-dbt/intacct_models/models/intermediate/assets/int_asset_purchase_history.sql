select
    aphl.asset_id,
    aphl.date_generated as date_start,
    coalesce(lead(aphl.date_generated)
        over (
            partition by aphl.asset_id
            order by aphl.date_generated
        ), '2099-12-31'::timestamptz) as date_end,
    aphl.finance_status,
    aphl.financial_schedule_id,
    aphl.po_number,
    round(coalesce(aphl.oec, aphl.purchase_price), 2) as oec,
    aphl.purchase_history_id
from {{ ref("stg_es_warehouse_public__asset_purchase_history_logs") }} as aphl
where
    -- Data before August 2020 is not reliable. See #ba-team thread
    --  for more information: https://equipmentshare.slack.com/archives/GJUE5B355/p1742588322464839
    aphl.date_generated >= '2020-08-01'
