select
    d.department_id,
    d.department_name,
    d.department_status
from 
    {{ ref('stg_analytics_intacct__department') }} as d
where 
    d.department_status = 'active'
