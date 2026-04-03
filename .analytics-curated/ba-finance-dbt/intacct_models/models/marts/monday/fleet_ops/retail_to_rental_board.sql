with retail_to_rental_board_output as (
    {{ generate_monday_table_from_column_map('5364542893') }}
)

select
-- Explicitly name columns so schema changes break this model.

    mmb.item_id,
    mmb.branch_location_is_other,
    mmb.support_column_for_units,
    mmb.status_notes,
    mmb.vendor,
    mmb.msp_rsp,
    mmb.regional_manager,
    mmb.national_account_price,
    mmb.reason_for_denial,
    mmb.subitems,
    mmb.rental_in_30_days,
    mmb.avg_yard_30_day_utilization,
    mmb.additional_information,
    mmb.customer_name,
    mmb.ownership_updated,
    mmb.attachment_yes_or_no,
    mmb.ies_vendor_invoice,
    mmb.submitted_date,
    mmb.why_not_transfer,
    mmb.status_1,
    mmb.branch_location,
    mmb.rm_email,
    mmb.name,
    mmb.unit_photos,
    mmb.retail_oec,
    mmb.status,
    mmb.make_and_model,
    mmb.floor_plan_unit_or_paid_asset,
    mmb.credit_pdf,
    mmb.projected_rental_rate_per_30_days,
    mmb.people,
    mmb.finance_status_updated,
    mmb.length_of_rental_in_days,
    mmb.internally_transfer,
    mmb.retail_credit,
    mmb.rental_start_date,
    mmb.cat_class,
    mmb.ies_to_es_invoice,
    mmb.sales_rep_name_and_number
from retail_to_rental_board_output as mmb
