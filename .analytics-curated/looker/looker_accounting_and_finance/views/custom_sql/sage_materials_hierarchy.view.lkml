view: sage_materials_hierarchy {
    derived_table: {
      sql: WITH RECURSIVE DepartmentHierarchy AS (
    -- Anchor member: Select the top-level departments (those with no parent department)
    SELECT d.RECORDNO            AS id,
           d.DEPARTMENTID        AS market_id,
           d.TITLE               AS market_name,
           d.STATUS              AS sage_status,
           d.DEPARTMENT_TYPE,
           d.BUILD_TO_SUIT_TYPE,
           d.PREVENT_NEW_PURCHASING_TRANS,
           d.PARENTKEY           AS parent_id,
           CAST(NULL AS VARCHAR) AS region,
           CAST(NULL AS VARCHAR) AS district,
           1                     AS level, -- Start level at 1
           d.TITLE               AS path   -- Initial path is the department name itself
    FROM ANALYTICS.INTACCT.DEPARTMENT d -- Replace 'Departments' with your actual table name
    WHERE d.PARENTKEY IS NULL -- Identify top-level departments
      AND d.STATUS != 'inactive'

    UNION ALL

    -- Recursive member: Join with the anchor member to build the hierarchy
    SELECT d1.RECORDNO       AS id,
           d1.DEPARTMENTID   AS market_id,
           d1.TITLE          AS market_name,
           d1.STATUS         AS sage_status,
           d1.DEPARTMENT_TYPE,
           d1.BUILD_TO_SUIT_TYPE,
           d1.PREVENT_NEW_PURCHASING_TRANS,
           d1.PARENTKEY      AS parent_id,
           CASE
               WHEN d1.DEPARTMENTID = 'REGIONS' THEN NULL
               WHEN dh.region IS NOT NULL THEN dh.region
               WHEN dh.region IS NULL AND d1.DEPARTMENT_TYPE = 'Region' THEN d1.TITLE
               ELSE NULL END AS region,
           CASE
               WHEN dh.district IS NOT NULL THEN dh.district
               WHEN dh.district IS NULL AND d1.DEPARTMENT_TYPE = 'District' THEN d1.TITLE
               ELSE NULL END AS district,
           dh.level + 1,              -- Increment level
           dh.path || '/' || d1.TITLE -- Append current department name to the path
    FROM ANALYTICS.INTACCT.DEPARTMENT d1
             INNER JOIN
         DepartmentHierarchy dh ON d1.PARENTKEY = dh.id -- Join with the CTE
)

-- Final SELECT statement to retrieve the hierarchical data
SELECT s.id,
       s.market_id,
       s.market_name,
       s.sage_status,
       s.DEPARTMENT_TYPE,
       s.BUILD_TO_SUIT_TYPE,
       s.PREVENT_NEW_PURCHASING_TRANS,
       s.parent_id,
       s.region,
       s.district,
       s.level,
       s.path
FROM DepartmentHierarchy s
WHERE path LIKE 'Materials: Regions, Districts, Locations%'
  AND sage_status != 'inactive'
ORDER BY s.path ;;
    }

    dimension: id {
      type: string
      label: "ID"
      sql: ${TABLE}.id ;;
    }

    dimension: market_id {
      type: string
      label: "Market ID"
      sql: ${TABLE}.market_id ;;
    }

    dimension: market_name {
      type: string
      label: "Market Name"
      sql: ${TABLE}.market_name ;;
    }

    dimension: sage_status {
      type: string
      label: "Sage Status"
      sql: ${TABLE}.sage_status ;;
    }

    dimension: department_tyoe {
      type: string
      label: "Department Type"
      sql: ${TABLE}."DEPARTMENT_TYPE" ;;
    }

    dimension: bts_type {
      type: string
      label: "Build-to-Suit Type"
      sql: ${TABLE}."BUILD_TO_SUIT_TYPE" ;;
    }

    dimension: prevent_new_pur_trans {
      type: yesno
      label: "Prevent New Purchasing Transactions"
      sql: ${TABLE}."PREVENT_NEW_PURCHASING_TRANS" ;;
    }

    dimension: parent_id {
      type: string
      label: "Parent ID"
      sql: ${TABLE}.parent_id ;;
    }

    dimension: region {
      type: string
      label: "Region"
      sql: ${TABLE}.region ;;
    }

    dimension: district {
      type: string
      label: "District"
      sql: ${TABLE}.district ;;
    }

    dimension: level {
      type: string
      label: "Level"
      sql: ${TABLE}.level ;;
    }

    dimension: path {
      type: string
      label: "Path"
      sql: ${TABLE}.path ;;
    }

}
