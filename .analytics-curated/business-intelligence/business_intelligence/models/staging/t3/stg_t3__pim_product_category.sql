select distinct
replace(record_metadata:key, '"','') as pim_product_id,
f1.value:name::string as pim_category_name,
f1.value:value::string as pim_category_value,
f1.value:unit_of_measure:name::string as pim_category_uom
from confluent.pim__raw.tbl_pim_products,
lateral flatten(input => data_product_category_core_attributes) f1
where data_is_deleted = false