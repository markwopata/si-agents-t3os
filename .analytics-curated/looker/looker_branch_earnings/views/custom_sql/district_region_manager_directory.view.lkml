view: district_region_manager_directory {
derived_table: {
  sql:
  with district_ops_manager_cte as (
    select cd.EMPLOYEE_ID                                                  as employee_id,
           cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as dm_name,
           cd.WORK_EMAIL,
           cd.EMPLOYEE_TITLE,
           cd.EMPLOYEE_STATUS,
           DEFAULT_COST_CENTERS_FULL_PATH                                  as cost_center,
           split_part(cost_center, '/', 3)                                 as district,
           left(split_part(cost_center, '/', 2), 2)                        as region_number,
           case
               when region_number = 'R1' then 'Pacific'
               when region_number = 'R2' then 'Mountain West'
               when region_number = 'R3' then 'Southwest'
               when region_number = 'R4' then 'Midwest'
               when region_number = 'R5' then 'Southeast'
               when region_number = 'R6' then 'Northeast'
               when region_number = 'R7' then 'Industrial'
               else 'No Region' end                                        as region
    from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
    where EMPLOYEE_STATUS = 'Active'
      and EMPLOYEE_TITLE in ('District Operations Manager', 'District Operations manager', 'District Manager',
                             'Regional Director of Advanced Solutions', 'Regional Manager- Advanced Solutions',
                             'Regional Director Of Advanced Solutions')
),
     district_sales_manager_cte as (
         select cd.EMPLOYEE_ID                                                  as employee_id,
                cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as dsm_name,
                cd.WORK_EMAIL,
                cd.EMPLOYEE_TITLE,
                cd.EMPLOYEE_STATUS,
                DEFAULT_COST_CENTERS_FULL_PATH                                  as cost_center,
                split_part(cost_center, '/', 3)                                 as district,
                left(split_part(cost_center, '/', 2), 2)                        as region_number,
                case
                    when region_number = 'R1' then 'Pacific'
                    when region_number = 'R2' then 'Mountain West'
                    when region_number = 'R3' then 'Southwest'
                    when region_number = 'R4' then 'Midwest'
                    when region_number = 'R5' then 'Southeast'
                    when region_number = 'R6' then 'Northeast'
                    when region_number = 'R7' then 'Industrial'
                    else 'No Region' end                                        as region
         from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
         where EMPLOYEE_STATUS = 'Active'
           and EMPLOYEE_TITLE in ('District Sales Manager')
     ),
     region_ops_manager_cte as (
         select cd.EMPLOYEE_ID                                                  as employee_id,
                cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as rm_name,
                cd.WORK_EMAIL,
                cd.EMPLOYEE_TITLE,
                cd.EMPLOYEE_STATUS,
                DEFAULT_COST_CENTERS_FULL_PATH                                  as cost_center,
                split_part(cost_center, '/', 3)                                 as district,
                left(split_part(cost_center, '/', 2), 2)                        as region_number,
                case
                    when region_number = 'R1' then 'Pacific'
                    when region_number = 'R2' then 'Mountain West'
                    when region_number = 'R3' then 'Southwest'
                    when region_number = 'R4' then 'Midwest'
                    when region_number = 'R5' then 'Southeast'
                    when region_number = 'R6' then 'Northeast'
                    when region_number = 'R7' then 'Industrial'
                    else 'No Region' end                                        as region

         from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
         where EMPLOYEE_STATUS = 'Active'
           and EMPLOYEE_TITLE in ('Regional Director of Operations', 'Regional Operations Director - Southwest','Regional Operations Director')
     ),
     region_sales_manager_cte as (
         select cd.EMPLOYEE_ID                                                  as employee_id,
                cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as rsm_name,
                cd.WORK_EMAIL,
                cd.EMPLOYEE_TITLE,
                cd.EMPLOYEE_STATUS,
                DEFAULT_COST_CENTERS_FULL_PATH                                  as cost_center,
                split_part(cost_center, '/', 3)                                 as district,
                left(split_part(cost_center, '/', 2), 2)                        as region_number,
                case
                    when region_number = 'R1' then 'Pacific'
                    when region_number = 'R2' then 'Mountain West'
                    when region_number = 'R3' then 'Southwest'
                    when region_number = 'R4' then 'Midwest'
                    when region_number = 'R5' then 'Southeast'
                    when region_number = 'R6' then 'Northeast'
                    when region_number = 'R7' then 'Industrial'
                    else 'No Region' end                                        as region

         from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
         where EMPLOYEE_STATUS = 'Active'
           and EMPLOYEE_TITLE in ('Regional Sales Manager', 'Regional Director of Sales', 'Regional Sales Director')
           and EMPLOYEE_ID not in ('9272','10199')
     ),
     regional_advanced_solutions_ops_manager_cte as (
         select cd.EMPLOYEE_ID                                                  as employee_id,
                cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as ras_ops_name,
                cd.WORK_EMAIL,
                cd.EMPLOYEE_TITLE,
                cd.EMPLOYEE_STATUS,
                DEFAULT_COST_CENTERS_FULL_PATH                                  as cost_center,
                split_part(cost_center, '/', 3)                                 as district_number,
                left(split_part(cost_center, '/', 2), 2)                        as region_number,
                case
                    when region_number = 'R1' then 'Pacific'
                    when region_number = 'R2' then 'Mountain West'
                    when region_number = 'R3' then 'Southwest'
                    when region_number = 'R4' then 'Midwest'
                    when region_number = 'R5' then 'Southeast'
                    when region_number = 'R6' then 'Northeast'
                    when region_number = 'R7' then 'Industrial'
                    else 'No Region' end                                        as region,
                case
                    when region_number = 'R1' then '1-4'
                    when region_number = 'R2' then '2-3'
                    when region_number = 'R3' then '3-5'
                    when region_number = 'R4' then '4-5'
                    when region_number = 'R5' then '5-4'
                    when region_number = 'R6' then '6-4'
                    when region_number = 'R7' then '7-4'
                    else 'No District' end                                      as district
         from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
         where EMPLOYEE_STATUS = 'Active'
           and EMPLOYEE_TITLE in ('Regional Director of Advanced Solutions', 'Regional Manager- Advanced Solutions',
                                  'Regional Director Of Advanced Solutions')
     ),
     regional_advanced_solutions_sales_manager_cte as (
         select cd.EMPLOYEE_ID                                                  as employee_id,
                cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as ras_sales_name,
                cd.WORK_EMAIL,
                cd.EMPLOYEE_TITLE,
                cd.EMPLOYEE_STATUS,
                DEFAULT_COST_CENTERS_FULL_PATH                                  as cost_center,
                split_part(cost_center, '/', 3)                                 as district_number,
                left(split_part(cost_center, '/', 2), 2)                        as region_number,
                case
                    when region_number = 'R1' then 'Pacific'
                    when region_number = 'R2' then 'Mountain West'
                    when region_number = 'R3' then 'Southwest'
                    when region_number = 'R4' then 'Midwest'
                    when region_number = 'R5' then 'Southeast'
                    when region_number = 'R6' then 'Northeast'
                    when region_number = 'R7' then 'Industrial'
                    else 'No Region' end                                        as region,
                case
                    when region_number = 'R1' then '1-4'
                    when region_number = 'R2' then '2-3'
                    when region_number = 'R3' then '3-5'
                    when region_number = 'R4' then '4-5'
                    when region_number = 'R5' then '5-4'
                    when region_number = 'R6' then '6-4'
                    when region_number = 'R7' then '7-4'
                    else 'No District' end                                      as district

         from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
         where EMPLOYEE_STATUS = 'Active'
           and EMPLOYEE_TITLE in
               ('Regional Advanced Solutions Sales Manager', 'Regional Sales Manager Advanced Solutions')
     ),
     regional_fleet_manager_cte as (
         select cd.EMPLOYEE_ID                                                  as employee_id,
                cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as rfm_name,
                cd.WORK_EMAIL,
                cd.EMPLOYEE_TITLE,
                cd.EMPLOYEE_STATUS,
                DEFAULT_COST_CENTERS_FULL_PATH                                  as cost_center,
                split_part(cost_center, '/', 3)                                 as district,
                left(split_part(cost_center, '/', 2), 2)                        as region_number,
                case
                    when region_number = 'R1' then 'Pacific'
                    when region_number = 'R2' then 'Mountain West'
                    when region_number = 'R3' then 'Southwest'
                    when region_number = 'R4' then 'Midwest'
                    when region_number = 'R5' then 'Southeast'
                    when region_number = 'R6' then 'Northeast'
                    when region_number = 'R7' then 'Industrial'
                    else 'No Region' end                                        as region

         from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
         where EMPLOYEE_STATUS = 'Active'
           and EMPLOYEE_TITLE in ('Fleet Manager', 'Fleet Manager Southwest', 'Fleet Manager Southeast')
     ),
     market_goal_flag as (
         select MARKET_ID,
                name,
                case
                    when REVENUE_GOALS >= 0 then 'Yes'
                    else 'No' end as market_goal_flag

         from ANALYTICS.PUBLIC.MARKET_GOALS mg
         where DATE_TRUNC(month, MONTHS)::date = '2023-12-01'
     )
select distinct mrx.REGION                                  as region_number,
                mrx.REGION_NAME,
                mrx.region||' - '||mrx.region_name          as region_num_name,
                mrx.REGION_DISTRICT,
                coalesce(dm.employee_id, raso.employee_id)  as dm_ras_ops_ee_id,
                coalesce(dm.dm_name, raso.ras_ops_name)     as dm_ras_ops_name,
                coalesce(dm.work_email, raso.work_email)    as dm_ras_ops_email,
                coalesce(dsm.employee_id, rass.employee_id) as dsm_ras_sales_ee_id,
                coalesce(dsm.dsm_name, rass.ras_sales_name) as dsm_ras_sales_name,
                coalesce(dsm.work_email, rass.work_email)   as dsm_ras_sales_email,
                rm.employee_id                              as rm_ee_id,
                rm.rm_name,
                rm.work_email                               as rm_email,
                rsm.employee_id                             as rsm_ee_id,
                rsm.rsm_name,
                rsm.work_email                              as rsm_email
from MARKET_REGION_XWALK mrx
         left join market_goal_flag mgf
                   on mrx.MARKET_ID = mgf.MARKET_ID
         left join ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE ro
                   on mrx.MARKET_ID = ro.MARKET_ID
         left join district_ops_manager_cte dm
                   on mrx.REGION_DISTRICT = dm.district
         left join district_sales_manager_cte dsm
                   on mrx.REGION_DISTRICT = dsm.district
         left join region_ops_manager_cte rm
                   on upper(mrx.REGION_NAME) = upper(rm.region)
         left join region_sales_manager_cte rsm
                   on upper(mrx.REGION_NAME) = upper(rsm.region)
         left join regional_advanced_solutions_ops_manager_cte raso
                   on upper(mrx.REGION_DISTRICT) = upper(raso.district)
         left join regional_advanced_solutions_sales_manager_cte rass
                   on upper(mrx.REGION_DISTRICT) = upper(rass.district)
         left join regional_fleet_manager_cte rfm
                   on upper(mrx.REGION_NAME) = upper(rfm.region)
where (mrx.MARKET_NAME not ilike '%retail%'
    and mrx.MARKET_NAME not ilike '%onsite%'
    and mrx.MARKET_NAME not ilike '%tool trailer%')
order by REGION_DISTRICT;;
}

  dimension: region_number {
    label: "Region Number"
    type: string
    sql: ${TABLE}."REGION_NUMBER" ;;
  }

  dimension: region_name {
    label: "Region Name"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: region_num_name {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NUM_NAME" ;;
  }

  dimension: region_link {
    type: string
    link: {
      label: "High Level Dashboard"
      url: "@{db_district_region_manager_directory}?Region+Name={{ filterable_value }}"
    }
    link: {
      label: "Branch Earnings Dashboard"
      url: "@{db_branch_earnings_dashboard}?Region+Name={{ ['district_region_manager_directory.region_name'] | url_encode }}"
    }
    sql: ${TABLE}."REGION_NUM_NAME" ;;
  }

  dimension: region_district {
    label: "District"
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: district_link {
    type: string
    link: {
      label: "High Level Dashboard"
      url: "@{db_district_region_manager_directory}?District={{ filterable_value }}"
    }
    link: {
      label: "Branch Earnings Dashboard"
      url: "@{db_branch_earnings_dashboard}?District+Number={{ filterable_value }}"
    }
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: dm_ras_ops_ee_id {
    label: "District Ops/Regional AS Ops Employee Id"
    type: number
    sql: ${TABLE}."DM_RAS_OPS_EE_ID" ;;
  }

  dimension: dm_ras_ops_name {
    label: "District Ops/Regional AS Ops Manager"
    type: string
    sql: ${TABLE}."DM_RAS_OPS_NAME" ;;
    # link: {
    #   label: "Greenhouse Profile"
    #   url: "{{ hr_greenhouse_link.greenhouse_link }}"
    # }
    # link: {
    #   label: "DISC Profile ({{ disc_master.environment_style.value }})"
    #   url: "http://www.discoveryreport.com/v/{{disc_master.disc_code._value}}"
    # }
    # html: <span title={{value}}>{{linked_value}}</span> ;;
  }

  dimension: dm_ras_ops_email {
    label: "District Ops/Regional AS Ops Email"
    type: string
    sql: ${TABLE}."DM_RAS_OPS_EMAIL" ;;
  }

  dimension: dsm_ras_sales_ee_id {
    label: "District Sales/Regional AS Sales Employee ID"
    type: number
    sql: ${TABLE}."DSM_RAS_SALES_EE_ID" ;;
  }

  dimension: dsm_ras_sales_name {
    label: "District Sales/Regional AS Sales Manager"
    type: string
    sql: ${TABLE}."DSM_RAS_SALES_NAME" ;;
    # link: {
    #   label: "Greenhouse Profile"
    #   url: "{{ hr_greenhouse_link.greenhouse_link }}"
    # }
    # link: {
    #   label: "DISC Profile ({{ disc_master.environment_style.value }})"
    #   url: "http://www.discoveryreport.com/v/{{disc_master.disc_code._value}}"
    # }
    # html: <span title={{value}}>{{linked_value}}</span> ;;
  }


  dimension: dsm_ras_sales_email {
    label: "District Sales/Regional AS Sales Email"
    type: string
    sql: ${TABLE}."DSM_RAS_SALES_EMAIL" ;;
  }

  dimension: rm_ee_id {
    label: "Regional Ops Employee ID"
    type: number
    sql: ${TABLE}."RM_EE_ID" ;;
  }

  dimension: rm_name {
    label: "Regional Ops Manager"
    type: string
    sql: ${TABLE}."RM_NAME" ;;
    # link: {
    #   label: "Greenhouse Profile"
    #   url: "{{ hr_greenhouse_link.greenhouse_link }}"
    # }
    # link: {
    #   label: "DISC Profile ({{ disc_master.environment_style.value }})"
    #   url: "http://www.discoveryreport.com/v/{{disc_master.disc_code._value}}"
    # }
    # html: <span title={{value}}>{{linked_value}}</span> ;;
  }


  dimension: rm_email {
    label: "Regional Ops Email"
    type: string
    sql: ${TABLE}."RM_EMAIL" ;;
  }

  dimension: rsm_ee_id {
    label: "Regiona Sales Employee ID"
    type: number
    sql: ${TABLE}."RSM_EE_ID" ;;
  }

  dimension: rsm_name {
    label: "Regional Sales Manager"
    type: string
    sql: ${TABLE}."RSM_NAME" ;;
    # link: {
    #   label: "Greenhouse Profile"
    #   url: "{{ hr_greenhouse_link.greenhouse_link }}"
    # }
    # link: {
    #   label: "DISC Profile ({{ disc_master.environment_style.value }})"
    #   url: "http://www.discoveryreport.com/v/{{disc_master.disc_code._value}}"
    # }
    # html: <span title={{value}}>{{linked_value}}</span> ;;
  }


  dimension: rsm_email {
    label: "Regional Sales Email"
    type: string
    sql: ${TABLE}."RSM_EMAIL" ;;
  }


  set: detail {
    fields: [
      region_name,
      region_district,
      dm_ras_ops_name,
      dsm_ras_sales_name,
      rm_name,
      rsm_name
    ]
  }




}
