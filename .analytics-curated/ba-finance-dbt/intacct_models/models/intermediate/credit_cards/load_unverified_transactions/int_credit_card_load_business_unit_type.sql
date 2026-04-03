with sub_depts as (
    select
        sub_department_id,
        sub_department_name,
        cost_capture_id
    from {{ ref('stg_analytics_corporate_budget__budget_sub_departments') }}
    qualify row_number() over (
            partition by sub_department_id, cost_capture_id
            order by budget_year desc -- TODO code smell
        ) = 1
),

exp_lines as (
    select
        expense_line_id,
        expense_line_name,
        cost_capture_id
    from {{ ref('stg_analytics_corporate_budget__budget_expense_lines') }}
    qualify row_number() over (
            partition by expense_line_id, cost_capture_id
            order by budget_year desc -- TODO code smell
        ) = 1
)

select
    bus.business_unit_snapshot_id,
    bus.name,
    bus.business_unit_id,
    bus.business_unit_type,
    sub_depts.sub_department_id,
    sub_depts.sub_department_name,
    exp_lines.expense_line_id,
    exp_lines.expense_line_name
from {{ ref('stg_procurement_public__business_unit_snapshots') }} as bus
    left join sub_depts
        on bus.business_unit_id = sub_depts.cost_capture_id
            and bus.business_unit_type = upper('sub_department')
    left join exp_lines
        on bus.business_unit_id = exp_lines.cost_capture_id
            and bus.business_unit_type = upper('expense_line')
where bus.business_unit_type in (upper('expense_line'), upper('sub_department'))
