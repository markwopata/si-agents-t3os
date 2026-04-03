select
    ece.employee_exception_id,
    ece.user_id,
    ece.start_date,
    ece.end_date,
    ece.exception_type_id,
    ece.override_rate
from {{ source('analytics_commission', 'employee_commission_exceptions') }} as ece
where ece.start_date != ece.end_date
