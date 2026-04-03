select
    dgu.employee_id::int as employee_id,
    dgu.disc_code,
    dgu.employee_status,
    dgu.external_id::int as external_id,
    dgu._es_update_timestamp
from {{ source('analytics_public', 'disc_gh_ukg') }} as dgu
where dgu.employee_id is not null
