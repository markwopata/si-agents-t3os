select distinct
replace(record_metadata:key, '"','') as pim_product_id,
f2.value:"Attribute":"name"::string AS group_name,
f2.value:"Attribute":"value"::string AS group_value,
f2.value:"Attribute":"unit_of_measure":"name"::string AS group_uom
from confluent.pim__raw.tbl_pim_products,
lateral flatten(input => data_product_attribute_groups) f1,
lateral flatten(input => f1.value:attributes) f2
where data_is_deleted = false