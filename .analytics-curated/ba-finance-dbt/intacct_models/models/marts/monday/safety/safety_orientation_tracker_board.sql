with safety_orientation_tracker_board as (
    {{ generate_monday_table_from_column_map('8608020390') }}
)

select
    item_id,
    three_month_status,
    position_wd,
    duration_attended,
    post_orientation_email,
    region_wd,
    orientation_status,
    status,
    worker_s_manager_wd,
    report_effective_date_wd,
    first_name_wd,
    date_attended,
    name,
    last_name_wd,
    manager_email_wd,
    original_hire_date_wd,
    hire_date_wd,
    orientation_type,
    location_wd,
    esu_days_remaining,
    subitems,
    post_email_sent
from safety_orientation_tracker_board
