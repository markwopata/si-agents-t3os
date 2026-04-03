{{ config(
    materialized='table'
    , cluster_by=['start_date', 'end_date', 'owner_company_id', 'rental_company_id']
) }}

WITH
    phases AS (
        SELECT
            o.job_id,
            o.order_id,
            o.company_id,
            r.rental_id,
            r.asset_id,
            j.name AS phase_job_name,
            j.job_id AS phase_job_id,
            jp.name AS job_name
        FROM
            {{ ref('platform', 'es_warehouse__public__orders') }} o
        LEFT JOIN {{ ref('platform', 'es_warehouse__public__rentals') }} r ON (r.order_id = o.order_id)
        JOIN {{ ref('platform', 'es_warehouse__public__jobs') }} j ON (j.job_id = o.job_id) AND j.parent_job_id IS NOT NULL
        LEFT JOIN {{ ref('platform', 'es_warehouse__public__jobs') }} jp ON (j.parent_job_id = jp.job_id)
        
        WHERE
            r.asset_id IS NOT NULL
            AND r.deleted = FALSE
            AND o.deleted = FALSE
            AND r.start_date >= DATEADD(day, -365, CURRENT_DATE())
    ),
    job_name_list AS (
        SELECT
            o.job_id,
            o.order_id,
            o.company_id,
            r.rental_id,
            r.asset_id,
            NULL AS phase_job_name,
            NULL AS phase_job_id,
            j.name AS job_name
        FROM
            {{ ref('platform', 'es_warehouse__public__orders') }} o
        LEFT JOIN {{ ref('platform', 'es_warehouse__public__rentals') }} r ON (r.order_id = o.order_id)
        JOIN {{ ref('platform', 'es_warehouse__public__jobs') }} j ON (j.job_id = o.job_id) AND j.parent_job_id IS NULL
        WHERE
            r.asset_id IS NOT NULL
            AND r.deleted = FALSE
            AND o.deleted = FALSE
            AND r.start_date >= DATEADD(day, -365, CURRENT_DATE())
    ), 
    jobs_list AS (
        SELECT * FROM phases
        UNION ALL
        SELECT * FROM job_name_list
    )
    , pre as (
SELECT
 DISTINCT
    o.order_id,
    o.company_id AS rental_company_id,
    a.company_id AS owner_company_id,
    rpcr.parent_company_id as rental_parent_company_id,
    rpc.name as rental_parent_company_name,
    opcr.parent_company_id as owner_parent_company_id,
    opc.name as owner_parent_company_name,
    r.rental_id,
   -- coalesce(l.nickname, NULL) as jobsite,
    coalesce(ea.asset_id, a.asset_id) as asset_id, 
    coalesce( ea.start_date, '1970-01-01') as start_date,
    coalesce(ea.end_date, '2999-12-31') as end_date,
    r.shift_type_id,
    o.SUB_RENTER_ID,
    c.company_id as SUB_RENTER_COMPANY_ID,
    c.name sub_renting_company,
    concat(u.first_name, ' ', u.last_name) as sub_renting_contact,
    o.job_id,
    jl.job_name,
    jl.phase_job_id,
    jl.phase_job_name
FROM
{{ ref('platform', 'es_warehouse__public__assets') }} a
LEFT JOIN {{ ref('platform', 'es_warehouse__public__rentals') }} r ON r.asset_id = a.asset_id
LEFT JOIN {{ ref('platform', 'es_warehouse__public__equipment_assignments') }} ea ON ea.rental_id = r.rental_id
LEFT JOIN es_warehouse.public.orders o ON r.order_id = o.order_id
left join es_warehouse.public.sub_renters sr on sr.sub_renter_id = o.sub_renter_id
left join es_warehouse.public.users u on sr.sub_renter_ordered_by_id = u.user_id
left join es_warehouse.public.companies c on sr.sub_renter_company_id = c.company_id
left join BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments rpcr on rpcr.company_id = o.company_id
left join es_warehouse.public.companies rpc on rpc.company_id = rpcr.parent_company_id
left join BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments opcr on opcr.company_id = o.company_id
left join es_warehouse.public.companies opc on opc.company_id = opcr.parent_company_id
LEFT JOIN jobs_list jl ON o.job_id = jl.job_id
WHERE a.asset_id IS NOT NULL
    and (r.rental_status_id not in (2,3,8) OR r.rental_id is null)
   ) 
    , max_days as (
    select pre.asset_id
    , max(end_date) as max_end 
    from pre
    group by pre.asset_id
    having max_end <= current_timestamp()
    order by max_end 
    )
    , pre2 as (
    select
    NULL as order_id,
    NULL as rental_company_id,
    a.company_id AS owner_company_id,
    NULL as rental_parent_company_id,
    NULL as rental_parent_company_name,
    opcr.parent_company_id as owner_parent_company_id,
    opc.name as owner_parent_company_name,
    NULL as rental_id,
   --NULL as jobsite,
    md.asset_id as asset_id, 
    md.max_end as start_date,
    '2999-12-31' as end_date,
    NULL as shift_type_id,
    NULL as SUB_RENTER_ID,
    NULL as SUB_RENTER_COMPANY_ID,
    NULL as sub_renting_company,
    NULL as sub_renting_contact,
    NULL as job_id,
    NULL as job_name,
    NULL as phase_job_id,
    NULL as phase_job_name
    from max_days md
    join es_warehouse.public.assets a on md.asset_id = a.asset_id
    left join BUSINESS_INTELLIGENCE.TRIAGE.stg_t3__national_account_assignments opcr on opcr.company_id = a.company_id
    left join es_warehouse.public.companies opc on opc.company_id = opcr.parent_company_id
    where a.deleted = false
    )
select *,
    CURRENT_TIMESTAMP()::timestamp_ntz AS data_refresh_timestamp 
    from pre
    
UNION
select *,
    CURRENT_TIMESTAMP()::timestamp_ntz AS data_refresh_timestamp
     from pre2
    where 1=1 and 2=2

