with msha_intake_reporting_board as (
    {{ generate_monday_table_from_column_map('9167854430') }}
)

select
    item_id,
    end_time,
    submission_link,
    manager_email,
    part_46_or_48,
    mine_site_type,
    mine_site_activity,
    mine_site_name,
    mine_site_visit_date,
    creation_log,
    name,
    start_time,
    training_upload,
    mine_site_hours_worked,
    digital_jsa_submission,
    hours_worked_upload
from msha_intake_reporting_board
