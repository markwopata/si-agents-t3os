-- looks like there can be up to 3 levels of categories

SELECT
    c.category_id,
    c.name as category_name,
    c.parent_category_id,
    p.name AS parent_category_name,
    p.parent_category_id as grandparent_category_id,
    gp.name as grandparent_category_name,
    c.active as is_active,
    IFF(c.description = '', NULL, c.description) as category_description,
    c.company_division_id,
    c.company_id,
    c.date_deactivated

FROM {{ ref('platform', 'categories') }} c
LEFT JOIN {{ ref('platform', 'categories') }} p
ON c.parent_category_id = p.category_id
LEFT JOIN {{ ref('platform', 'categories') }} gp
on p.parent_category_id = gp.category_id

WHERE c._categories_effective_delete_utc_datetime IS NULL
AND p._categories_effective_delete_utc_datetime IS NULL
AND gp._categories_effective_delete_utc_datetime IS NULL