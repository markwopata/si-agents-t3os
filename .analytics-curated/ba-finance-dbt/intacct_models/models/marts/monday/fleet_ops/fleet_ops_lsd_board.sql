with fleet_ops_lsd_board_output as (
    {{ generate_monday_table_from_column_map('6737047445') }}
)

select
-- Explicitly name columns so schema changes break this model.

     mmb.item_id,
    mmb.serial_number,
    mmb.fleet_inbox,
    mmb.days_since_quote_sent,
    mmb.customer_name,
    mmb.lsd_insurance,
    mmb.customer_quote_needed,
    mmb.total_days,
    mmb.today,
    mmb.customer_signed_quote,
    mmb.fmv_quote,
    mmb.sales_invoice_number,
    mmb.make,
    mmb.model,
    mmb.date_complete,
    mmb.date_of_incident,
    mmb.assets_owner,
    mmb.gm_email,
    mmb.fmv_needed,
    mmb.documents_and_photos,
    mmb.tam_email,
    mmb.person,
    mmb.overall_status,
    mmb.name,
    mmb.ins_file_notes,
    mmb.report_date,
    mmb.location_of_incident,
    mmb.non_insurance_status,
    mmb.type_of_loss,
    mmb.asset_year,
    mmb.customer_quote,
    mmb.sales_invoice_status,
    mmb.yard_location,
    mmb.date_customer_quote_sent_to_yard,
    mmb.subitems
from fleet_ops_lsd_board_output as mmb
