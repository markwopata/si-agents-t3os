view: safety_monthly_reporting_amalgamation {
  derived_table: {
    sql:
    WITH employee_info_transform AS (
        SELECT
            employee_id,
            cd.market_id,
            mrx.market_name,
            mrx.market_type,
            mrx.district,
            mrx.region,
            IFF(REGEXP_LIKE(LEFT(split_part(cd.default_cost_centers_full_path, '/', 1), 2), 'R[0-9]+'),
                   2, 1) as DCCFP_type,
            CASE WHEN DCCFP_type = 1
                    THEN IFF(REGEXP_LIKE(LEFT(split_part(cd.default_cost_centers_full_path, '/', 2), 2), 'R[0-9]+'),
                             IFF(split_part(cd.default_cost_centers_full_path, '/', 2) NOT LIKE '% %',
                                 RIGHT(split_part(cd.default_cost_centers_full_path, '/', 2),
                                       len(split_part(cd.default_cost_centers_full_path, '/', 2)) - 1
                                      ),
                                 SUBSTR(split_part(cd.default_cost_centers_full_path, '/', 2), 2,
                                        CHARINDEX(' ', split_part(cd.default_cost_centers_full_path, '/', 2)) - 1
                                       )
                                ),
                             split_part(cd.default_cost_centers_full_path, '/', 2)
                            )
                 WHEN DCCFP_type = 2
                    THEN IFF(split_part(cd.default_cost_centers_full_path, '/', 1) NOT LIKE '% %',
                             RIGHT(split_part(cd.default_cost_centers_full_path, '/', 1),
                                   len(split_part(cd.default_cost_centers_full_path, '/', 1)) - 1
                                  ),
                             SUBSTR(split_part(cd.default_cost_centers_full_path, '/', 1), 2,
                                    CHARINDEX(' ', split_part(cd.default_cost_centers_full_path, '/', 1)) - 1
                                   )
                            )
            END as dccfp_region,
            CASE WHEN DCCFP_type = 1 THEN IFF(REGEXP_LIKE(split_part(cd.default_cost_centers_full_path, '/', 3), '[0-9]+-[0-9]+'),
                                              split_part(cd.default_cost_centers_full_path, '/', 3), null
                                             )
                 WHEN DCCFP_type = 2 THEN IFF(REGEXP_LIKE(split_part(cd.default_cost_centers_full_path, '/', 2), '[0-9]+-[0-9]+'),
                                              split_part(cd.default_cost_centers_full_path, '/', 2), null
                                             )
            END as dccfp_district
        FROM analytics.payroll.company_directory cd
        LEFT JOIN analytics.public.market_region_xwalk mrx ON cd.market_id = mrx.market_id
        WHERE cd.employee_status IN ('Active', 'External Payroll', 'Military Intern', 'On Leave', 'Seasonal (Fixed Term) (Seasonal)')
    )

    , employee_info AS (
        SELECT
            employee_id,
            market_id::varchar as market_id,
            market_name,
            market_type,
            TRIM(COALESCE(region::varchar, IFF(TRIM(dccfp_region) rlike '^[0-9]$', dccfp_region::varchar, null))) as region,
            TRIM(COALESCE(district, dccfp_district)) as district,
        FROM employee_info_transform
    )

    -- TOTAL & RECORDABLE INJURIES
    -- Year to date date_of_incident
    -- location data from mrx in this join order: market_id, branch name, work location
    -- if no join, pulls from given region or district
    -- district is numeric dash numeric e.g. 2-1; also includes 'Corporate', 'Moberly'
    , injury_tracker AS (
        SELECT
            coalesce(mrx.region::varchar,
                     mrx_branch.region::varchar,
                     mrx_location.region::varchar,
                     IFF(LEFT(itb.region, 6) = 'Region', SPLIT_PART(itb.region, 'Region ', 2), itb.region),
                     try_to_decimal(left(itb.district, 1))::varchar
                     ) as region,
            coalesce(mrx.district, mrx_branch.district, itb.district) as district,
            coalesce(itb.market_id::varchar, mrx_branch.market_id::varchar, mrx_location.market_id::varchar) as market_id,
            coalesce(mrx.market_name, itb.branch, mrx_location.market_name) as market_name,
            coalesce(mrx.market_type, mrx_branch.market_type, mrx_location.market_type) as market_type,
            itb.location,
            itb.work_location,
            itb.recordable
        FROM analytics.monday.injury_tracker_board itb
        LEFT JOIN analytics.public.market_region_xwalk mrx
            ON itb.market_id = mrx.market_id
        LEFT JOIN analytics.public.market_region_xwalk mrx_branch
            ON itb.branch = mrx_branch.market_name
        LEFT JOIN analytics.public.market_region_xwalk mrx_location
            ON lower(trim(itb.work_location)) = lower(trim(mrx_location.market_name))
        where date_of_incident >= DATE_TRUNC('year',
                DATEADD(day, -1, COALESCE({% parameter as_of_date %}, current_date()))
              )
          and date_of_incident < COALESCE({% parameter as_of_date %}, current_date())
    )

    , INJURIES_AGGREGATE AS (
        SELECT
            market_id,
            market_name,
            market_type,
            IFF(region rlike '^[0-9]$', region, null) as region,
            IFF(district rlike '^[0-9]-[0-9]{1,2}$', district, null) as district,
            sum(IFF(recordable ilike 'yes', 1, 0)) as recordable_injuries,
            count(*) as total_injuries
        FROM injury_tracker
        WHERE region rlike '^[0-9]$'
        GROUP BY
            market_id,
            market_name,
            market_type,
            IFF(region rlike '^[0-9]$', region, null),
            IFF(district rlike '^[0-9]-[0-9]{1,2}$', district, null)
    )

    -- AT-FAULT AUTO ACCIDENTS
    -- Year to date
    -- if there's not a mrx join on market id or location, then rely on EE info
    , at_fault_accidents AS (
        SELECT
            COALESCE(mva.market_id::varchar, mrx_name.market_id::varchar, ei.market_id::varchar) as market_id,
            COALESCE(mrx_id.market_name, mrx_name.market_name, ei.market_name, mva.location) as market_name,
            COALESCE(mrx_id.market_type, mrx_name.market_type, ei.market_type, mva.market_type) as market_type,
            COALESCE(mrx_id.region::varchar, mrx_name.region::varchar, ei.region::varchar) as region,
            COALESCE(mrx_id.district, mrx_name.district, ei.district) as district,
        FROM analytics.monday.motor_vehicle_accidents_board mva
        LEFT JOIN analytics.public.market_region_xwalk mrx_id
            ON mva.market_id = mrx_id.market_id
        LEFT JOIN analytics.public.market_region_xwalk mrx_name
            ON lower(trim(mva.location)) = lower(trim(mrx_name.market_name))
        LEFT JOIN employee_info ei ON ei.employee_id = mva.employee_id
        WHERE mva.at_fault = 'At-Fault'
          AND mva.incident_date >= DATE_TRUNC('year',
                DATEADD(day, -1, COALESCE({% parameter as_of_date %}, current_date()))
              )
          and mva.incident_date < COALESCE({% parameter as_of_date %}, current_date())
    )

    , AT_FAULT_ACCIDENTS_AGGREGATE as (
    SELECT
        market_id,
        market_name,
        market_type,
        IFF(region rlike '^[0-9]$', region, null) as region,
        IFF(district rlike '^[0-9]-[0-9]{1,2}$', district, null) as district,
        COUNT(*) as at_fault_auto_accidents
    FROM at_fault_accidents
    where region rlike '^[0-9]$'
    GROUP BY
        market_id,
        market_name,
        market_type,
        IFF(region rlike '^[0-9]$', region, null),
        IFF(district rlike '^[0-9]-[0-9]{1,2}$', district, null)
    )

    -- INCOMPLETE SAFETY COURSES
    -- location data from employee info, which is leftmost table
    -- for now, excluding null market_name data
    , esu_courses as (
        SELECT name as course_name
        from ANALYTICS.DOCEBO.courses
        WHERE id_course IN (
          331, 2050, 1948, 1947, 1843, 1840, 839, 1841, 1839, 1842,
          1649, 838, 1609, 1860, 1859, 1864, 1026, 921, 1861, 1876,
          1865, 1853, 1854, 1868, 1757, 1863, 712, 2305, 1875, 665,
          2412, 2424, 2426, 2427, 2425, 2440, 2409, 2408, 2407, 2406,
          2414, 2405, 2404, 2403, 2402, 2401, 2423, 2400, 2398, 2397,
          1442, 1450, 1451, 1452, 1907, 1252
        )
    )

    , esu_enrollment as (
        SELECT
            eh.enrollment_date_expire_validity,
            eh.enrollment_status,
            eh.enrollment_date_expire_validity < COALESCE({% parameter as_of_date %}, current_date())
              AND lower(eh.enrollment_status) <> 'completed' as overdue,
            ei.market_id,
            ei.market_name,
            ei.market_type,
            ei.region,
            ei.district
        FROM employee_info ei
        JOIN analytics.docebo.users u ON to_varchar(ei.employee_id) = REPLACE((u.field_4),'CW','')
        JOIN analytics.docebo.enrollment_history eh ON u.encoded_username = eh.user_userid
        JOIN esu_courses c ON c.course_name = eh.course_name
        LEFT JOIN analytics.docebo.enrollments enr ON eh.course_uidcourse = enr.course_uid AND eh.user_userid = enr.username
        WHERE eh.enrollment_date_expire_validity is not null
          AND eh.archived_enrollment_yes_no = 'No'
          AND (NOT((enr.enrollment_created_by) = (enr.user_id)) OR ((enr.enrollment_created_by) = (enr.user_id)) IS NULL)
    )

    , INCOMPLETE_ESU_SAFETY_COURSES as (
    select
        market_id,
        market_name,
        market_type,
        IFF(region rlike '^[0-9]$', region, null) as region,
        IFF(district rlike '^[0-9]-[0-9]{1,2}$', district, null) as district,
        SUM(IFF(overdue, 1, 0)) as incomplete_esu_safety_courses
    from esu_enrollment
    where region rlike '^[0-9]$'
    group by
        market_id,
        market_name,
        market_type,
        IFF(region rlike '^[0-9]$', region, null),
        IFF(district rlike '^[0-9]-[0-9]{1,2}$', district, null)
    )

    -- INCOMPLETE SAFETY MEETING
    -- weekly only
    -- non-sales
    -- there are instances where market_name is null and region or district is not null
    -- if district is non-null so is region, but not necessarily vice-versa
    -- 2026 onward
    , safety_meeting_attendance AS (
        SELECT
            market_id::varchar as market_id,
            market_name,
            market_type,
            district,
            region_abrv::varchar as region_abrv,
            region_name,
            current_work_email,
            employee_title,
            employee_type,
            manager_email,
            eligible_topic_name,
            eligible_topic_start_date::date as eligible_topic_start_date,
            attended_topic <> 1 OR attended_topic IS NULL as incomplete
        FROM analytics.bi_ops.safety_meeting_attendance
        WHERE eligible_topic_start_date::date >= DATE_TRUNC('year',
                DATEADD(day, -1, COALESCE({% parameter as_of_date %}, current_date()))
              )
          AND eligible_topic_start_date::date < COALESCE({% parameter as_of_date %}, current_date())
          AND topic_type = 'Weekly'
          AND employee_type = 'Non-Sales'
    )

    , INCOMPLETE_SAFETY_MEETINGS as (
        SELECT
            market_id,
            market_name,
            market_type,
            IFF(region_abrv rlike '^[0-9]$', region_abrv, null) as region,
            IFF(district rlike '^[0-9]-[0-9]{1,2}$', district, null) as district,
            SUM(IFF(incomplete, 1, 0)) as incomplete_safety_meetings
        FROM safety_meeting_attendance
        WHERE region_abrv rlike '^[0-9]$'
        GROUP BY
            market_id,
            market_name,
            market_type,
            IFF(region_abrv rlike '^[0-9]$', region_abrv, null),
            IFF(district rlike '^[0-9]-[0-9]{1,2}$', district, null)
    )

    , MARKET_SPINE AS (
        SELECT market_id
        FROM INJURIES_AGGREGATE
        UNION
        SELECT market_id
        FROM AT_FAULT_ACCIDENTS_AGGREGATE
        UNION
        SELECT market_id
        FROM INCOMPLETE_ESU_SAFETY_COURSES
        UNION
        SELECT market_id
        FROM INCOMPLETE_SAFETY_MEETINGS
    )

    SELECT
        COALESCE(esu.market_id, sftm.market_id, inj.market_id, afa.market_id)         as market_id,
        COALESCE(esu.market_name, sftm.market_name, inj.market_name, afa.market_name) as market_name,
        COALESCE(esu.market_type, sftm.market_type, inj.market_type, afa.market_type) as market_type,
        COALESCE(esu.region, sftm.region, inj.region, afa.region)                     as region,
        COALESCE(esu.district, sftm.district, inj.district, afa.district)             as district,
        COALESCE(inj.recordable_injuries, 0)                                          as recordable_injuries,
        COALESCE(inj.total_injuries, 0)                                               as total_injuries,
        COALESCE(afa.at_fault_auto_accidents, 0)                                      as at_fault_auto_accidents,
        COALESCE(esu.incomplete_esu_safety_courses, 0)                                as incomplete_esu_safety_courses,
        COALESCE(sftm.incomplete_safety_meetings, 0)                                  as incomplete_safety_meetings
    FROM MARKET_SPINE ms
    LEFT JOIN INJURIES_AGGREGATE inj
        ON ms.market_id = inj.market_id
    LEFT JOIN AT_FAULT_ACCIDENTS_AGGREGATE afa
        ON ms.market_id = afa.market_id
    LEFT JOIN INCOMPLETE_ESU_SAFETY_COURSES esu
        ON ms.market_id = esu.market_id
    LEFT JOIN INCOMPLETE_SAFETY_MEETINGS sftm
        ON ms.market_id = sftm.market_id
    order by region, district, market_id
    ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: recordable_injuries {
    type: number
    sql: ${TABLE}."RECORDABLE_INJURIES" ;;
  }

  dimension: total_injuries {
    type: number
    sql: ${TABLE}."TOTAL_INJURIES" ;;
  }

  dimension: at_fault_auto_accidents {
    type: number
    sql: ${TABLE}."AT_FAULT_AUTO_ACCIDENTS" ;;
  }

  dimension: incomplete_esu_safety_courses {
    type: number
    sql: ${TABLE}."INCOMPLETE_ESU_SAFETY_COURSES" ;;
  }

  dimension: incomplete_safety_meetings {
    type: number
    sql: ${TABLE}."INCOMPLETE_SAFETY_MEETINGS" ;;
  }

  parameter: as_of_date {
    type: date
  }
}
