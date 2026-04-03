SELECT
    p.productid as product_id,
    p.supplierid as supplier_id,
    p.supplierproductid as supplier_product_id,
    p._fivetran_deleted as _fivetran_deleted,
    p._fivetran_synced as _fivetran_synced
FROM {{ source('analytics_bt_dbo', 'productsupplier') }} as p
