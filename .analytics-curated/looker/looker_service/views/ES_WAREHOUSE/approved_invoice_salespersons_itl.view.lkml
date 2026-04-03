view: approved_invoice_salespersons_itl {
  derived_table: {
    sql: with primary_sales as (
    select s.invoice_id
        , s.primary_salesperson_id
        , u.employee_id as primary_salesperson_employee_id
        , u.first_name||' '||u.last_name primary_salesperson_name
    from "ES_WAREHOUSE"."PUBLIC"."APPROVED_INVOICE_SALESPERSONS" s
    join "ES_WAREHOUSE"."PUBLIC"."USERS" u
        on s.primary_salesperson_id =u.user_id
    left join "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" cd
        on u.employee_id = to_char(cd.employee_id)
    --where cd.employee_status != 'Terminated'
)

, secondary_sales_flat as (
    select s.invoice_id
        , value as flat_secondary
    from "ES_WAREHOUSE"."PUBLIC"."APPROVED_INVOICE_SALESPERSONS" s
        , lateral flatten(INPUT => secondary_salesperson_ids)
)

, secondary_detail as (
    select s.invoice_id
        , s.flat_secondary
        , u.employee_id as secondary_salesperson_employee_id
        , u.first_name||' '||u.last_name secondary_salesperson_name
    from secondary_sales_flat s
    join "ES_WAREHOUSE"."PUBLIC"."USERS" u
        on s.flat_secondary = u.user_id
    left join "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" cd
        on u.employee_id = to_char(cd.employee_id)
    where cd.employee_status != 'Terminated'
    --and invoice_id = 4642922
)

, secondary_collapse as (
    select invoice_id
        , listagg(flat_secondary, ', ') as secondary_salesperson_ids
        , listagg(secondary_salesperson_employee_id, ', ') as secondary_salesperson_employee_ids
        , listagg(secondary_salesperson_name, ', ') as secondary_salesperson_names
    from secondary_detail
    group by invoice_id
)

select p.invoice_id
    , p.primary_salesperson_id
    , p.primary_salesperson_employee_id
    , p.primary_salesperson_name
    , s.secondary_salesperson_ids
    , s.secondary_salesperson_employee_ids
    , s.secondary_salesperson_names
from primary_sales p
left join secondary_collapse s
    on p.invoice_id = s.invoice_id;;
  }

  dimension: invoice_id {
    type:  string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: primary_salesperson_id {
    type: number
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
  }

  dimension: primary_salesperson_employee_id {
    type: number
    sql: ${TABLE}."PRIMARY_SALESPERSON_EMPLOYEE_ID" ;;
    }

  dimension: primary_salesperson_name {
    type: string
    sql: ${TABLE}."PRIMARY_SALESPERSON_NAME" ;;
  }

  dimension: secondary_salesperson_ids {
    type: number
    sql: ${TABLE}."SECONDARY_SALESPERSON_IDS" ;;
  }

  dimension: secondary_salesperson_employee_ids {
    type: number
    sql: ${TABLE}."SECONDARY_SALESPERSON_EMPLOYEE_IDS" ;;
  }

  dimension: secondary_salesperson_names {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_NAMES" ;;
  }

  filter: primary_and_secondary_id {
    type:  string
    sql: {% condition %} ${primary_salesperson_employee_id} {% endcondition %} or {% condition %}  ${secondary_salesperson_employee_ids} {% endcondition %}  ;;
  }

  filter: primary_and_secondary_name {
    type:  string
    sql: {% condition %} ${primary_salesperson_name} {% endcondition %} or {% condition %}  ${secondary_salesperson_names} {% endcondition %}  ;;
  }
}
