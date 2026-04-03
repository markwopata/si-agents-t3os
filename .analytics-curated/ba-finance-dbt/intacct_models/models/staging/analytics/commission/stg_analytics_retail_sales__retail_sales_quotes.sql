
select * 
from {{ source('analytics_retail_sales', 'retail_sales_quotes') }}