with driver_coaching_management as (
    {{ generate_monday_table_from_column_map('7278220129') }}
)

select
    split_part(created_at, ' UTC', 1)::timestamp_ntz as created_at,
    employee_email,
    region,
    coaching_status,
    coaching_severity,
    primary_violation_type,
    secondary_violation_type,
    asset_id,
    vehicle_type,
    split(completed_form, ',\n') as completed_form_attachments,
    split_part(probation_period, ' - ', 1)::date as probation_start_date,
    split_part(probation_period, ' - ', 2)::date as probation_end_date,
    probation_days,
    coaching_due_date,
    coaching_completed_date,
    coach_name,
    manager_email,
    notes,
    total_weekly_points,
    previous_coaching_count,
    split(video, ',\n') as video_attachments
from driver_coaching_management
