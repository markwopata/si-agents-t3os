-- Union POs and related documents and apa true ups into a single model. 

select *
from {{ ref('int_purchase_orders_po_true_ups') }}
union distinct
select *
from {{ ref('int_purchase_orders_po_to_vi') }}
