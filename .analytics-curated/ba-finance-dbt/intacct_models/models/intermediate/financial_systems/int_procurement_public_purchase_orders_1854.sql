select *
from {{ ref('stg_procurement_public__purchase_orders') }}
where company_id = 1854
