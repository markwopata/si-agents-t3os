
select *
from {{ ref("int_retail_sales_commissions_live_staging") }}
where 
    commission_id not in (
            select  COMMISSION_ID
            from  {{ ref('int_retail_sales_commissions_finalized_data') }}
            )
            and paycheck_date is not null