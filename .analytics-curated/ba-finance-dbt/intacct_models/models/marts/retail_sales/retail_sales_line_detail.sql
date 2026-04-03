select *
from {{ ref("int_retail_sales_line_detail") }}
where is_current
