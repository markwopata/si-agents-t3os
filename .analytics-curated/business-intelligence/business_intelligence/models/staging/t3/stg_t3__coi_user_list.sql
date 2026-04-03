{{ config(
    materialized = 'incremental',
    unique_key = 'supplier_id'
) }}

-- SHARED CTE -------------------------------------------------------------------

WITH insurance_flags AS (
  SELECT
      c.company_id,
      MAX(CASE WHEN r.equipment_class_id IN (
        39352,39095,39130,39132,39053,39078,39131,39034,39035,37037,29989,28914,14816,
        10826,16426,13638,13653,22868,9513,9522,9308,10400,8812,8811,8810,8841,3533,
        3124,3485,518,197,519,4740,3465,476,475,474,771,3437,3425,32363
      ) THEN 1 ELSE 0 END) AS vehicle_rental_flag,
      MAX(CASE WHEN r.equipment_class_id NOT IN (
        39352,39095,39130,39132,39053,39078,39131,39034,39035,37037,29989,28914,14816,
        10826,16426,13638,13653,22868,9513,9522,9308,10400,8812,8811,8810,8841,3533,
        3124,3485,518,197,519,4740,3465,476,475,474,771,3437,3425,32363
      ) THEN 1 ELSE 0 END) AS equipment_rental_flag,
      MAX(CASE WHEN nt.name = 'Cash on Delivery' THEN 1 ELSE 0 END) AS is_cod
  FROM es_warehouse.public.companies c
  LEFT JOIN es_warehouse.public.orders o ON o.company_id = c.company_id
  LEFT JOIN es_warehouse.public.rentals r ON r.order_id   = o.order_id
  LEFT JOIN es_warehouse.public.net_terms nt ON nt.net_terms_id = c.net_terms_id
  WHERE
      (
        r.end_date   >= '2025-04-16'
        OR r.start_date >= '2025-04-16'
        OR r.end_date IS NULL
        OR r.rental_status_id = 5
      )
      AND r.equipment_class_id IS NOT NULL
      AND r.rental_status_id IN (4,5,6,7,9)
      AND o.deleted = FALSE
      AND r.deleted = FALSE
  GROUP BY c.company_id
),

insurance_by_user AS (
  SELECT
      f.company_id,
      CASE
        WHEN f.is_cod = 1 THEN 'Cash on Delivery'
        WHEN f.vehicle_rental_flag = 1 AND f.equipment_rental_flag = 1 THEN 'Equipment & On-Road'
        WHEN f.vehicle_rental_flag = 1 AND f.equipment_rental_flag = 0 THEN 'On-Road'
        WHEN f.vehicle_rental_flag = 0 AND f.equipment_rental_flag = 1 THEN 'Equipment'
      END AS insurance_tier
  FROM insurance_flags f
),

raw_current AS (
  SELECT DISTINCT
      u.first_name                                        AS "First Name",
      u.last_name                                         AS "Last Name",
      CASE
        WHEN c.doing_business_as IS NOT NULL
             AND c.doing_business_as <> ''
             AND c.name ILIKE '%dba%'
        THEN c.doing_business_as
        ELSE c.name
      END                                                 AS "Company Name",
      ibu.insurance_tier                                  AS "Insurance Tier",
      l.street_1                                          AS "Company Address 1",
      NULL                                                AS "Company Address 2",
      NULL                                                AS "Company Country",
      s.name                                              AS "Company State/Province",
      l.city                                              AS "Company City",
      l.zip_code                                          AS "Company Zip Code/Post Code/Pin Code",
      u.email_address                                     AS "Email",
      NULL                                                AS "Tax ID",
      c.company_id                                        AS "Supplier ID"
  FROM es_warehouse.public.companies c
  LEFT JOIN es_warehouse.public.users u        ON u.user_id = c.owner_user_id
  LEFT JOIN es_warehouse.public.orders o       ON o.company_id = c.company_id
  LEFT JOIN es_warehouse.public.rentals r      ON r.order_id = o.order_id
  LEFT JOIN es_warehouse.public.locations l    ON l.location_id = COALESCE(c.billing_location_id, c.home_office_location_id)
  LEFT JOIN es_warehouse.public.states s       ON s.state_id = l.state_id
  LEFT JOIN insurance_by_user ibu ON u.company_id = ibu.company_id
  WHERE
      (
        r.end_date   >= '2025-04-16'
        OR r.start_date >= '2025-04-16'
        OR r.end_date IS NULL
        OR r.rental_status_id = 5
      )
      AND r.equipment_class_id IS NOT NULL
      AND r.rental_status_id IN (4,5,6,7,9)
      AND o.deleted = FALSE
      AND r.deleted = FALSE
),

current_candidates AS (
  SELECT *
  FROM raw_current
  WHERE "Company Name" NOT ILIKE '%duplicate%'
    AND "Company Name" NOT ILIKE '%deleted%'
    AND "Company Name" NOT ILIKE '%do not use%'
    AND "Email" LIKE '%@%'
)

{% if is_incremental() %}

-- INCREMENTAL RUNS: APPEND ONLY NEW COMPANIES -------------------------------------------------------------------

SELECT
  cc."First Name",
  cc."Last Name",
  cc."Company Name",
  cc."Insurance Tier",
  cc."Company Address 1",
  cc."Company Address 2",
  cc."Company Country",
  cc."Company State/Province",
  cc."Company City",
  cc."Company Zip Code/Post Code/Pin Code",
  cc."Email",
  cc."Tax ID",
  cc."Supplier ID"        AS supplier_id,
  CURRENT_DATE()::date     AS baseline_loaded_at
FROM current_candidates cc
LEFT JOIN {{ this }} b
  ON b.supplier_id = cc."Supplier ID"
WHERE b.supplier_id IS NULL          -- only companies not already in the table

{% else %}

-- FIRST RUN: LOAD TEMP TABLE ROWS -------------------------------------------------------------------

SELECT
  rc."First Name",
  rc."Last Name",
  rc."Company Name",
  rc."Insurance Tier",
  rc."Company Address 1",
  rc."Company Address 2",
  rc."Company Country",
  rc."Company State/Province",
  rc."Company City",
  rc."Company Zip Code/Post Code/Pin Code",
  rc."Email",
  rc."Tax ID",
  t.supplier_id                          AS supplier_id,
  t.baseline_loaded_at::date                   AS baseline_loaded_at
FROM ANALYTICS.PUBLIC.CERTIFICAL_TEMP_LIST t
LEFT JOIN current_candidates rc
  ON t.supplier_id = rc."Supplier ID"

{% endif %}
