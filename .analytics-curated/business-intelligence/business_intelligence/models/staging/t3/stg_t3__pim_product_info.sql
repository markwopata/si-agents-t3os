select distinct 
replace(record_metadata:key, '"','') as pim_product_id,
data_product_core_attributes_name,
data_product_category_path,
data_product_category_name,
data_tenant_id,
time,
data_updatedat,
data_createdat,
data_product_core_attributes_model,
data_product_core_attributes_make,
data_product_core_attributes_variant,
data_product_core_attributes_year,
data_product_source_attributes_source
from confluent.pim__raw.tbl_pim_products
where data_is_deleted = false