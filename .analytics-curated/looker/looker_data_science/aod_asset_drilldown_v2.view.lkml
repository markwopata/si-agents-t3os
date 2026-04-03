view: aod_asset_drilldown_v2 {
  # # You can specify the table name if it's different from the view name:
  derived_table: {
    sql:
    -- ########## cte_metrics_to_track ##########
 WITH cte_metrics_to_track
    (pgn,spn,description) AS (
      SELECT
        65262,
        110,
        'Engine Coolant Temperature (°F)'
      UNION
      SELECT
        65263,
        100,
        'Engine Oil Pressure (PSI)'
      UNION
      SELECT
        65262,
        175,
        'Engine Oil Temperature (°F)' ),
-- ########## cte_data_metrics ##########
    cte_data_metrics
      (asset_id,
      record_date,
      pgn,
      spn,
      description,
      probability,
      model_id,
      YEAR,
      make,
      model) AS (
      SELECT
        asset_info.asset_id,
        asset_info.record_date,
        track.pgn,
        asset_info.spn,
        track.description,
        asset_info.probability,
        asset_info.model_id,
        asset_info.YEAR,
        asset_info.make,
        asset_info.model
      FROM
        (
        SELECT
          dm.PK_ID_JSON:asset_id AS asset_id,
          TO_DATE(dm.END_TIMESTAMP) AS record_date,
          dm.META_DATA_JSON:spn AS spn,
          avg(dm.METRIC_VALUE) AS probability,
          assets.EQUIPMENT_MODEL_ID AS model_id,
          assets.YEAR,
          assets.make,
          assets.model
        FROM
          DATA_SCIENCE."PUBLIC".DATA_METRICS dm
        LEFT JOIN ES_WAREHOUSE."PUBLIC".ASSETS assets ON
          dm.PK_ID_JSON:asset_id = ASSETS.ASSET_ID
        WHERE
          TO_DATE(end_timestamp) BETWEEN (dateadd(DAY,
          -90,
          current_date())) AND (current_date())
          AND DATA_SOURCE LIKE 'aod_%'
          AND METRIC_NAME = 'probability'
        GROUP BY
          TO_DATE(END_TIMESTAMP),
          META_DATA_JSON:spn,
          PK_ID_JSON:asset_id,
          assets.EQUIPMENT_MODEL_ID,
          assets.YEAR,
          assets.make,
          assets.model) asset_info
      INNER JOIN cte_metrics_to_track track ON
        asset_info.spn = track.spn ),
-- ########## cte_data_metrics_assets ##########
  cte_data_metrics_assets
    (asset_id) AS (
    SELECT
      DISTINCT(asset_id)
    FROM
      cte_data_metrics ),
-- ########## cte_data_metrics_models ##########
  cte_data_metrics_models
    (model_id) AS (
      SELECT
        DISTINCT(MODEL_ID)
      FROM
        cte_data_metrics ),
-- ########## cte_days14 ##########
  cte_days14
    (date14,
    pgn,
    spn,
    description,
    asset_id) AS (
    SELECT
      *
    FROM
      (
      SELECT
        dateadd( DAY,
        '-' || ROW_NUMBER() OVER (
      ORDER BY
        NULL),
        current_date() ) AS date14
      FROM
        TABLE (generator(rowcount => 30)))
    LEFT JOIN cte_metrics_to_track
    LEFT JOIN cte_data_metrics_assets ON
      1 = 1 ),
-- ########## cte_days30 ##########
  cte_days30
    (date30,
    pgn,
    spn,
    description,
    asset_id) AS (
    SELECT
      *
    FROM
      (
      SELECT
        dateadd( DAY,
        '-' || ROW_NUMBER() OVER (
      ORDER BY
        NULL),
        current_date() ) AS date30
      FROM
        TABLE (generator(rowcount => 30)))
    LEFT JOIN cte_metrics_to_track
    LEFT JOIN cte_data_metrics_assets ON
      1 = 1 ),
-- ########## cte_days30_model ##########
  cte_days30_model
    (date30,
    pgn,
    spn,
    description,
    model_id) AS (
    SELECT
      *
    FROM
      (
      SELECT
        dateadd( DAY,
        '-' || ROW_NUMBER() OVER (
      ORDER BY
        NULL),
        current_date() ) AS date30
      FROM
        TABLE (generator(rowcount => 30)))
    LEFT JOIN cte_metrics_to_track
    LEFT JOIN cte_data_metrics_models ON
      1 = 1 ),
-- ########## cte_probabilities ##########
  cte_probabilities
    (asset_id,
    pgn,
    spn,
    description,
    GRAY_PROBABILITIES,
    RED_PROBABILITIES,
    YELLOW_PROBABILITIES ,
    GREEN_PROBABILITIES ) AS (
    SELECT
      d14.asset_id,
      d14.pgn,
      d14.spn,
      d14.description,
      listagg
      (CASE
        WHEN metrics.probability IS NULL THEN '100'
        ELSE 'null'
      END,
      ',') WITHIN GROUP (
        ORDER BY d14.date14 ASC) AS gray_probabilities,
      listagg
      (CASE
        WHEN metrics.probability >= 0.95 THEN '100'
        ELSE 'null'
      END,
      ',') WITHIN GROUP (
        ORDER BY d14.date14 ASC) AS red_probabilities,
      listagg
      (CASE
        WHEN metrics.probability < 0.95
        AND metrics.probability >= 0.85 THEN '100'
        ELSE 'null'
      END,
      ',') WITHIN GROUP (
        ORDER BY d14.date14 ASC) AS yellow_probabilities,
      listagg
      (CASE
        WHEN metrics.probability < 0.85 THEN '100'
        ELSE 'null'
      END,
      ',') WITHIN GROUP (
        ORDER BY d14.date14 ASC) AS green_probabilities
    FROM
      cte_days14 d14
    LEFT JOIN cte_data_metrics metrics ON
      d14.date14 = metrics.record_date
      AND d14.spn = metrics.spn
      AND d14.asset_id = metrics.asset_id
    GROUP BY
      d14.asset_id,
      d14.pgn,
      d14.spn,
      d14.description ),
-- ########## cte_j1939_all ##########
  cte_j1939_all
    (asset_id,
    report_date,
    REPORT_TIMESTAMP,
    spn,
    pgn,
    value) AS (
    SELECT
      asset_ID,
      to_date(report_timestamp) AS report_date,
      REPORT_TIMESTAMP,
      SPN,
      PGN,
      value
    FROM
      es_warehouse.public.j1939_data
    WHERE
      J1939_DATA_ID < 0
      AND spn IN (100, 110, 175)
      AND pgn IN (65262,65263)
      AND report_timestamp >= dateadd(DAY,
      -30,
      current_date())
      AND asset_id IN (
      SELECT
        asset_id
      FROM
        ES_WAREHOUSE."PUBLIC".ASSETS assets
      WHERE
        EQUIPMENT_MODEL_ID IN (
        SELECT
          model_id
        FROM
          cte_data_metrics_models)) ),
-- ########## cte_j1939 ##########
  cte_j1939
    (asset_id,
    report_date,
    report_timestamp,
    spn,
    pgn,
    value) AS (
    SELECT
      *
    FROM
      cte_j1939_all
    WHERE
      asset_id IN (
      SELECT
        asset_id
      FROM
        cte_DATA_METRICS_assets ) ) ,
-- ########## cte_current_value ##########
  cte_current_value
    (asset_id,
    data_as_of,
    spn,
    pgn,
    current_value,
    current_color) AS (
    SELECT
      cv.asset_id,
      cv.report_timestamp,
      cv.spn,
      cv.pgn,
      cv.current_value,
      ifnull(curr_color.current_color, 'gray')
    FROM
      (
      SELECT
        ASSET_id,
        REPORT_TIMESTAMP,
        SPN,
        PGN,
        CASE
          WHEN spn = 100 THEN round(value / 6.895)
          ELSE round(value * (9 / 5) + 32)
        END AS current_value
      FROM
        (
        SELECT
          ASSET_ID,
          REPORT_TIMESTAMP,
          SPN,
          PGN,
          VALUE ,
          RANK() OVER (PARTITION BY ASSET_ID,
          SPN,
          PGN
        ORDER BY
          REPORT_TIMESTAMP DESC) AS MY_RANK
        FROM
          cte_j1939)
      WHERE
        MY_RANK = 1) cv
    LEFT JOIN (
      SELECT
        asset_id,
        spn,
        CASE
          WHEN probability >= 0.95 THEN 'red'
          WHEN probability >= 0.85 THEN 'yellow'
          ELSE 'green'
        END AS current_color
      FROM
        (
        SELECT
          asset_id,
          spn,
          PROBABILITY ,
          RANK() OVER (PARTITION BY asset_id,
          spn
        ORDER BY
          record_date DESC) AS my_rank
        FROM
          cte_data_metrics)
      WHERE
        my_rank = 1 ) curr_color ON
      cv.asset_id = curr_color.asset_id
      AND cv.spn = curr_color.spn ) ,
-- ########## cte_header ##########
  cte_header
    (asset_id,
    year_make_model,
    data_as_of,
    model_id) AS (
    SELECT
      met.asset_id,
      concat(met.Year, ' ', met.Make, ' ', met.Model),
      max(cv.data_as_of),
      met.model_id
    FROM
      cte_data_metrics met
    LEFT JOIN cte_current_value cv ON
      met.asset_id = cv.asset_id
    GROUP BY
      met.asset_id,
      concat(met.Year, ' ', met.Make, ' ', met.Model),
      met.model_id ),
-- ########## cte_ref_values ##########
  cte_ref_values
    (model_id,
    spn,
    pgn,
    ref_values,max_ref_value,min_ref_value) AS (
    SELECT
      d30.model_id,
      d30.spn,
      d30.pgn,
      listagg(ifnull(to_varchar(
        CASE
          WHEN d30.spn = 100 THEN round(REF.median_value / 6.895)
          ELSE round(REF.median_value * (9 / 5) + 32)
          END ), 'null'),
        ',') WITHIN GROUP (
      ORDER BY d30.date30 ASC) AS ref_values,
      max(median_value) AS max_ref_value,
      min(median_value) AS min_ref_value
    FROM
      cte_days30_model d30
    LEFT JOIN (
      SELECT
        j1939.report_date AS ref_date,
        j1939.spn,
        j1939.pgn,
        assets.EQUIPMENT_MODEL_ID ,
        round(median(value)) AS median_value
      FROM
        cte_j1939_all j1939
      LEFT JOIN ES_WAREHOUSE."PUBLIC".ASSETS assets ON
        j1939.asset_id = assets.asset_id
      GROUP BY
        j1939.report_date,
        j1939.spn,
        j1939.pgn,
        assets.EQUIPMENT_MODEL_ID) REF ON
      d30.date30 = REF.ref_date
      AND d30.spn = REF.spn
      AND d30.pgn = REF.pgn
      AND d30.model_id = REF.equipment_model_id
    GROUP BY
      d30.model_id,
      d30.spn,
      d30.pgn ),
-- ########## cte_asset_values ##########
  cte_asset_values
    (asset_id,
    pgn,
    spn,
    description,
    asset_values,max_asset_value,min_asset_value) AS (
    SELECT
      d30.asset_id,
      d30.pgn,
      d30.spn,
      d30.description,
      listagg( ifnull(to_varchar(
        CASE
          WHEN d30.spn = 100 THEN round(j1939.median_value / 6.895)
          ELSE round(j1939.median_value * (9 / 5) + 32)
          END ), 'null'),
        ',') WITHIN GROUP (
      ORDER BY d30.date30 ASC) AS asset_values,
      max(median_value) AS max_asset_value,
      min(median_value) AS min_asset_value
    FROM
      cte_days30 d30
    LEFT JOIN (
      SELECT
        asset_id,
        report_date,
        spn,
        pgn,
        round(median(value)) AS median_value
      FROM
        cte_j1939
      GROUP BY
        asset_id,
        report_date,
        spn,
        pgn ) j1939 ON
      d30.date30 = j1939.report_date
      AND d30.asset_id = j1939.asset_id
      AND d30.pgn = j1939.PGN
      AND d30.spn = j1939.spn
    GROUP BY
      d30.asset_id,
      d30.pgn,
      d30.spn,
      d30.description )
-- ########## begin main query ##########
SELECT
  *
FROM (
  SELECT
    head.asset_id,
    head.year_make_model,
    to_varchar(convert_timezone('America/Chicago',head.data_as_of), 'MM/DD/YYYY HH12:MI AM')  AS data_as_of,
    prob.description,
    cv.spn,
    cv.pgn,
    cv.current_value,
    cv.current_color,
    REPLACE(prob.GRAY_PROBABILITIES,'null') AS GRAY_PROBABILITIES,
    REPLACE(prob.red_PROBABILITIES,'null') AS red_PROBABILITIES,
    REPLACE(prob.yellow_PROBABILITIES,'null') AS yellow_PROBABILITIES,
    REPLACE(prob.green_PROBABILITIES,'null') AS green_PROBABILITIES,
    rv.ref_values,
    av.asset_values,
    CASE
      WHEN cv.spn = 100 THEN round(greatest(rv.max_ref_value,av.max_asset_value,-9999) / 6.895)
      ELSE round(greatest(rv.max_ref_value,av.max_asset_value,-9999) * (9 / 5) + 32)
    END AS max_median,
    CASE
      WHEN cv.spn = 100 THEN round(least(rv.min_ref_value,av.min_asset_value,9999) / 6.895)
      ELSE round(least(rv.min_ref_value,av.min_asset_value,9999) * (9 / 5) + 32)
    END AS min_median
  FROM
    cte_header head
  LEFT JOIN cte_current_value cv ON
    head.asset_id = cv.asset_id
  LEFT JOIN cte_probabilities prob ON
    head.asset_id = prob.asset_id
    AND cv.spn = prob.spn
    AND cv.pgn = prob.pgn
  LEFT JOIN cte_ref_values rv ON
    head.model_id = rv.model_id
    AND cv.spn = rv.spn
    AND cv.pgn = rv.pgn
  LEFT JOIN cte_asset_values av ON
    head.asset_id = av.asset_id
    AND cv.spn = av.spn
    AND cv.pgn = av.pgn)
--WHERE
  --asset_id = 24550
  --ORDER BY asset_id, spn
    ;;}



  dimension: asset_id {}
  dimension: description {}
  dimension: year_make_model {}
  dimension: data_as_of {}
  dimension: current_value {}
  dimension: current_color {}
  dimension: gray_probabilities {}
  dimension: red_probabilities  {}
  dimension: yellow_probabilities  {}
  dimension: green_probabilities  {}
  dimension: ref_values  {}
  dimension: asset_values  {}
  dimension: max_median   {}
  dimension: min_median  {}


  dimension: header {
    sql: '1' ;;
    html: <H1>{{year_make_model}}</H1><br><h3>Data as of {{data_as_of}}</h3>  ;;
  }

  dimension: header_single_line {
    sql: '1' ;;
    html: <H1>{{year_make_model}} — Data as of {{data_as_of}}</h1>  ;;
  }


  dimension: drilldown_top {
    sql: '1';;
    html:   <div height=250 text-align: center>{{description}}<div height=200><div style="width: 80px;
          height: 80px;
          line-height: 80px;
          border-radius: 50%;
          font-size: 20px;
          color: #000000;
          text-align: center;
          background: {{current_color}}"  ><b>{{current_value}}</b></div></div>
          <div height=10 width=150>&nbsp</div>
          <img height="30" width="150" src="https://quickchart.io/chart?chs=150x30&cht=bvs&chd=a:{{gray_probabilities._value}}|{{red_probabilities._value}}|{{yellow_probabilities._value}}|{{green_probabilities._value}}&chco=aaaaaa,aa2222,aaaa22,22aa22"></div>
          ;;

    }

  dimension: engine_data_last_30_days{
    sql: '1';;
    #html: <img src="https://quickchart.io/chart?chs=400x50&cht=ls&chd=a:{{median_list._value}}|{{ref_median_list._value}}&chco=882222,22228877&chxt=y&chxr=0,{{lower_bound._value}},{{upper_bound._value}}">;;
    html: <h3>{{description}}</h3><img height="200" width="1000" src="https://quickchart.io/chart?w=1000&h=200&c={type:%27line%27,options:{scales:{yAxes:[{ticks:{min:{{min_median._value}},max:{{max_median._value}},maxTicksLimit:2},gridLines:{display:false}}],xAxes:[{gridLines:{display:false}}]},plugins:{legend:false}},data:{labels:[%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27],datasets:[{data:[{{asset_values._value}}],fill:false,backgroundColor:%27%2388222277%27,borderColor:%27%2388222277%27},{data:[{{ref_values._value}}],fill:false,backgroundColor:%27%2322228877%27,borderColor:%27%2322228877%27}]}}">;;
  }







}
