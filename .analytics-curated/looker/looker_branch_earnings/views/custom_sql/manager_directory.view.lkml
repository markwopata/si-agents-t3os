view: manager_directory {
 derived_table: {
   sql: with district_ops_manager_cte as (
    select cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as dm_name,
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
      and EMPLOYEE_TITLE in ('District Operations Manager', 'District Manager',
                             'Regional Director of Advanced Solutions', 'Regional Manager- Advanced Solutions',
                             'Regional Director Of Advanced Solutions')
),
     district_sales_manager_cte as (
         select cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as dsm_name,
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
         select cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as rm_name,
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
           and EMPLOYEE_TITLE in ('Regional Director of Operations', 'Regional Operations Director - Southwest')
     ),
     region_sales_manager_cte as (
         select cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as rsm_name,
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
           and EMPLOYEE_TITLE in ('Regional Sales Manager', 'Regional Director of Sales')
           and EMPLOYEE_ID not in ('9272')
     ),
     regional_advanced_solutions_ops_manager_cte as (
         select cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as ras_ops_name,
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
         select cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as ras_sales_name,
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
         select cd.EMPLOYEE_ID || ' - ' || cd.FIRST_NAME || ' ' || cd.LAST_NAME as rfm_name,
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
select distinct mrx.REGION_NAME,
                mrx.REGION_DISTRICT,
                coalesce(dm.dm_name, raso.ras_ops_name)     dm_ras_ops_name,
                coalesce(dsm.dsm_name, rass.ras_sales_name) dsm_ras_sales_name,
                rm.rm_name,
                rsm.rsm_name
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
    and mrx.MARKET_NAME not ilike '%tool trailer%') ;;
 }

  filter: display {
    type: string
    suggestions: [
      "January 2021","February 2021","March 2021","April 2021","May 2021","June 2021","July 2021","August 2021","September 2021","October 2021","November 2021","December 2021",
      "January 2022","February 2022","March 2022","April 2022","May 2022","June 2022", "July 2022","August 2022","September 2022","October 2022","November 2022","December 2022"
    ]
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: id_employee_name {
    label: "ID - Name"
    type: string
    sql: ${TABLE}."ID_EMPLOYEE_NAME" ;;
  }

  dimension: employee_name {
    label: "Employee Name"
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }

  dimension: employee_id {
    primary_key: yes
    label: "Employee ID"
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: work_email {
    label: "Work Email"
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: personal_email {
    label: "Personal Email"
    type: string
    sql: ${TABLE}."PERSONAL_EMAIL" ;;
  }

  dimension: employee_title {
    label: "Employee Title"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: employee_title_classification {
    label: "Employee Title Classification"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE_CLASSIFICATION" ;;
  }

  dimension: cost_center {
    label: "Cost Center"
    type: string
    sql: ${TABLE}."COST_CENTER" ;;
  }

  dimension: date_last_hired {
    label: "Date Last Hired"
    type: string
    sql: ${TABLE}."DATE_LAST_HIRED" ;;
  }

  dimension: date_terminated {
    label: "Termination Date"
    type: string
    sql: ${TABLE}."DATE_TERMINATED" ;;
  }

  dimension: region_number {
    hidden: yes
    sql: ${TABLE}."REGION_NUMBER" ;;
  }

  dimension: region {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id1 {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID1" ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    label: "Market Type"
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: pay_calc {
    label: "Pay Type"
    type: string
    sql: ${TABLE}."PAY_CALC" ;;
  }

  dimension: district_ops_manager {
    label: "District Operations Manager"
    type: string
    sql: case when ${employee_title_classification} = 'District Operations Manager' then ${employee_name} else null end ;;
  }

  dimension: distric_sales_manager{
    label: "District Sales Manager"
    type: string
    sql: case when ${employee_title_classification} = 'District Sales Manager' then ${employee_name} else null end ;;
  }

  dimension: regional_ops_manager {
    label: "Regional Operations Manager"
    type: string
    sql: case when ${employee_title_classification} = 'Regional Operations Manager' then ${employee_name} else null end ;;
  }

  dimension: regional_sales_manager {
    label: "Regional Sales Manager"
    type: string
    sql: case when ${employee_title_classification} = 'Regional Sales Manager' then ${employee_name} else null end ;;
  }

  dimension: regional_as_ops_manager {
    label: "Regional Advanced Solutions Operations Manager"
    type: string
    sql: case when ${employee_title_classification} = 'Regional Advanced Solutions Operations Manager' then ${employee_name} else null end ;;
  }



}
