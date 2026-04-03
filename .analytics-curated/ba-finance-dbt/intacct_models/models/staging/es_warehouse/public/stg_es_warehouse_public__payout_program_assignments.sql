select
    ppa.payout_program_assignment_id,
    ppa.asset_id,
    ppa.payout_program_id,
    ppa.start_date as date_start,
    coalesce(ppa.end_date, '9999-12-31'::timestamptz) as date_end,
    ppa.end_date is null as is_current,
    ppa.replaced_or_removed_reason,
    ppa.updated_by_user_id,
    ppa.payout_program_schedule_id,
    ppa.replaced_by_asset_id,
    ppa.payout_program_billing_type,
    ppa.date_updated,
    ppa._es_update_timestamp
from {{ source('es_warehouse_public', 'payout_program_assignments') }} as ppa
