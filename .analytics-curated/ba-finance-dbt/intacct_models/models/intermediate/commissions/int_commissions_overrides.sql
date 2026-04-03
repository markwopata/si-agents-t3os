with
invoice_data as (
    select
        lid.line_item_id,
        lid.line_item_type_id,
        lid.invoice_id,
        lid.salesperson_user_id as user_id,
        lid.billing_approved_date,
        lid.company_id
    from {{ ref("int_commissions_line_item_details") }} as lid
    where lid.sales_person_type != 'NAM Salesperson'
),

employee_overrides as (
    select
        id.line_item_id,
        ece.exception_type_id,
        id.user_id,
        ece.override_rate
    from invoice_data as id
        inner join
            {{ ref("stg_analytics_commission__employee_commission_exceptions") }} as ece
            on id.user_id = ece.user_id
                and id.billing_approved_date between ece.start_date and ece.end_date
),

company_overrides as (
    select
        id.line_item_id,
        cce.exception_type_id,
        id.user_id,
        cce.override_rate,
        (cce.exception_type_id = 1) as is_exception
    from invoice_data as id
        inner join
            {{ ref("stg_analytics_commission__company_commission_exceptions") }} as cce
            on id.company_id = cce.company_id
                and id.billing_approved_date between cce.start_date and cce.end_date
                and (id.line_item_type_id = cce.line_item_type_id
                -- When line_item_type_id is null, the exception applies to all line items
                or cce.line_item_type_id is null)
),

nam_company_exceptions as (
    select
        id.line_item_id,
        cce.exception_type_id,
        nca.nam_user_id as user_id,
        cce.override_rate,
        (cce.exception_type_id = 1) as is_exception
    from invoice_data as id
        inner join
            {{ ref("stg_analytics_commission__company_commission_exceptions") }} as cce
            on id.company_id = cce.company_id
                and id.billing_approved_date between cce.start_date and cce.end_date
                and cce.line_item_type_id is null
        inner join
            {{ ref("stg_analytics_commission__nam_company_assignments") }} as nca
            on id.company_id = nca.company_id
                and id.billing_approved_date between nca.effective_start_date and nca.effective_end_date
                and nca.nam_user_id is not null
),

line_item_overrides as (
    select
        line_item_id,
        5 as exception_type_id, -- Type 5 is the line item override
        salesperson_user_id as user_id,
        0.04 as override_rate
    from {{ ref("int_commissions_line_item_overrides") }}
),

output as (
    select
        id.line_item_id::int as line_item_id,
        id.user_id::int as salesperson_user_id,
        (eo.exception_type_id is not null) as is_employee_override,
        eo.override_rate as employee_override_rate,
        iff(co.exception_type_id = 2, true, false) as is_company_override,
        co.override_rate as company_override_rate,
        (lio.exception_type_id is not null) as is_line_item_override,
        lio.override_rate as line_item_override_rate,
        coalesce(co.is_exception, false) as is_exception,
        greatest(is_employee_override, is_company_override, is_line_item_override) as is_override
    from invoice_data as id
        left join employee_overrides as eo
            on id.line_item_id = eo.line_item_id
                and id.user_id = eo.user_id
        left join company_overrides as co
            on id.line_item_id = co.line_item_id
                and id.user_id = co.user_id
        left join line_item_overrides as lio
            on id.line_item_id = lio.line_item_id
                and id.user_id = lio.user_id
    where (
        eo.override_rate is not null
        or co.override_rate is not null
        or lio.override_rate is not null
        or co.is_exception is not null
    )
)

select *
from output

union all

-- Add NAM exceptions (No overrides for NAM)
select distinct
    line_item_id,
    user_id as salesperson_user_id,
    false as is_employee_override,
    null as employee_override_rate,
    false as is_company_override,
    null as company_override_rate,
    false as is_line_item_override,
    null as line_item_override_rate,
    is_exception,
    false as is_override
from nam_company_exceptions
