select distinct 
replace(record_metadata:key, '"','') as pim_product_id,
f1.value:"name"::string as shipping_dimension_name,
f1.value:"description"::string as shipping_dimension_description,
f1.value:"unit_of_measure":"name"::string as shipping_dimension_uom,
f1.value:"value"::string as shipping_dimension_value
from confluent.pim__raw.tbl_pim_products,
lateral flatten(input => data_product_shipping_dimensions_attributes) f1
where data_is_deleted = false