view: profit_share_managers {
  derived_table: {
    sql: with employee_changes_adj as (
        select EMPLOYEE_ID,
               cdv.MARKET_ID,
               mrx.MARKET_NAME,
               DEFAULT_COST_CENTERS_FULL_PATH,
               cdv.EMPLOYEE_TITLE as job_title,
               coalesce(cdv.DATE_REHIRED, cdv.DATE_HIRED) date_last_hired,
               row_number() over (partition by EMPLOYEE_ID order by _ES_UPDATE_TIMESTAMP desc) as rnk
        from analytics.PAYROLL.COMPANY_DIRECTORY_VAULT CDV
        left join MARKET_REGION_XWALK mrx
            on cdv.MARKET_ID = mrx.MARKET_ID
        where date_trunc(month, _ES_UPDATE_TIMESTAMP) = $period::date
    )
select
       cd.EMPLOYEE_ID || ' - ' || coalesce(cd.NICKNAME, cd.FIRST_NAME) || ' ' || cd.LAST_NAME   id_employee_name,
       coalesce(cd.NICKNAME,cd.FIRST_NAME) || ' ' || cd.LAST_NAME                               employee_name,
       cd.EMPLOYEE_ID                                                                           employee_id,
       cd.WORK_EMAIL                                                                            work_email,
       cd.PERSONAL_EMAIL                                                                        personal_email,
       eca_cc.job_title                                                                         employee_title,
       coalesce(eca_cc.DEFAULT_COST_CENTERS_FULL_PATH ,cd.DEFAULT_COST_CENTERS_FULL_PATH)       cost_center,
       date_last_hired,
       cd.DATE_TERMINATED                                                                       date_terminated,
       left(split_part(cost_center, '/', 1),2)                                                  region_number,
       case when region_number = 'R1' then 'Pacific'
            when region_number = 'R2' then 'Mountain West'
            when region_number = 'R3' then 'Southwest'
            when region_number = 'R4' then 'Midwest'
            when region_number = 'R5' then 'Southeast'
            when region_number = 'R6' then 'Northeast'
            when region_number = 'R7' then 'Industrial'
            else 'No Region' end                                                                region,
       split_part(cost_center, '/', 2)                                                          district,
       coalesce(eca_cc.MARKET_ID, cd.MARKET_ID)                                                 market_id,
       coalesce(eca_cc.MARKET_NAME, mrx.MARKET_NAME)                                            market_name,
       mrx.MARKET_TYPE
    from ANALYTICS.PAYROLL.COMPANY_DIRECTORY CD
            left join employee_changes_adj eca_cc
                       on cd.EMPLOYEE_ID = eca_cc.EMPLOYEE_ID
            left join analytics.public.MARKET_REGION_XWALK mrx
                       on cd.MARKET_ID::varchar = mrx.MARKET_ID::varchar
    where rnk = 1
    and EMPLOYEE_STATUS in ('Active') ;;
  }

dimension: id_name {
  label: "ID - Name"
  type: string
  sql: ${TABLE}."ID_EMPLOYEE_NAME" ;;
}

dimension: employee_name {
  label: "Employee Name"
  type: string
  sql: ${TABLE}."EMPLOYEE_NAME" ;;
}

dimension: id {
  label: "Employee ID"
  type: string
  sql: ${TABLE}."EMPLOYEE_ID" ;;
  primary_key: yes
}

dimension: employee_title {
  label: "Employee Title"
  type: string
  sql: ${TABLE}."EMPLOYEE_TITLE" ;;
}

dimension: date_last_hired {
  label: "Date Hired"
  type: string
  sql: tovarchar(${TABLE}."DATE_LAST_HIRED"::date, 'MMMM yyyy') ;;
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

dimension: market_name {
  label: "Market Name"
  type: string
  sql: ${TABLE}."MARKET_NAME" ;;
}

}
