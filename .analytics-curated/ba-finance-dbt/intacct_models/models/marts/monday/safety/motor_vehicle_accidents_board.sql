with motor_vehicle_accidents_board as (
    {{ generate_monday_table_from_column_map('6101113463') }}
)

select
    item_id,
    retrain,
    location,
    subitems,
    send_to_slack,
    course_to_be_reassigned,
    employee_id,
    incident_type,
    vehicle_model,
    vehicle_type,
    market_id,
    at_fault,
    dot_board,
    dd_email,
    payer,
    driver_type,
    manager,
    days_at_es,
    incident_date,
    manager_email,
    root_cause,
    incident_time,
    type,
    safety_accountability_form,
    vehicle_make,
    employee_email,
    market_type,
    ten_by_ten,
    saf_request,
    incident_dow,
    description
from motor_vehicle_accidents_board
