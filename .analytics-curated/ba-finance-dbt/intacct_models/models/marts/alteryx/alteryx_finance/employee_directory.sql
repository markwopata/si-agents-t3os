with company_directory as (
    select * from {{ ref('stg_analytics_payroll__company_directory') }}
),

markets as (
    select * from {{ ref('stg_es_warehouse_public__markets') }}
),

managers_names as (
    select distinct
        cd.employee_id as manager_id,
        -- use full_name instead of nickname
        concat(cd.full_name, ' - ', cd.employee_id) as manager_name,
        lower(trim(cd.work_email)) as manager_email,
        cd.direct_manager_employee_id
    from company_directory as cd
),

renamed as (
    select
        company_directory.market_id as company_directory_market_id,
        markets.market_name as markets_market_name,
        company_directory.location as company_directory_location,
        company_directory.employee_title as company_directory_employee_title,
        company_directory.work_phone as company_directory_work_phone,
        company_directory.work_email as company_directory_work_email,
        markets.sales_email as markets_sales_email,
        markets.service_email as markets_service_email,
        mn.manager_name as managers_names_manager_name,
        mn.manager_email as managers_names_manager_email,
        to_char(
            to_date(
                case
                    when company_directory.date_rehired is not null
                        then company_directory.date_rehired
                    else company_directory.date_hired
                end
            ), 'yyyy-mm-dd'
        ) as company_directory_date_most_recent_hire_formatted_date,
        -- use full_name instead of nickname
        concat(manager_reports_to.full_name, ' - ', manager_reports_to.employee_id) as manager_reports_to_employee_name,
        split_part(company_directory.default_cost_centers_full_path, '/', 3) as company_directory_district,
        company_directory.default_cost_centers_full_path as company_directory_default_cost_centers_full_path,
        -- use full_name instead of nickname
        concat(company_directory.full_name, ' - ', company_directory.employee_id) as company_directory_employee_name_with_id,
        iff(
            split_part(company_directory.default_cost_centers_full_path, '/', 2) = 'Corp', 'Corporate',
            iff(
                split_part(company_directory.default_cost_centers_full_path, '/', 2) = 'R2 Mountain West', 'Mountain West',
                split_part(split_part(company_directory.default_cost_centers_full_path, '/', 2), ' ', 2)
            )
        ) as company_directory_region_clean
    from company_directory
left join managers_names mn
    on company_directory.direct_manager_employee_id = mn.manager_id
    left join company_directory as manager_reports_to
        on mn.direct_manager_employee_id = manager_reports_to.employee_id
    left join markets
        on company_directory.market_id = markets.market_id
    where
        (
            upper(
                -- use full_name instead of nickname
                concat(company_directory.full_name, ' - ', company_directory.employee_id)
            ) not like upper('%test employee%')
            or
            concat(company_directory.full_name, ' - ', company_directory.employee_id) is null
        )
        and company_directory.employee_status not in ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
        and (
            company_directory.work_email like '%equipmentshare.com%'
            or company_directory.work_email like '%forgeandbuild.com%'
        )
        and cast(company_directory.date_hired as timestamp_ntz) <= current_date
    group by
        to_date(
            case
                when company_directory.date_rehired is not null
                    then company_directory.date_rehired
                else company_directory.date_hired
            end
        ),
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
    order by company_directory_employee_name_with_id
)
select 
    company_directory_employee_name_with_id as employee_name,
    company_directory_work_email as work_email,
    company_directory_market_id as market_id,
    markets_market_name as market_name,
    company_directory_location as location,
    company_directory_employee_title as job_title,
    company_directory_date_most_recent_hire_formatted_date as date_hired,
    company_directory_work_phone as work_phone,
    markets_sales_email as sales_front_email,
    markets_service_email as service_front_email,
    managers_names_manager_name as manager_name,
    managers_names_manager_email as manager_email,
    manager_reports_to_employee_name as manager_reports_to,
    company_directory_district as district,
    company_directory_region_clean as region,
    company_directory_default_cost_centers_full_path as full_cost_center
from renamed
