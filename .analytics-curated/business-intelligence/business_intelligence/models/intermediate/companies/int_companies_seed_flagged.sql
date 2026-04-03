select 
    company_id, company_name, 'deleted' as flag
    , _is_deleted, _created_recordtimestamp, _updated_recordtimestamp, _deleted_recordtimestamp
from {{ ref('stg_seed_companies__deleted') }}
where _is_deleted = false

UNION ALL

select 
    company_id, company_name, 'do_not_use' as flag
    , _is_deleted, _created_recordtimestamp, _updated_recordtimestamp, _deleted_recordtimestamp
from {{ ref('stg_seed_companies__do_not_use') }}
where _is_deleted = false

UNION ALL

select 
    company_id, company_name, 'duplicate' as flag
    , _is_deleted, _created_recordtimestamp, _updated_recordtimestamp, _deleted_recordtimestamp
from {{ ref('stg_seed_companies__duplicate') }}
where _is_deleted = false

UNION ALL

select 
    company_id, company_name, 'employee' as flag
    , _is_deleted, _created_recordtimestamp, _updated_recordtimestamp, _deleted_recordtimestamp
from {{ ref('stg_seed_companies__employees') }}
where _is_deleted = false

UNION ALL

select 
    company_id, company_name, 'es_internal' as flag
    , _is_deleted, _created_recordtimestamp, _updated_recordtimestamp, _deleted_recordtimestamp
from {{ ref('stg_seed_companies__es_internal') }}
where _is_deleted = false

UNION ALL

select 
    company_id, company_name, 'misc' as flag
    , _is_deleted, _created_recordtimestamp, _updated_recordtimestamp, _deleted_recordtimestamp
from {{ ref('stg_seed_companies__misc') }}
where _is_deleted = false

UNION ALL

select 
    company_id, company_name, 'prospect' as flag
    , _is_deleted, _created_recordtimestamp, _updated_recordtimestamp, _deleted_recordtimestamp
from {{ ref('stg_seed_companies__prospect') }}
where _is_deleted = false

UNION ALL

select 
    company_id, company_name, 'spam' as flag
    , _is_deleted, _created_recordtimestamp, _updated_recordtimestamp, _deleted_recordtimestamp
from {{ ref('stg_seed_companies__spam') }}
where _is_deleted = false

UNION ALL

select
    company_id, company_name, 'test' as flag
    , _is_deleted, _created_recordtimestamp, _updated_recordtimestamp, _deleted_recordtimestamp
from {{ ref('stg_seed_companies__test') }}
where _is_deleted = false