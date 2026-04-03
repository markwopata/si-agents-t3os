{{ config(
    materialized='table'
    , cluster_by=['company_id', 'billing_approved_date']
) }}

WITH jobs AS (
    SELECT
        o.job_id,
        r.asset_id,
        r.start_date,
        r.end_date,
        CASE WHEN j.parent_job_id IS NOT NULL THEN j.name END AS phase_job_name,
        CASE WHEN j.parent_job_id IS NOT NULL THEN j.job_id END AS phase_job_id,
        COALESCE(jp.name, j.name) AS job_name
    FROM {{ ref("platform","es_warehouse__public__orders") }} o
    LEFT JOIN {{ ref("platform","es_warehouse__public__rentals") }} r ON (r.order_id = o.order_id)
    JOIN {{ ref("platform","es_warehouse__public__jobs") }} j ON (j.job_id = o.job_id)
    LEFT JOIN {{ ref("platform","es_warehouse__public__jobs") }} jp ON (j.parent_job_id = jp.job_id)
    WHERE r.asset_id IS NOT NULL
      AND r.deleted = false
      AND o.deleted = false
)
  ,  orders AS (select
    o.*
    , c.contract_id
    from
    {{ ref("platform","es_warehouse__public__orders") }} o
    left join {{ ref("platform","es_warehouse__public__contracts") }} c on (o.order_id = c.terms:order_id)
    )
SELECT DISTINCT
    (TO_CHAR(TO_DATE(CAST(invoices.billing_approved_date AS TIMESTAMP_NTZ) ), 'YYYY-MM-DD')) AS billing_approved_date,
    invoices.invoice_no  AS invoice_no,
    line_item_types.name  AS line_item_type_name,
    rentals.rental_id  AS rental_id,
    coalesce(assets.custom_name,'No Asset Assigned')  AS custom_name,
    assets.asset_class  AS asset_class,
    purchase_orders.name  AS purchase_order_name,
    locations.nickname  AS location_nickname,
    jobs.job_name  AS job_name,
    jobs.phase_job_name  AS phase_name,
    invoices.company_id as company_id,
    orders.user_id as user_id,
    invoices.invoice_date as invoice_date,
    COALESCE(line_items.amount, 0) AS line_item_amount,
    COALESCE(line_items.tax_amount, 0) AS total_tax
FROM {{ ref("platform","es_warehouse__public__invoices") }} AS invoices
LEFT JOIN {{ ref("platform","es_warehouse__public__line_items") }} AS line_items ON (line_items.invoice_id) = (invoices.invoice_id)
LEFT JOIN {{ ref("platform","es_warehouse__public__rentals") }} AS rentals ON (line_items.rental_id) = (rentals.rental_id)
LEFT JOIN orders ON (orders.order_id) = (rentals.order_id)
LEFT JOIN jobs ON (orders.job_id) = (jobs.job_id)
LEFT JOIN {{ ref("platform","es_warehouse__public__purchase_orders") }} AS purchase_orders ON (purchase_orders.purchase_order_id) = (invoices.purchase_order_id)
LEFT JOIN {{ ref("platform","es_warehouse__public__assets") }} AS assets ON (assets.asset_id) = (COALESCE(line_items.asset_id, line_items.extended_data:delivery:asset_id::NUMBER))
LEFT JOIN {{ ref("platform","es_warehouse__public__line_item_types") }} AS line_item_types ON (line_items.line_item_type_id) = (line_item_types.line_item_type_id)
LEFT JOIN {{ ref("platform","es_warehouse__public__rental_location_assignments") }} AS rental_location_assignments ON (rental_location_assignments.rental_id) = (rentals.rental_id) and (TO_CHAR(TO_DATE(CAST(rental_location_assignments.end_date AS TIMESTAMP_NTZ) ), 'YYYY-MM-DD')) is null
LEFT JOIN {{ ref("platform","es_warehouse__public__locations") }} AS locations ON (rental_location_assignments.location_id) = (locations.location_id)
ORDER BY
    1 DESC,
    2 DESC,
    3,
    4,
    5,
    6,
    7
