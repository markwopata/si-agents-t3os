-- raw data
WITH raw AS (
  SELECT
      RECORD_CONTENT:time::TIMESTAMP_TZ AS assignment_time,
      TO_VARCHAR(RECORD_CONTENT:data:t3_asset_id) AS asset_id_raw,
      TO_VARCHAR(RECORD_CONTENT:data:operator_assignment:operator_id) AS operator_id_raw,
      TO_VARCHAR(RECORD_CONTENT:data:operator_assignment:operator_name) AS operator_name_raw,
      TO_VARCHAR(RECORD_CONTENT:data:operator_assignment:t3_company_id) AS company_id_raw,
      TO_VARCHAR(RECORD_CONTENT:data:operator_assignment:t3_user_id) AS user_id_raw,
      CASE RECORD_CONTENT:type::STRING
        WHEN 'operators-api.operators.created_operator_assignment' THEN 'CREATED'
        WHEN 'operators-api.operators.ended_operator_assignment'   THEN 'ENDED'
        ELSE NULL
      END AS record_type
  FROM confluent.public.operator_assignments
  WHERE RECORD_CONTENT:type::STRING IN (
    'operators-api.operators.created_operator_assignment',
    'operators-api.operators.ended_operator_assignment'
  )
),

-- filtered raw data
filtered AS (
  SELECT
    assignment_time,
    TRIM(asset_id_raw) AS asset_id,
    TRIM(operator_id_raw) AS operator_id,
    TRIM(operator_name_raw) AS operator_name_raw,
    TRIM(company_id_raw) AS company_id,
    TRIM(user_id_raw) AS user_id,
    record_type
  FROM raw
  WHERE assignment_time IS NOT NULL
    -- remove rows with missing asset id
    AND COALESCE(TRIM(asset_id_raw), '') <> ''
    AND record_type IN ('CREATED','ENDED')
    -- remove CREATE events with no operator info
    AND NOT (record_type = 'CREATED'
           AND COALESCE(TRIM(operator_id_raw),'') = ''
           AND COALESCE(TRIM(operator_name_raw),'') = '')
),

-- created new operator_name
norm AS (
  SELECT
    assignment_time,
    asset_id,
    operator_id,
    operator_name_raw,
    company_id,
    user_id,
    -- removes trailing white space, upper/lower case diffs, and spaces in between first and last name
    LOWER(REGEXP_REPLACE(TRIM(operator_name_raw), '\\s+', ' ')) AS operator_name,
    record_type
  FROM filtered
),

-- removes duplicate rows
de_dupe AS (
  SELECT *
  FROM (
    SELECT
      assignment_time, asset_id, record_type,
      operator_id, operator_name, company_id, user_id,
      ROW_NUMBER() OVER (
        PARTITION BY asset_id, assignment_time, record_type, COALESCE(operator_id,''), COALESCE(operator_name,'')
        ORDER BY assignment_time
      ) AS rn
    FROM norm
  )
  WHERE rn = 1
),

collapse_created AS (

  -- checks for assets assigned at the same time
  WITH agg AS (
    SELECT
      asset_id, assignment_time,
      COUNT(*)                    AS created_count,
      COUNT(DISTINCT operator_id) AS distinct_ops,
      MIN(operator_id)             AS min_operator_id
    FROM de_dupe
    WHERE record_type = 'CREATED'
    GROUP BY ALL
  )
  SELECT
    d.assignment_time,
    d.asset_id,
    -- chooses MIN operator in case of multiple simultaneous assignments
    CASE WHEN a.distinct_ops > 1 THEN a.min_operator_id ELSE d.operator_id END AS operator_id,
    d.operator_name, d.company_id, d.user_id,
    'CREATED' AS record_type,
    CASE
      WHEN a.distinct_ops > 1 THEN 'assumed - multiple assigned operators at the same time, chose one'
      ELSE 'no assumption'
    END AS assumed_event
  FROM de_dupe d
  INNER JOIN agg a USING(asset_id, assignment_time)
  WHERE d.record_type = 'CREATED'
    AND (a.distinct_ops = 1 OR d.operator_id = a.min_operator_id)
),

-- establishes default assumptions for END events
ended_kept AS (
  SELECT
    assignment_time, asset_id, operator_id, operator_name, company_id, user_id,
    'ENDED' AS record_type, 'no assumption' AS assumed_event
  FROM de_dupe
  WHERE record_type = 'ENDED'
),

-- combines CREATE and END events 
event_stream AS (
  SELECT * FROM collapse_created
  UNION ALL
  SELECT * FROM ended_kept
),

-- sequences by asset per time created
ordered AS (
  SELECT
    assignment_time, asset_id, operator_id,
    operator_name, company_id, user_id, record_type, assumed_event,
    ROW_NUMBER() OVER (
      PARTITION BY asset_id
      ORDER BY assignment_time ASC,
               CASE record_type WHEN 'CREATED' THEN 0 ELSE 1 END ASC,
               COALESCE(operator_id,'')
    ) AS seq
  FROM event_stream
),

-- first CREATE event per asset
first_created AS (
  SELECT asset_id, MIN(assignment_time) AS first_created_ts
  FROM ordered
  WHERE record_type = 'CREATED'
  GROUP BY asset_id
),

-- removes END events before first CREATE event
stream_pruned AS (
  SELECT o.*
  FROM ordered o
  INNER JOIN first_created f USING(asset_id)
  WHERE NOT (o.record_type = 'ENDED' AND o.assignment_time < f.first_created_ts)
),

-- identifies previous CREATE event, next CREATE event, and if there are END events at the same time
created_with_next AS (
  SELECT
    s.asset_id,
    s.assignment_time AS start_time,
    s.operator_id,
    s.operator_name,
    s.company_id, 
    s.user_id,
    cc.assumed_event,
    LAG(CASE WHEN s.record_type = 'CREATED' THEN s.assignment_time END)
      IGNORE NULLS
      OVER (PARTITION BY s.asset_id ORDER BY s.assignment_time, s.record_type) AS prev_created_time,
    LEAD(CASE WHEN s.record_type = 'CREATED' THEN s.assignment_time END)
      IGNORE NULLS
      OVER (PARTITION BY s.asset_id ORDER BY s.assignment_time, s.record_type) AS next_created_time,
    CASE 
      WHEN EXISTS (
        SELECT 1
        FROM stream_pruned e2
        WHERE e2.asset_id = s.asset_id
          AND e2.record_type = 'ENDED'
          AND e2.assignment_time = s.assignment_time
      ) 
      THEN 1 
      ELSE 0 
    END AS has_end_same_ts
  FROM stream_pruned s
  INNER JOIN collapse_created cc USING(asset_id, assignment_time)
  WHERE s.record_type = 'CREATED'
),

-- find the first END event after each CREATE event
ended_window AS (
  SELECT
    c.asset_id,
    c.start_time,
    MIN(e.assignment_time) AS end_after_start,
    COUNT(*)              AS ended_in_window
  FROM created_with_next c
  LEFT JOIN stream_pruned e
    ON e.asset_id = c.asset_id
   AND e.record_type = 'ENDED'
   AND e.assignment_time > c.start_time
   AND (c.next_created_time IS NULL OR e.assignment_time <= c.next_created_time)
  GROUP BY c.asset_id, c.start_time
),

-- If there’s an ENDED in the window → use it as end_time
-- Else if an ENDED exists exactly at the start and there was no prior open → treat as instantaneous assign–unassign (end = start)
-- Else if there’s a next CREATED → end at the next start (clean handoff)
-- Else → leave the session open (end_time = NULL)
-- Also assigns the correct assumed_event label
sessions_with_end AS (
  SELECT
    c.asset_id,
    c.start_time,
    c.operator_id,
    c.operator_name,
    c.company_id, 
    c.user_id,
    CASE
      WHEN ew.end_after_start IS NOT NULL
        THEN ew.end_after_start
      WHEN c.has_end_same_ts = 1 AND c.prev_created_time IS NULL
        THEN c.start_time
      WHEN c.next_created_time IS NOT NULL
        THEN c.next_created_time
      ELSE NULL
    END AS end_time,
    CASE
      WHEN ew.end_after_start IS NOT NULL AND ew.ended_in_window > 1
        THEN 'assumed - took min end'
      WHEN c.has_end_same_ts = 1 AND c.prev_created_time IS NULL
        THEN 'assumed - instantaneous assign-unassign'
      WHEN ew.end_after_start IS NULL AND c.next_created_time IS NOT NULL
        THEN 'assumed - closed by next create'
      ELSE c.assumed_event
    END AS assumed_event
  FROM created_with_next c
  LEFT JOIN ended_window ew USING(asset_id, start_time)
),

final_data AS (
  SELECT
    asset_id,
    start_time AS assignment_time,
    end_time AS unassignment_time,
    operator_id,
    operator_name,
    company_id, 
    user_id,
    assumed_event,
    CASE WHEN end_time IS NULL THEN TRUE ELSE FALSE END AS is_currently_assigned
  FROM sessions_with_end
  WHERE start_time IS NOT NULL AND start_time != '0001-01-01T00:00:00Z'
  GROUP BY ALL
)


SELECT 
  a.ASSET_ID, 
  COALESCE(a.COMPANY_ID, b.COMPANY_ID::VARCHAR) AS ASSET_COMPANY_ID, 
  INITCAP(COALESCE(a.operator_name, CONCAT(u.first_name, ' ', u.last_name))) AS OPERATOR_NAME, 
  COALESCE(a.user_id, m.t3_user_id::VARCHAR) AS USER_ID, 
  a.OPERATOR_ID, 
  a.ASSIGNMENT_TIME, 
  COALESCE(a.UNASSIGNMENT_TIME,'2999-12-31 00:00:00.000 +0000') as UNASSIGNMENT_TIME, 
  a.IS_CURRENTLY_ASSIGNED AS CURRENT_ASSIGNMENT,
  a.assumed_event
FROM 
final_data a   
INNER JOIN es_warehouse.public.assets b USING (ASSET_ID) -- extra company_id reference
LEFT JOIN analytics.fleetcam.operator_user_map m ON a.operator_id = m.operator_id::VARCHAR -- extra user_id reference
LEFT JOIN es_warehouse.public.users u ON COALESCE(a.user_id, m.t3_user_id::VARCHAR) = u.user_id::VARCHAR -- extra operator_name reference
GROUP BY ALL 