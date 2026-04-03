{{ config(materialized="table", cluster_by=["company_id", "company"]) }}

with
    user_map as (
        select
            u.user_id,
            u.email_address,
            case
                when position(' ', coalesce(cd.nickname, cd.first_name)) = 0
                then concat(coalesce(cd.nickname, cd.first_name), ' ', cd.last_name)
                else
                    concat(
                        coalesce(cd.nickname, concat(cd.first_name, ' ', cd.last_name))
                    )
            end as name,
        from {{ ref("platform", "es_warehouse__public__users") }} u
        join {{ ref("stg_payroll__company_directory") }} cd
            on lower(u.email_address) = lower(cd.work_email)
        qualify row_number() over(partition by u.user_id order by
                                    case 
                                        when cd.employee_status ilike 'Active' then 0
                                        when cd.employee_status ilike 'Terminated' then 2
                                        else 1
                                    end
                                    , cd.employee_id desc
                                 ) = 1
    ),
    national_accounts as (
        select 
            bcp.company_id,
            bcp.prefs:managed_billing as managed_billing,
            bcp.prefs:general_services_administration as gsa
        from {{ ref("platform", "es_warehouse__public__billing_company_preferences") }} bcp
        where prefs:national_account = true
    ),
    parent_company_relationships as (
        select
            pcr.company_id,
            pcr.parent_company_id,
            pc.name as parent_company_name,
        from {{ source("analytics__bi_ops", "parent_company_relationships") }} pcr
        left join {{ ref("platform", "es_warehouse__public__companies") }} pc
            on pc.company_id = pcr.parent_company_id
        qualify
            row_number() over (
                partition by pcr.company_id order by record_created_timestamp desc
            )
            = 1
    ),
    commission_assignments as (
        select
            nca.company_id,
            nca.director_user_id as sales_director_user_id,
            COALESCE(dir_um.name, 'Unassigned') as sales_director,
            nca.nam_user_id as commissioned_nam_user_id,
            COALESCE(nam_um.name, 'Unassigned') as commissioned_nam,
            nam_um.email_address as commissioned_nam_email,
            COALESCE(nca.nam_user_id, parent_nca.nam_user_id) as effective_nam_user_id,
            /*case
                when nca.nam_user_id is not null then nam_um.name
                else
                    case
                    when pcr.parent_company_id is null then 'Unassigned NAM | No Parent Company Exists'
                    -- Parent exists but parent NAM is null
                    when parent_nca.nam_user_id is null then 'Unassigned NAM | Parent Company Has No NAM'
                    -- Parent exists and has a NAM
                    else 'Unassigned NAM | Parent Company NAM: ' || parent_nam_um.name
                end
            end as effective_nam,*/
            COALESCE(nam_um.name, parent_nam_um.name, 'Unassigned') as effective_nam,
            COALESCE(nam_um.email_address, parent_nam_um.email_address) as effective_nam_email
        from {{ ref("stg_analytics_commission__nam_company_assignments") }} nca
        left join user_map nam_um
            on nca.nam_user_id = nam_um.user_id
        left join user_map dir_um
            on nca.director_user_id = dir_um.user_id
        left join parent_company_relationships pcr
            on nca.company_id = pcr.company_id
        left join {{ ref("stg_analytics_commission__nam_company_assignments") }} parent_nca
            on pcr.parent_company_id = parent_nca.company_id
            and current_timestamp() between parent_nca.effective_start_date and parent_nca.effective_end_date
        left join user_map parent_nam_um
            on parent_nca.nam_user_id = parent_nam_um.user_id
        where current_timestamp() between nca.effective_start_date and nca.effective_end_date
    ),
    account_info as (
        select
            ai.company_id, 
            ai.region,
            ai.coordinator_user_id,
            coalesce(uc.name, 'Unassigned') as national_account_coordinator,
            ai.nac_2_user_id,
            coalesce(uc2.name, 'Unassigned') as nac_2,
            ai.nac_3_user_id,
            coalesce(uc3.name, 'Unassigned') as nac_3,
            ai.notes,
            coalesce(ai.account_folder_url, '') as account_folder_url
        from {{ source("analytics__bi_ops", "national_account_info") }} ai
        left join user_map uc on ai.coordinator_user_id = uc.user_id
        left join user_map uc2 on ai.nac_2_user_id = uc2.user_id
        left join user_map uc3 on ai.nac_3_user_id = uc3.user_id
        qualify
            row_number() over (
                partition by ai.company_id order by record_creation_date desc
            )
            = 1
    )
select
    na.company_id as company_id,
    c.name as company,
    pcr.parent_company_id,
    pcr.parent_company_name,
    ca.sales_director_user_id,
    ca.sales_director,
    ca.commissioned_nam_user_id,
    ca.commissioned_nam,
    ca.commissioned_nam_email,
    ca.effective_nam_user_id,
    ca.effective_nam,
    ca.effective_nam_email,
    ai.region,
    ai.coordinator_user_id,
    ai.national_account_coordinator,
    ai.nac_2_user_id,
    ai.nac_2,
    ai.nac_3_user_id,
    ai.nac_3,
    ai.notes,
    ai.account_folder_url,
    na.managed_billing,
    na.gsa
from national_accounts na
join {{ ref("platform", "es_warehouse__public__companies") }} c
    on na.company_id = c.company_id
left join parent_company_relationships pcr
    on na.company_id = pcr.company_id
left join commission_assignments ca
    on na.company_id = ca.company_id
left join account_info ai on na.company_id = ai.company_id
