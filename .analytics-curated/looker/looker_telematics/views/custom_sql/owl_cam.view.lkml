view: owl_cam {

  derived_table: {
    sql:
    SELECT  A.ASSET_ID AS ASSET_ID, COALESCE(A.SERIAL_NUMBER, A.VIN) AS SERIAL_VIN, A.MAKE as make,
A.MODEL as model,A.ASSET_CLASS as asset_class,
coalesce(A.rental_branch_id,A.INVENTORY_BRANCH_ID) as BRANCH_ID,
A.COMPANY_ID AS COMPANY_ID, X.MARKET_NAME AS inventory_branch,
X.REGION_NAME AS REGION_NAME, X.DISTRICT AS DISTRICT,
CASE WHEN C.CAMERA_VENDOR_ID = 3 THEN 'Yes' ELSE 'No' END AS HAS_OWL_CAM
FROM ES_WAREHOUSE."PUBLIC".ASSETS AS A
LEFT JOIN ES_WAREHOUSE."PUBLIC".CAMERAS AS C
ON A.CAMERA_ID = C.CAMERA_ID
LEFT JOIN ES_WAREHOUSE."PUBLIC".COMPANIES AS COMP
ON  A.COMPANY_ID = COMP.COMPANY_ID
LEFT JOIN  ES_WAREHOUSE."PUBLIC".MARKETS AS M
ON M.MARKET_ID = coalesce(A.rental_branch_id,A.INVENTORY_BRANCH_ID)
LEFT JOIN  ANALYTICS."PUBLIC".MARKET_REGION_XWALK AS X
ON X.MARKET_ID = coalesce(A.rental_branch_id,A.INVENTORY_BRANCH_ID)
WHERE (lower(A.asset_class) LIKE '%service%' OR lower(A.asset_class) LIKE '%delivery%' OR lower(A.asset_class) LIKE '%1/2 ton non-rental pickup truck%' and lower(A.asset_class) not like '%trailer%')

                         ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: serial_vin {
    type: string
    sql: ${TABLE}.serial_vin ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}.asset_class ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}.inventory_branch ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }

    dimension: has_owl_cam {
    type: string
    sql: ${TABLE}.has_owl_cam ;;
  }

  set: owl_net_details {
    fields: [asset_id, serial_vin, make, model, company_id, inventory_branch, region_name, district, asset_class, has_owl_cam]
  }

  measure: asset_count {
    type: count_distinct
    drill_fields: [owl_net_details*]
    sql: ${asset_id} ;;
  }

 }
