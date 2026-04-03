select distinct
replace(record_metadata:key, '"','') as pim_product_id,
f1.value:"ProductOptionGroup":"name"::string as product_option_group,
f2.value:"name"::string as product_option_name,
f3.value:"name"::string as product_option_choice_name,
case when f2.value:"is_choices"::string = 'true' then f3.value:"value"::string else f2.value end as product_option_value,
f4.value:"Attribute":"name"::string as product_option_attribute_name,
f4.value:"Attribute":"value"::string as product_option_attribute_value,
f4.value:"Attribute":"unit_of_measure":"name"::string as product_option_uom
from confluent.pim__raw.tbl_pim_products,
lateral flatten(input => data_product_options) f1,
lateral flatten(input => f1.value:"ProductOptionGroup":"options") f2,
lateral flatten(input => f2.value:"choices") f3,
lateral flatten(input => f3.value:"attributes") f4
where data_is_deleted = false