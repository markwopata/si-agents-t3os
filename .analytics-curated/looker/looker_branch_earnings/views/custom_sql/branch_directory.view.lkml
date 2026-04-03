view: branch_directory {
  derived_table: {
    sql:
      WITH manager_cte as (select cd.FIRST_NAME || ' ' || cd.LAST_NAME     as manager_name,
                            cd.EMPLOYEE_TITLE,
                            cd.EMPLOYEE_STATUS,
                            DEFAULT_COST_CENTERS_FULL_PATH           as cost_center,
                            split_part(cost_center, '/', 3)          as district,
                            left(split_part(cost_center, '/', 2), 2) as region_number,
                            case
                                when region_number = 'R1' then 'Pacific'
                                when region_number = 'R2' then 'Mountain West'
                                when region_number = 'R3' then 'Southwest'
                                when region_number = 'R4' then 'Midwest'
                                when region_number = 'R5' then 'Southeast'
                                when region_number = 'R6' then 'Northeast'
                                when region_number = 'R7' then 'Industrial'
                                else 'No Region' end                 as region,
      case
      when employee_title in
      ('District Operations Manager', 'District Operations manager',
      'District Manager', 'District Sales Manager')
      then district
      else null end as district_fixed
      from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
      where EMPLOYEE_STATUS = 'Active'
      and EMPLOYEE_TITLE in
      ('District Operations Manager', 'District Operations manager', 'District Manager',
      'Regional Director of Advanced Solutions', 'Regional Manager- Advanced Solutions',
      'Regional Director Of Advanced Solutions', 'Regional Director of Operations',
      'Regional Operations Director - Southwest', 'Regional Operations Director',
      'District Sales Manager', 'Regional Sales Manager', 'Regional Director of Sales',
      'Regional Advanced Solutions Sales Manager', 'Regional Sales Manager Advanced Solutions', 'Regional Operations Manager - Advanced Solutions','Regional Operations Manager- Advanced Solutions')
      and employee_id not in ('9272')),

      adv_solutions_cte as (select distinct region_name, region_district
from analytics.public.MARKET_REGION_XWALK
where market_type_id = 2
and market_id <> 125838),

      filtered_manager_cte as (select mc.manager_name,
      mc.employee_title,
      mc.region,
      case when mc.employee_title ilike '%Adv%' then asc.region_district else mc.district_fixed end as district
      from manager_cte mc
      left join adv_solutions_cte asc
      on to_varchar(mc.region) = to_varchar(asc.region_name)
      where mc.region <> 'No Region')

      select manager_name, employee_title, district, region
      from filtered_manager_cte
      {% if district._is_filtered and region._is_filtered %}
      where {% condition district %} district {% endcondition %}
      {% elsif district._is_filtered  %}
      where {% condition district %} district {% endcondition %}
      {% elsif region._is_filtered  %}
      where {% condition region %} region {% endcondition %}
      and district is null
      {% else %}
      where region is null
      {% endif %}


      ;;
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

  dimension: manager_name {
    label: "Manager"
    type: string
    sql: ${TABLE}."MANAGER_NAME" ;;
  }
  dimension: employee_title {
    label: "Title"
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

}
