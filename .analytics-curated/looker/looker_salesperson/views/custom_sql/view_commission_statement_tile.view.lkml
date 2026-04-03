view: view_commission_statement_tile {
  derived_table: {
    sql:   WITH RECURSIVE
      directory AS (
                       SELECT cd.first_name,
                              cd.last_name,
                              cd.employee_title,
                              cd.employee_id,
                              IFF(cd.employee_id = 103, NULL, cd.direct_manager_employee_id) AS manager_id,
                              m.work_email                                                   AS manager_email
                         FROM analytics.payroll.company_directory cd
                                  INNER JOIN analytics.payroll.company_directory m
                                  ON cd.direct_manager_employee_id = m.employee_id
                        WHERE cd.date_terminated IS NULL),
      managers  AS (
                       SELECT ''                                    AS manager_list,
                              CONCAT_WS(' ', first_name, last_name) AS name,
                              employee_title,
                              employee_id,
                              manager_id,
                              manager_email
                         FROM directory
                        WHERE employee_id = 103
                        UNION ALL
                       SELECT CONCAT_WS(',', emp.manager_email, man.manager_list) AS manager_list,
                              CONCAT_WS(' ', emp.first_name, emp.last_name)       AS name,
                              emp.employee_title,
                              emp.employee_id,
                              emp.manager_id,
                              emp.manager_email
                         FROM directory emp
                                  INNER JOIN managers man
                                  ON emp.manager_id = man.employee_id),
--one time override (Jay) requested by Mark W on 5/19/23, completed by JW 5/23/23
--second override (David) requested by Mark W on 6/28/23, completed by JW 6/28/23
      overrides AS (
                       SELECT CASE WHEN CONTAINS(manager_list, 'eric@equipmentshare.com')
                                   THEN REPLACE(manager_list, 'eric@equipmentshare.com', 'eric@equipmentshare.com,jay.mitchell@equipmentshare.com,david.ross@equipmentshare.com')
                                   ELSE manager_list END AS manager_list,
                              name,
                              employee_title,
                              employee_id,
                              manager_id,
                              manager_email
                         FROM managers),
      final     AS (
                       SELECT STRTOK_TO_ARRAY(manager_list, ',') AS manager_array,
                              m.name,
                              m.employee_title,
                              m.employee_id,
                              u.user_id,
                              m.manager_id
                         FROM overrides m
                                  INNER JOIN es_warehouse.public.users u
                                  ON m.employee_id = TRY_TO_NUMBER(u.employee_id)
                                  INNER JOIN analytics.public.commissions_salesperson_data csd
                                  ON csd.salesperson_user_id = u.user_id
                        WHERE CURRENT_DATE BETWEEN commission_start_date AND commission_end_date
                          AND u.company_id = 1854),
      commissions_records as (
    select
           count(*) as COUNT
    from ANALYTICS.COMMISSION.COMMISSION_DETAILS csd
    LEFT JOIN final f
         ON csd.user_id = f.user_id
    where
        case when
            'developer' = {{ _user_attributes['department'] }}
            OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}') = 'traci.marshall@equipmentshare.com'
            OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}') = 'christine@equipmentshare.com'
            OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::variant, manager_array)
            then 1=1
            else
            TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}') = email_address
        end
        AND {% condition sales_rep_filter %} concat(csd.full_name,' - ',csd.user_id) {% endcondition %}
)
select
       case when count >= 1 then 'View Commission Statement' else 'Statement Not Available' end as view_statement_text,
       concat(u.first_name,' ',u.last_name,' - ',u.user_id) as full_name_with_id,
       u.user_id
from commissions_records cr
    join es_warehouse.public.users u on u.email_address = TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')
      ;;
  }


  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format_name: id
  }

  dimension: Full_Name_with_ID {
    type: string
    sql: ${TABLE}."FULL_NAME_WITH_ID" ;;
  }

  dimension: view_statement_text {
    type: string
    sql: ${TABLE}."VIEW_STATEMENT_TEXT" ;;
    html: {% if view_statement_text._value == 'View Commission Statement' and _filters['view_commission_statement_tile.sales_rep_filter'] != nil %}
           <u><p style="color:Blue;"><a href="https://equipmentshare.looker.com/dashboards/470?Company+Name=&Full+Name+with+ID={{ _filters['view_commission_statement_tile.sales_rep_filter'] | url_encode }}&Payroll+Check+Date=2026%2F03%2F20&Invoice+No=&Line+Item+Type=">View Commission Statement</a></p></u>
          {% elsif view_statement_text._value == 'View Commission Statement' %}
            <u><p style="color:Blue;"><a href="https://equipmentshare.looker.com/dashboards/470?Company+Name=&Full+Name+with+ID={{ Full_Name_with_ID._value | url_encode }}&Payroll+Check+Date=2026%2F03%2F20&Invoice+No=&Line+Item+Type=">View Commission Statement</a></p></u>
        {% else %}
            <p> Statement Not Available </p>
        {% endif %};;
  }

  filter: sales_rep_filter {
  }
}
