view: geofence_competition {

  derived_table: {
    sql:
WITH
PARAMS AS (
  SELECT
    365::INT AS DAYS_BACK,
    0.20::FLOAT AS TARGET_SHARED_REDUCTION_PCT
),

/* 1) 365-day usage */
FILTERED_USAGE AS (
  SELECT fu.*
  FROM business_intelligence.triage.stg_t3__geofence_asset_usage fu
  CROSS JOIN PARAMS p
  WHERE fu.COMPANY_ID = 109154
    AND fu.USAGE_DATE >= CURRENT_DATE - p.DAYS_BACK
),

/* 2) Geofence -> H3 cluster (Res 8) */
CLUSTERS AS (
  SELECT
    H3_LATLNG_TO_CELL(l.LATITUDE, l.LONGITUDE, 8) AS CLUSTER_ID,
    g.GEOFENCE_ID
  FROM es_warehouse.public.geofences g
  JOIN es_warehouse.public.locations l USING (LOCATION_ID)
  WHERE H3_LATLNG_TO_CELL(l.LATITUDE, l.LONGITUDE, 8) IS NOT NULL
),

/* 3) Keep clusters with >= 3 geofences */
CLUSTERS_3G AS (
  SELECT CLUSTER_ID
  FROM CLUSTERS
  GROUP BY 1
  HAVING COUNT(DISTINCT GEOFENCE_ID) >= 3
),

/* 4) Asset <-> geofence <-> cluster annual hours + asset_class
      asset_type comes from usage table */
ASSET_GEOFENCE_CLUSTER AS (
  SELECT
    fu.ASSET_ID,
    fu.ASSET_TYPE,
    COALESCE(a.ASSET_CLASS, 'UNKNOWN') AS ASSET_CLASS,
    c.GEOFENCE_ID,
    c.CLUSTER_ID,
    SUM(fu.HOURS_IN_GEOFENCE) AS HOURS
  FROM FILTERED_USAGE fu
  JOIN CLUSTERS c USING (GEOFENCE_ID)
  JOIN CLUSTERS_3G cg USING (CLUSTER_ID)
  LEFT JOIN es_warehouse.public.assets a
    ON a.ASSET_ID = fu.ASSET_ID
  GROUP BY 1,2,3,4,5
),

/* 5) Shared assets = touch 2+ geofences within a cluster */
ASSET_CLUSTER_TOUCH AS (
  SELECT
    ASSET_ID,
    CLUSTER_ID,
    COUNT(DISTINCT GEOFENCE_ID) AS GEOFENCES_TOUCHED
  FROM ASSET_GEOFENCE_CLUSTER
  GROUP BY 1,2
),

/* 6) Cluster totals */
CLUSTER_TOTALS AS (
  SELECT
    CLUSTER_ID,
    SUM(HOURS) AS TOTAL_USAGE
  FROM ASSET_GEOFENCE_CLUSTER
  GROUP BY 1
),

/* 7) Cluster shared pressure */
CLUSTER_SHARED AS (
  SELECT
    agc.CLUSTER_ID,
    SUM(IFF(act.GEOFENCES_TOUCHED >= 2, agc.HOURS, 0)) AS SHARED_USAGE,
    COUNT(DISTINCT IFF(act.GEOFENCES_TOUCHED >= 2, agc.ASSET_ID, NULL)) AS SHARED_ASSETS,
    COUNT(DISTINCT agc.GEOFENCE_ID) AS GEOFENCES
  FROM ASSET_GEOFENCE_CLUSTER agc
  JOIN ASSET_CLUSTER_TOUCH act
    ON act.CLUSTER_ID = agc.CLUSTER_ID
   AND act.ASSET_ID   = agc.ASSET_ID
  GROUP BY 1
),

/* 8) Qualified clusters (guardrails) */
CLUSTER_PRESSURE AS (
  SELECT
    cs.CLUSTER_ID,
    ct.TOTAL_USAGE,
    cs.SHARED_USAGE,
    cs.SHARED_ASSETS,
    cs.GEOFENCES,
    cs.SHARED_USAGE / NULLIF(ct.TOTAL_USAGE, 0) AS SHARED_RATIO
  FROM CLUSTER_SHARED cs
  JOIN CLUSTER_TOTALS ct USING (CLUSTER_ID)
  WHERE cs.SHARED_ASSETS >= 3
    AND ct.TOTAL_USAGE >= 100
    AND cs.SHARED_USAGE / NULLIF(ct.TOTAL_USAGE, 0) >= 0.20
),

/* 9) Geofence shared usage distribution (concentration check) */
GEOFENCE_SHARED AS (
  SELECT
    agc.CLUSTER_ID,
    agc.GEOFENCE_ID,
    SUM(IFF(act.GEOFENCES_TOUCHED >= 2, agc.HOURS, 0)) AS SHARED_HOURS
  FROM ASSET_GEOFENCE_CLUSTER agc
  JOIN ASSET_CLUSTER_TOUCH act
    ON act.CLUSTER_ID = agc.CLUSTER_ID
   AND act.ASSET_ID   = agc.ASSET_ID
  GROUP BY 1,2
),

RANKED_GEOFENCE AS (
  SELECT
    CLUSTER_ID,
    GEOFENCE_ID,
    SHARED_HOURS,
    ROW_NUMBER() OVER (PARTITION BY CLUSTER_ID ORDER BY SHARED_HOURS DESC) AS RN
  FROM GEOFENCE_SHARED
),

TOP12 AS (
  SELECT
    CLUSTER_ID,
    SUM(IFF(RN = 1, SHARED_HOURS, 0)) AS TOP1_SHARED_HOURS,
    SUM(IFF(RN IN (1,2), SHARED_HOURS, 0)) AS TOP2_SHARED_HOURS
  FROM RANKED_GEOFENCE
  GROUP BY 1
),

/* 10) ADD_FLEET candidate clusters (rules) */
ADD_FLEET_CANDIDATES AS (
  SELECT
    cp.CLUSTER_ID,
    cp.TOTAL_USAGE,
    cp.SHARED_USAGE,
    cp.SHARED_ASSETS,
    cp.GEOFENCES,
    cp.SHARED_RATIO,
    td.TOP1_SHARED_HOURS / NULLIF(cp.SHARED_USAGE, 0) AS TOP1_SHARE,
    td.TOP2_SHARED_HOURS / NULLIF(cp.SHARED_USAGE, 0) AS TOP2_SHARE
  FROM CLUSTER_PRESSURE cp
  JOIN TOP12 td USING (CLUSTER_ID)
  WHERE cp.SHARED_RATIO >= 0.70
    AND cp.SHARED_USAGE >= 500
    AND (td.TOP2_SHARED_HOURS / NULLIF(cp.SHARED_USAGE, 0)) <= 0.85
),

/* 11) Top clusters (<=5; if fewer qualify, returns fewer) */
TOP_ADD_FLEET_CLUSTERS AS (
  SELECT *
  FROM ADD_FLEET_CANDIDATES
  ORDER BY SHARED_USAGE DESC
  LIMIT 5
),

/* =========================================================
CAPACITY BENCHMARK (asset_id productivity inside cluster)
========================================================= */

/* 12) Shared-only asset hours within each cluster (asset_id-level) */
CLUSTER_SHARED_ASSET_HOURS AS (
  SELECT
    agc.CLUSTER_ID,
    agc.ASSET_ID,
    SUM(agc.HOURS) AS ASSET_HOURS_IN_CLUSTER
  FROM ASSET_GEOFENCE_CLUSTER agc
  JOIN ASSET_CLUSTER_TOUCH act
    ON act.CLUSTER_ID = agc.CLUSTER_ID
   AND act.ASSET_ID   = agc.ASSET_ID
  JOIN TOP_ADD_FLEET_CLUSTERS top
    ON top.CLUSTER_ID = agc.CLUSTER_ID
  WHERE act.GEOFENCES_TOUCHED >= 2
  GROUP BY 1,2
),

/* 13) Cluster-level productivity benchmark: p75 hours per shared asset */
CLUSTER_PRODUCTIVITY AS (
  SELECT
    CLUSTER_ID,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ASSET_HOURS_IN_CLUSTER) AS P75_HOURS_PER_SHARED_ASSET
  FROM CLUSTER_SHARED_ASSET_HOURS
  GROUP BY 1
),

/* 14) Cluster-level total assets-to-add (based on target reduction in shared hours) */
CLUSTER_ADD_TOTAL AS (
  SELECT
    top.CLUSTER_ID,
    top.TOTAL_USAGE,
    top.SHARED_USAGE,
    top.SHARED_RATIO,
    top.SHARED_ASSETS,
    top.GEOFENCES,
    top.TOP1_SHARE,
    top.TOP2_SHARE,
    p.TARGET_SHARED_REDUCTION_PCT,
    (top.SHARED_USAGE * p.TARGET_SHARED_REDUCTION_PCT) AS TARGET_REDUCTION_HOURS,
    cp.P75_HOURS_PER_SHARED_ASSET,
    CEIL(
      (top.SHARED_USAGE * p.TARGET_SHARED_REDUCTION_PCT)
      / NULLIF(cp.P75_HOURS_PER_SHARED_ASSET, 0)
    ) AS TOTAL_ASSETS_TO_ADD_EST
  FROM TOP_ADD_FLEET_CLUSTERS top
  JOIN CLUSTER_PRODUCTIVITY cp USING (CLUSTER_ID)
  CROSS JOIN PARAMS p
),

/* =========================================================
ALLOCATE total add count across asset_type + asset_class
based on shared-hours mix inside cluster
========================================================= */

/* 15) Shared-hours mix by (asset_type, asset_class) inside cluster */
CLUSTER_SHARED_MIX AS (
  SELECT
    agc.CLUSTER_ID,
    agc.ASSET_TYPE,
    agc.ASSET_CLASS,
    SUM(IFF(act.GEOFENCES_TOUCHED >= 2, agc.HOURS, 0)) AS SHARED_HOURS_BY_CLASS
  FROM ASSET_GEOFENCE_CLUSTER agc
  JOIN ASSET_CLUSTER_TOUCH act
    ON act.CLUSTER_ID = agc.CLUSTER_ID
   AND act.ASSET_ID   = agc.ASSET_ID
  JOIN TOP_ADD_FLEET_CLUSTERS top
    ON top.CLUSTER_ID = agc.CLUSTER_ID
  GROUP BY 1,2,3
),

CLUSTER_SHARED_MIX_WITH_SHARE AS (
  SELECT
    m.*,
    (m.SHARED_HOURS_BY_CLASS
      / NULLIF(SUM(m.SHARED_HOURS_BY_CLASS) OVER (PARTITION BY m.CLUSTER_ID), 0)
    ) AS MIX_SHARE
  FROM CLUSTER_SHARED_MIX m
),

/* 16) Allocate total add count into class/type buckets, enforce minimum >= 1 */
ADD_PLAN AS (
  SELECT
    mix.CLUSTER_ID,
    mix.ASSET_TYPE,
    mix.ASSET_CLASS,
    mix.SHARED_HOURS_BY_CLASS,
    mix.MIX_SHARE,
    cat.TOTAL_ASSETS_TO_ADD_EST,
    GREATEST(CEIL(cat.TOTAL_ASSETS_TO_ADD_EST * mix.MIX_SHARE), 0) AS ASSETS_TO_ADD
  FROM CLUSTER_SHARED_MIX_WITH_SHARE mix
  JOIN CLUSTER_ADD_TOTAL cat
    ON cat.CLUSTER_ID = mix.CLUSTER_ID
  WHERE cat.TOTAL_ASSETS_TO_ADD_EST >= 1
),

ADD_PLAN_FILTERED AS (
  SELECT *
  FROM ADD_PLAN
  WHERE ASSETS_TO_ADD >= 1
)


SELECT
    cat.CLUSTER_ID,

    /* Cluster info */
    cat.TOTAL_USAGE,
    cat.SHARED_USAGE,
    cat.SHARED_RATIO,
    cat.SHARED_ASSETS,
    cat.GEOFENCES,

    /* Add logic */
    cat.TARGET_SHARED_REDUCTION_PCT AS TARGET_REDUCTION_PCT,
    cat.TARGET_REDUCTION_HOURS,
    cat.P75_HOURS_PER_SHARED_ASSET,
    cat.TOTAL_ASSETS_TO_ADD_EST AS ESTIMATED_ASSETS_TO_ADD,

    /* Estimated post-add shared usage */
    GREATEST(
        cat.SHARED_USAGE - cat.TARGET_REDUCTION_HOURS,
        0
    ) AS ESTIMATED_POST_ADD_SHARED_USAGE,

    /* Estimated new shared ratio */
    GREATEST(
        (cat.SHARED_USAGE - cat.TARGET_REDUCTION_HOURS)
        / NULLIF(cat.TOTAL_USAGE,0),
        0
    ) AS ESTIMATED_POST_ADD_SHARED_RATIO,

    /* % reduction in internal competition */
    cat.TARGET_SHARED_REDUCTION_PCT AS ESTIMATED_COMPETITION_REDUCTION_PCT

FROM CLUSTER_ADD_TOTAL cat
ORDER BY cat.SHARED_USAGE DESC
          ;;
  }



  dimension: cluster_id { type: number sql: ${TABLE}.CLUSTER_ID ;; }










}
