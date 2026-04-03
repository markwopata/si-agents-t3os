select
    ps.project_status_id,
    ps.name,
    ps.description,
    ps.date_created,
    ps.created_by,
    ps.date_updated,
    ps.updated_by
from {{ source('analytics_retool', 'cip_project_statuses') }} as ps
