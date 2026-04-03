select
    budget_year
    ,department_name
    ,sub_department_name
    ,expense_line_name
    ,concat(sub_department_id,' - ',expense_line_name) as valid_combo
from {{ ref('stg_analytics_corporate_budget__approved_budgets')}}