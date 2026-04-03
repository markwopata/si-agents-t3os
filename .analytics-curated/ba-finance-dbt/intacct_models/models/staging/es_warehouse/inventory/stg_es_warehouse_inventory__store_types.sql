SELECT
    st.store_type_id,
    st.name,
    st._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'store_types') }} as st
