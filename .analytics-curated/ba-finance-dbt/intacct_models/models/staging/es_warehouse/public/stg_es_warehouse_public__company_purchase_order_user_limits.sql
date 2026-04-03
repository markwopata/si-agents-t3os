SELECT
    cpoul.company_purchase_order_user_limit_id,
    cpoul.user_id,
    cpoul.approval_limit,
    cpoul.can_change_reconciliation_status,
    cpoul.can_edit_line_asset_id_assignments,
    cpoul.can_edit_line_after_schedule_assignment,
    cpoul.can_edit_pending_schedule,
    cpoul.can_change_out_of_reconciliation,
    cpoul.can_edit_read_only_line,
    cpoul.can_change_out_of_financial_schedule,
    cpoul._es_update_timestamp
FROM {{ source('es_warehouse_public', 'company_purchase_order_user_limits') }} as cpoul
