view: employee_title_permissions {
  # Person-grain companion to the market permission view for employee-level dashboard tiles.
  derived_table: {
    sql:
      WITH viewer_src AS (
        SELECT
          cd.employee_id,
          LOWER(cd.work_email) AS work_email,
          cd.employee_title,
          --IFF(LOWER('regional_ops') IN ('safety', 'developer', 'leadership'), TRUE, FALSE) AS full_access,
          --IFF(LOWER('general_mgr') IN ('safety', 'developer', 'leadership'), TRUE, FALSE) AS full_access,
          --IFF(LOWER('district_ops') IN ('safety', 'developer', 'leadership'), TRUE, FALSE) AS full_access,
          --IFF(LOWER('driver') IN ('safety','developer','leadership'), TRUE, FALSE) AS full_access,
          IFF(LOWER({{ _user_attributes['job_role'] }}) IN ('safety','developer','leadership','hrbp','training') OR (LOWER('{{ _user_attributes['email'] }}') = 'bryan.walsh@equipmentshare.com'), TRUE, FALSE) AS full_access,
          IFF(LOWER({{ _user_attributes['job_role'] }}) = 'driver', TRUE, FALSE) AS is_driver,
          cd.market_id,
          viewer_map.region AS market_region,
          viewer_map.region_name AS market_region_name,
          viewer_map.district AS market_district,
          SPLIT_PART(cd.default_cost_centers_full_path, '/', 1) AS dccfp_part_1,
          SPLIT_PART(cd.default_cost_centers_full_path, '/', 2) AS dccfp_part_2,
          SPLIT_PART(cd.default_cost_centers_full_path, '/', 3) AS dccfp_part_3,
          IFF(
            LEFT(SPLIT_PART(cd.default_cost_centers_full_path, '/', 1), 1) = 'R'
            AND TRY_TO_NUMBER(SUBSTR(SPLIT_PART(cd.default_cost_centers_full_path, '/', 1), 2, 1)) IS NOT NULL,
            2,
            1
          ) AS dccfp_type
        FROM analytics.payroll.company_directory cd
        LEFT JOIN analytics.public.market_region_xwalk viewer_map
          ON cd.market_id = viewer_map.market_id
         AND (viewer_map.division_name <> 'Materials' OR viewer_map.division_name IS NULL)
        WHERE LOWER(cd.work_email) = LOWER('{{ _user_attributes['email'] }}')
        -- WHERE LOWER(cd.work_email) = LOWER('lee.lobbs@equipmentshare.com')
        --WHERE LOWER(cd.work_email) = LOWER('luke.mcalister@equipmentshare.com') --driver
        --WHERE LOWER(cd.work_email) = LOWER('michael.brown@equipmentshare.com')
        --WHERE LOWER(cd.work_email) = LOWER('franco.vallabriga@equipmentshare.com') --GM
        --WHERE LOWER(cd.work_email) = LOWER('aaron.langston@equipmentshare.com') --DSM
        --WHERE LOWER(cd.work_email) = LOWER('josh.helmstetler@equipmentshare.com') --RM
          AND cd.employee_status NOT IN ('Terminated', 'Inactive', 'Never Started')
      ),
      -- Normalize the viewer to a single market, district, and region record for person access checks.
      viewer AS (
        SELECT
          employee_id,
          work_email,
          employee_title,
          full_access,
          is_driver,
          market_id,
          TRIM(COALESCE(
            CASE
              WHEN TRY_TO_NUMBER(market_region::varchar) IS NOT NULL THEN market_region::varchar
              WHEN UPPER(TRIM(market_region::varchar)) IN ('NATIONAL', 'CORP') THEN UPPER(TRIM(market_region::varchar))
            END,
            CASE
              WHEN LEFT(dccfp_part_1, 1) = 'R' AND TRY_TO_NUMBER(SUBSTR(dccfp_part_1, 2, 1)) IS NOT NULL THEN
                IFF(
                  dccfp_part_1 NOT LIKE '% %',
                  RIGHT(dccfp_part_1, LEN(dccfp_part_1) - 1),
                  SUBSTR(dccfp_part_1, 2, CHARINDEX(' ', dccfp_part_1) - 1)
                )
              WHEN LEFT(dccfp_part_2, 1) = 'R' AND TRY_TO_NUMBER(SUBSTR(dccfp_part_2, 2, 1)) IS NOT NULL THEN
                IFF(
                  dccfp_part_2 NOT LIKE '% %',
                  RIGHT(dccfp_part_2, LEN(dccfp_part_2) - 1),
                  SUBSTR(dccfp_part_2, 2, CHARINDEX(' ', dccfp_part_2) - 1)
                )
            END
          )) AS region,
          TRIM(COALESCE(
            market_region_name,
            CASE
              WHEN LEFT(dccfp_part_1, 1) = 'R' AND TRY_TO_NUMBER(SUBSTR(dccfp_part_1, 2, 1)) IS NOT NULL
                AND dccfp_part_1 LIKE '% %' THEN
                SUBSTR(dccfp_part_1, CHARINDEX(' ', dccfp_part_1) + 1)
              WHEN LEFT(dccfp_part_2, 1) = 'R' AND TRY_TO_NUMBER(SUBSTR(dccfp_part_2, 2, 1)) IS NOT NULL
                AND dccfp_part_2 LIKE '% %' THEN
                SUBSTR(dccfp_part_2, CHARINDEX(' ', dccfp_part_2) + 1)
            END
          )) AS region_name,
          COALESCE(
            market_district,
            CASE
              WHEN TRY_TO_NUMBER(SPLIT_PART(dccfp_part_3, '-', 1)) IS NOT NULL
                AND TRY_TO_NUMBER(SPLIT_PART(dccfp_part_3, '-', 2)) IS NOT NULL
                AND SPLIT_PART(dccfp_part_3, '-', 3) = ''
              THEN dccfp_part_3
              WHEN TRY_TO_NUMBER(SPLIT_PART(dccfp_part_2, '-', 1)) IS NOT NULL
                AND TRY_TO_NUMBER(SPLIT_PART(dccfp_part_2, '-', 2)) IS NOT NULL
                AND SPLIT_PART(dccfp_part_2, '-', 3) = ''
              THEN dccfp_part_2
            END
          ) AS district
        FROM viewer_src
      ),
      -- Gather the employee population once, join operator_id here to avoid a separate company_directory scan.
      staff_src AS (
        SELECT
          staff.employee_id AS subject_employee_id,
          LOWER(staff.work_email) AS subject_work_email,
          staff.employee_title AS subject_employee_title,
          staff.direct_manager_employee_id AS subject_direct_manager_employee_id,
          staff.market_id AS subject_market_id,
          staff_map.market_name AS subject_market_name_from_mrx,
          staff_map.region AS subject_region_from_mrx,
          staff_map.region_name AS subject_region_name_from_mrx,
          staff_map.district AS subject_district_from_mrx,
          SPLIT_PART(staff.default_cost_centers_full_path, '/', 1) AS dccfp_part_1,
          SPLIT_PART(staff.default_cost_centers_full_path, '/', 2) AS dccfp_part_2,
          SPLIT_PART(staff.default_cost_centers_full_path, '/', 3) AS dccfp_part_3,
          SPLIT_PART(staff.default_cost_centers_full_path, '/', 4) AS dccfp_part_4,
          IFF(
            LEFT(SPLIT_PART(staff.default_cost_centers_full_path, '/', 1), 1) = 'R'
            AND TRY_TO_NUMBER(SUBSTR(SPLIT_PART(staff.default_cost_centers_full_path, '/', 1), 2, 1)) IS NOT NULL,
            2,
            1
          ) AS dccfp_type,
          foa.operator_id AS subject_operator_id
        FROM analytics.payroll.company_directory staff
        LEFT JOIN analytics.public.market_region_xwalk staff_map
          ON staff.market_id = staff_map.market_id
         AND (staff_map.division_name <> 'Materials' OR staff_map.division_name IS NULL)
        LEFT JOIN es_warehouse.public.users u
          ON u.employee_id::VARCHAR = staff.employee_id::VARCHAR
        LEFT JOIN business_intelligence.gold.fact_operator_assignments foa
          ON foa.user_id::VARCHAR = u.user_id::VARCHAR
        WHERE staff.employee_status NOT IN ('Terminated', 'Inactive', 'Never Started')
        QUALIFY ROW_NUMBER() OVER (PARTITION BY staff.employee_id ORDER BY foa.operator_id NULLS LAST) = 1
      ),
      -- Normalize each subject employee to a market, district, and region before evaluating access.
      staff_scope AS (
        SELECT
          subject_employee_id,
          subject_work_email,
          subject_employee_title,
          subject_direct_manager_employee_id,
          subject_market_id,
          subject_operator_id,
          COALESCE(
            subject_market_name_from_mrx,
            dccfp_part_4
          ) AS subject_market_name,
          COALESCE(
            subject_district_from_mrx,
            CASE
              WHEN dccfp_type = 1 THEN
                IFF(
                  TRY_TO_NUMBER(SPLIT_PART(dccfp_part_3, '-', 1)) IS NOT NULL
                  AND TRY_TO_NUMBER(SPLIT_PART(dccfp_part_3, '-', 2)) IS NOT NULL
                  AND SPLIT_PART(dccfp_part_3, '-', 3) = '',
                  dccfp_part_3,
                  NULL
                )
              ELSE
                IFF(
                  TRY_TO_NUMBER(SPLIT_PART(dccfp_part_2, '-', 1)) IS NOT NULL
                  AND TRY_TO_NUMBER(SPLIT_PART(dccfp_part_2, '-', 2)) IS NOT NULL
                  AND SPLIT_PART(dccfp_part_2, '-', 3) = '',
                  dccfp_part_2,
                  NULL
                )
            END
          ) AS subject_district,
          TRIM(COALESCE(
            CASE
              WHEN TRY_TO_NUMBER(subject_region_from_mrx::varchar) IS NOT NULL THEN subject_region_from_mrx::varchar
              WHEN UPPER(TRIM(subject_region_from_mrx::varchar)) IN ('NATIONAL', 'CORP') THEN UPPER(TRIM(subject_region_from_mrx::varchar))
            END,
            CASE
              WHEN dccfp_type = 1 THEN
                IFF(
                  LEFT(dccfp_part_2, 1) = 'R' AND TRY_TO_NUMBER(SUBSTR(dccfp_part_2, 2, 1)) IS NOT NULL,
                  IFF(
                    dccfp_part_2 NOT LIKE '% %',
                    RIGHT(dccfp_part_2, LEN(dccfp_part_2) - 1),
                    SUBSTR(dccfp_part_2, 2, CHARINDEX(' ', dccfp_part_2) - 1)
                  ),
                  dccfp_part_2
                )
              ELSE
                IFF(
                  dccfp_part_1 NOT LIKE '% %',
                  RIGHT(dccfp_part_1, LEN(dccfp_part_1) - 1),
                  SUBSTR(dccfp_part_1, 2, CHARINDEX(' ', dccfp_part_1) - 1)
                )
            END
          )) AS subject_region,
          COALESCE(
            subject_region_name_from_mrx,
            CASE
              WHEN dccfp_type = 1 THEN
                IFF(
                  LEFT(dccfp_part_2, 1) = 'R' AND TRY_TO_NUMBER(SUBSTR(dccfp_part_2, 2, 1)) IS NOT NULL,
                  IFF(
                    dccfp_part_2 NOT LIKE '% %',
                    RIGHT(dccfp_part_2, LEN(dccfp_part_2) - 1),
                    SUBSTR(dccfp_part_2, 2, CHARINDEX(' ', dccfp_part_2) - 1)
                  ),
                  dccfp_part_2
                )
              ELSE
                IFF(
                  dccfp_part_1 NOT LIKE '% %',
                  RIGHT(dccfp_part_1, LEN(dccfp_part_1) - 1),
                  SUBSTR(dccfp_part_1, 2, CHARINDEX(' ', dccfp_part_1) - 1)
                )
            END
          ) AS subject_region_name
        FROM staff_src
      )
      -- Emit one row per subject employee so direct-report and region rules can be applied safely.
      SELECT
        viewer.employee_id AS viewer_employee_id,
        viewer.work_email AS viewer_work_email,
        viewer.employee_title AS viewer_employee_title,
        viewer.market_id AS viewer_market_id,
        viewer.district AS viewer_district,
        viewer.region AS viewer_region,
        viewer.region_name AS viewer_region_name,
        staff_scope.subject_employee_id,
        staff_scope.subject_work_email,
        staff_scope.subject_employee_title,
        staff_scope.subject_direct_manager_employee_id,
        staff_scope.subject_market_id,
        staff_scope.subject_market_name,
        staff_scope.subject_district,
        staff_scope.subject_region,
        staff_scope.subject_region_name,
        staff_scope.subject_operator_id,
        -- DEBUG: shows which check is the first to fail so you can identify the real issue
        CASE
          WHEN viewer.full_access THEN 'full_access_granted'
          WHEN viewer.is_driver THEN
            CASE
              WHEN staff_scope.subject_employee_id = viewer.employee_id
              THEN 'PASS: driver → self only'
              ELSE 'FAIL: driver → can only view own record'
            END
          WHEN LOWER('{{ _user_attributes['email'] }}') = 'lee.lobbs@equipmentshare.com'
            AND staff_scope.subject_district IN ('4-2', '4-7')
            THEN 'PASS: hard-coded override → lee.lobbs districts 4-2, 4-7'
          WHEN LOWER('{{ _user_attributes['email'] }}') = 'eric.maki@equipmentshare.com'
            AND staff_scope.subject_district = '2-4'
            THEN 'PASS: hard-coded override → eric.maki district 2-4'
          WHEN LOWER(TRIM(viewer.employee_title)) ILIKE '%regional %' THEN
            CASE
              WHEN (
                UPPER(COALESCE(viewer.region, '')) IN ('NATIONAL', 'CORP')
                OR TRY_TO_NUMBER(REGEXP_REPLACE(staff_scope.subject_region, '^[Rr]', '')) = TRY_TO_NUMBER(REGEXP_REPLACE(viewer.region, '^[Rr]', ''))
                OR staff_scope.subject_region = viewer.region
                OR UPPER(TRIM(staff_scope.subject_region_name)) = UPPER(TRIM(viewer.region_name))
                OR EXISTS (
                  SELECT 1
                  FROM analytics.public.market_region_xwalk mrx
                  WHERE mrx.market_id = staff_scope.subject_market_id
                    AND (mrx.division_name <> 'Materials' OR mrx.division_name IS NULL)
                    AND (
                      TRY_TO_NUMBER(REGEXP_REPLACE(mrx.region::VARCHAR, '^[Rr]', '')) = TRY_TO_NUMBER(REGEXP_REPLACE(viewer.region, '^[Rr]', ''))
                      OR UPPER(TRIM(mrx.region_name)) = UPPER(TRIM(viewer.region_name))
                    )
                )
              ) THEN 'PASS: regional → viewer_region=' || COALESCE(viewer.region, 'NULL') || ' viewer_region_name=' || COALESCE(viewer.region_name, 'NULL')
              ELSE 'FAIL: regional region mismatch → viewer_region=' || COALESCE(viewer.region, 'NULL') || ' subject_region=' || COALESCE(staff_scope.subject_region, 'NULL')
            END
          WHEN LOWER(TRIM(viewer.employee_title)) IN ('district sales manager', 'district operations manager') THEN
            CASE
              WHEN (
                staff_scope.subject_district = viewer.district
                OR staff_scope.subject_direct_manager_employee_id = viewer.employee_id
                OR EXISTS (
                  SELECT 1
                  FROM analytics.public.market_region_xwalk sub_mrx
                  JOIN analytics.public.market_region_xwalk viewer_mrx
                    ON sub_mrx.district = viewer_mrx.district
                  WHERE sub_mrx.market_id = staff_scope.subject_market_id
                    AND (sub_mrx.division_name <> 'Materials' OR sub_mrx.division_name IS NULL)
                    AND viewer_mrx.market_id = viewer.market_id
                    AND (viewer_mrx.division_name <> 'Materials' OR viewer_mrx.division_name IS NULL)
                )
              ) THEN 'PASS: DSM → viewer_district=' || COALESCE(viewer.district, 'NULL')
              ELSE 'FAIL: DSM district mismatch → viewer_district=' || COALESCE(viewer.district, 'NULL') || ' subject_district=' || COALESCE(staff_scope.subject_district, 'NULL')
            END
          WHEN LOWER(TRIM(viewer.employee_title)) ILIKE '%general manager%' THEN
            CASE
              WHEN TO_VARCHAR(staff_scope.subject_market_id) = TO_VARCHAR(viewer.market_id)
              THEN 'PASS: GM → viewer_market=' || COALESCE(TO_VARCHAR(viewer.market_id), 'NULL')
              ELSE 'FAIL: GM market mismatch → viewer_market=' || COALESCE(TO_VARCHAR(viewer.market_id), 'NULL') || ' subject_market=' || COALESCE(TO_VARCHAR(staff_scope.subject_market_id), 'NULL')
            END
          ELSE
            CASE
              WHEN staff_scope.subject_employee_id = viewer.employee_id
              THEN 'PASS: self-only → ' || COALESCE(viewer.employee_title, 'NULL')
              ELSE 'FAIL: self-only → can only view own record → ' || COALESCE(viewer.employee_title, 'NULL')
            END
        END AS debug_access_check,
        -- Person access mirrors the intended dashboard rules: region, district (for DSMs), direct reports, or home market.
        CASE
          WHEN viewer.full_access THEN TRUE
          WHEN viewer.is_driver
            AND staff_scope.subject_employee_id = viewer.employee_id THEN TRUE
          WHEN viewer.is_driver THEN FALSE
          WHEN LOWER('{{ _user_attributes['email'] }}') = 'lee.lobbs@equipmentshare.com'
            AND staff_scope.subject_district IN ('4-2', '4-7') THEN TRUE
          WHEN LOWER('{{ _user_attributes['email'] }}') = 'eric.maki@equipmentshare.com'
            AND staff_scope.subject_district = '2-4' THEN TRUE
          WHEN LOWER(TRIM(viewer.employee_title)) ILIKE '%regional %'
            AND (
              UPPER(COALESCE(viewer.region, '')) IN ('NATIONAL', 'CORP')
              OR TRY_TO_NUMBER(REGEXP_REPLACE(staff_scope.subject_region, '^[Rr]', '')) = TRY_TO_NUMBER(REGEXP_REPLACE(viewer.region, '^[Rr]', ''))
              OR staff_scope.subject_region = viewer.region
              OR UPPER(TRIM(staff_scope.subject_region_name)) = UPPER(TRIM(viewer.region_name))
              OR EXISTS (
                SELECT 1
                FROM analytics.public.market_region_xwalk mrx
                WHERE mrx.market_id = staff_scope.subject_market_id
                  AND (mrx.division_name <> 'Materials' OR mrx.division_name IS NULL)
                  AND (
                    TRY_TO_NUMBER(REGEXP_REPLACE(mrx.region::VARCHAR, '^[Rr]', '')) = TRY_TO_NUMBER(REGEXP_REPLACE(viewer.region, '^[Rr]', ''))
                    OR UPPER(TRIM(mrx.region_name)) = UPPER(TRIM(viewer.region_name))
                  )
              )
            ) THEN TRUE
          WHEN LOWER(TRIM(viewer.employee_title)) IN ('district sales manager', 'district operations manager')
            AND (
              staff_scope.subject_district = viewer.district
              OR staff_scope.subject_direct_manager_employee_id = viewer.employee_id
              OR EXISTS (
                SELECT 1
                FROM analytics.public.market_region_xwalk sub_mrx
                JOIN analytics.public.market_region_xwalk viewer_mrx
                  ON sub_mrx.district = viewer_mrx.district
                WHERE sub_mrx.market_id = staff_scope.subject_market_id
                  AND (sub_mrx.division_name <> 'Materials' OR sub_mrx.division_name IS NULL)
                  AND viewer_mrx.market_id = viewer.market_id
                  AND (viewer_mrx.division_name <> 'Materials' OR viewer_mrx.division_name IS NULL)
              )
            ) THEN TRUE
          WHEN LOWER(TRIM(viewer.employee_title)) ILIKE '%general manager%'
            AND TO_VARCHAR(staff_scope.subject_market_id) = TO_VARCHAR(viewer.market_id) THEN TRUE
          WHEN staff_scope.subject_employee_id = viewer.employee_id THEN TRUE
          ELSE FALSE
        END AS person_access,
        -- Expose the rule that granted access to make validation easier in Explore.
        CASE
          WHEN viewer.full_access THEN 'full_access'
          WHEN viewer.is_driver
            AND staff_scope.subject_employee_id = viewer.employee_id THEN 'driver_self'
          WHEN viewer.is_driver THEN 'none'
          WHEN LOWER('{{ _user_attributes['email'] }}') = 'lee.lobbs@equipmentshare.com'
            AND staff_scope.subject_district IN ('4-2', '4-7') THEN 'hard_coded_district_override'
          WHEN LOWER('{{ _user_attributes['email'] }}') = 'eric.maki@equipmentshare.com'
            AND staff_scope.subject_district = '2-4' THEN 'hard_coded_district_override'
          WHEN LOWER(TRIM(viewer.employee_title)) ILIKE '%regional %'
            AND (
              UPPER(COALESCE(viewer.region, '')) IN ('NATIONAL', 'CORP')
              OR TRY_TO_NUMBER(REGEXP_REPLACE(staff_scope.subject_region, '^[Rr]', '')) = TRY_TO_NUMBER(REGEXP_REPLACE(viewer.region, '^[Rr]', ''))
              OR staff_scope.subject_region = viewer.region
              OR UPPER(TRIM(staff_scope.subject_region_name)) = UPPER(TRIM(viewer.region_name))
              OR EXISTS (
                SELECT 1
                FROM analytics.public.market_region_xwalk mrx
                WHERE mrx.market_id = staff_scope.subject_market_id
                  AND (mrx.division_name <> 'Materials' OR mrx.division_name IS NULL)
                  AND (
                    TRY_TO_NUMBER(REGEXP_REPLACE(mrx.region::VARCHAR, '^[Rr]', '')) = TRY_TO_NUMBER(REGEXP_REPLACE(viewer.region, '^[Rr]', ''))
                    OR UPPER(TRIM(mrx.region_name)) = UPPER(TRIM(viewer.region_name))
                  )
              )
            ) THEN 'region'
          WHEN LOWER(TRIM(viewer.employee_title)) IN ('district sales manager', 'district operations manager')
            AND (
              staff_scope.subject_district = viewer.district
              OR EXISTS (
                SELECT 1
                FROM analytics.public.market_region_xwalk sub_mrx
                JOIN analytics.public.market_region_xwalk viewer_mrx
                  ON sub_mrx.district = viewer_mrx.district
                WHERE sub_mrx.market_id = staff_scope.subject_market_id
                  AND (sub_mrx.division_name <> 'Materials' OR sub_mrx.division_name IS NULL)
                  AND viewer_mrx.market_id = viewer.market_id
                  AND (viewer_mrx.division_name <> 'Materials' OR viewer_mrx.division_name IS NULL)
              )
            ) THEN 'district'
          WHEN LOWER(TRIM(viewer.employee_title)) IN ('district sales manager', 'district operations manager')
            AND staff_scope.subject_direct_manager_employee_id = viewer.employee_id THEN 'direct_report'
          WHEN LOWER(TRIM(viewer.employee_title)) ILIKE '%general manager%'
            AND TO_VARCHAR(staff_scope.subject_market_id) = TO_VARCHAR(viewer.market_id) THEN 'market'
          WHEN staff_scope.subject_employee_id = viewer.employee_id THEN 'self'
          ELSE 'none'
        END AS access_reason
      FROM viewer
      CROSS JOIN staff_scope
      ;;
    }


    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: viewer_employee_id {
      type: number
      sql: ${TABLE}."VIEWER_EMPLOYEE_ID" ;;
      hidden: yes
    }

    dimension: viewer_work_email {
      type: string
      sql: ${TABLE}."VIEWER_WORK_EMAIL" ;;
    }

    dimension: viewer_employee_title {
      type: string
      sql: ${TABLE}."VIEWER_EMPLOYEE_TITLE" ;;
    }

    dimension: viewer_market_id {
      type: string
      sql: ${TABLE}."VIEWER_MARKET_ID" ;;
      hidden: yes
    }

    dimension: viewer_district {
      type: string
      sql: ${TABLE}."VIEWER_DISTRICT" ;;
      hidden: yes
    }

    dimension: viewer_region {
      type: string
      sql: ${TABLE}."VIEWER_REGION" ;;
      hidden: yes
    }

    dimension: subject_operator_id {
    type: string
    sql: ${TABLE}."SUBJECT_OPERATOR_ID" ;;
  }

    dimension: subject_employee_id {
      type: number
      primary_key: yes
      sql: ${TABLE}."SUBJECT_EMPLOYEE_ID" ;;
    }

    dimension: subject_work_email {
      type: string
      sql: ${TABLE}."SUBJECT_WORK_EMAIL" ;;
    }

    dimension: subject_employee_title {
      type: string
      sql: ${TABLE}."SUBJECT_EMPLOYEE_TITLE" ;;
    }

    dimension: subject_direct_manager_employee_id {
      type: number
      sql: ${TABLE}."SUBJECT_DIRECT_MANAGER_EMPLOYEE_ID" ;;
      hidden: yes
    }

    dimension: subject_market_id {
      type: string
      sql: ${TABLE}."SUBJECT_MARKET_ID" ;;
    }

    dimension: subject_market_name {
      type: string
      sql: ${TABLE}."SUBJECT_MARKET_NAME" ;;
    }

    dimension: subject_district {
      type: string
      sql: ${TABLE}."SUBJECT_DISTRICT" ;;
    }

    dimension: subject_region_name {
      type: string
      sql: ${TABLE}."SUBJECT_REGION_NAME" ;;
    }

    dimension: subject_region {
      type: string
      sql: ${TABLE}."SUBJECT_REGION" ;;
      hidden: yes
    }

    dimension: person_access {
      type: yesno
      sql: ${TABLE}."PERSON_ACCESS" ;;
    }

    dimension: access_reason {
      type: string
      sql: ${TABLE}."ACCESS_REASON" ;;
    }

    set: detail {
      fields: [
        viewer_work_email,
        viewer_employee_title,
        subject_employee_id,
        subject_work_email,
        subject_employee_title,
        subject_market_id,
        subject_market_name,
        subject_district,
        subject_region_name,
        access_reason
      ]
    }
  }
