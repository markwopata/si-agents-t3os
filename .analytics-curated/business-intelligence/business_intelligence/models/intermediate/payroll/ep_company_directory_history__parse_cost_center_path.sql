{{ config(
    materialized='ephemeral'
) }}

-- this query parses through the '/' delimited field in DEFAULT_COST_CENTERS_FULL_PATH and looks for anything region or district related.

WITH distinct_paths AS (
    -- One known pattern is 'Rental/R7 Industrial/3-3/Dallas, TX' and 'R7 Industrial/3-3/Dallas, TX', 
        -- so adding an extra '/' delimiter to the latter to match the former's format to simplify the parsing logic
    SELECT DISTINCT default_cost_centers_full_path, 
            IFF(REGEXP_LIKE(LEFT(split_part(default_cost_centers_full_path, '/', 1), 2), 'R([1-9]|H)+'), -- match R1-R9 or RH
            '/' || default_cost_centers_full_path,
            default_cost_centers_full_path) as adjusted_path
    FROM {{ ref('int_company_directory_history') }} 

    WHERE default_cost_centers_full_path IS NOT NULL
),

    -- handle the ones that follow the expected format - uses less processing power
    quick_parse AS (
        SELECT
            adjusted_path,
            CASE
                WHEN SPLIT_PART(adjusted_path, '/', 1) in (select division_name from {{ ref("stg_market_data__division_types") }})
                    THEN SPLIT_PART(adjusted_path, '/', 1)
                ELSE NULL
            END AS division_name,
            -- isolate the number that's after the R - usually it's in the second or fourth delimited segment
            CASE
                WHEN REGEXP_LIKE(SPLIT_PART(adjusted_path, '/', 2), 'R[1-9].*')
                    THEN TRY_CAST(REGEXP_SUBSTR(SPLIT_PART(adjusted_path, '/', 2), 'R([1-9])', 1, 1, 'e', 1) AS INT)
                WHEN REGEXP_LIKE(SPLIT_PART(adjusted_path, '/', 4), 'R[1-9].*')
                    THEN TRY_CAST(REGEXP_SUBSTR(SPLIT_PART(adjusted_path, '/', 4), 'R([1-9])', 1, 1, 'e', 1) AS INT)
                ELSE NULL
            END AS region,
            -- only if the segment has R1-9, get the value after R1-9 if exists
            CASE
                WHEN REGEXP_LIKE(SPLIT_PART(adjusted_path, '/', 2), 'R[1-9].*')
                    THEN TRIM(REGEXP_SUBSTR(SPLIT_PART(adjusted_path, '/', 2), 'R[1-9][ -]([A-Za-z ]+)', 1, 1, 'e', 1))
                WHEN REGEXP_LIKE(SPLIT_PART(adjusted_path, '/', 4), 'R[1-9].*')
                    THEN TRIM(REGEXP_SUBSTR(SPLIT_PART(adjusted_path, '/', 4), 'R[1-9][ -]([A-Za-z ]+)', 1, 1, 'e', 1))
                ELSE NULL
            END AS region_name,
            -- extract value if it looks like number-number - usually it's in the third delimited segment
            CASE
                WHEN REGEXP_LIKE(SPLIT_PART(adjusted_path, '/', 3), '.*[0-9]+-[0-9]+.*')
                    THEN REGEXP_SUBSTR(SPLIT_PART(adjusted_path, '/', 3), '.*([0-9]+-[0-9]+).*', 1, 1, 'e', 1)
                ELSE NULL
            END AS district
        FROM distinct_paths
    ),

    additional_parsing as (
        SELECT
            adjusted_path
        FROM quick_parse
        WHERE (region IS NULL AND district IS NULL)
        AND (division_name in ('Rental') or division_name IS NULL)
    ),

    -- only look at paths that were not parsed that have the patterns we want but couldn't find in segment 2,3,4
    segments AS (
        SELECT
            adjusted_path,
            s.value::string AS segment,
            s.index + 1 AS segment_position  -- make it 1-based index
        FROM additional_parsing,
        LATERAL FLATTEN(input => SPLIT(adjusted_path, '/')) AS s
    ),

    classified AS (
        SELECT *,
            REGEXP_LIKE(segment, 'R[1-9].*') AS is_region,
            REGEXP_LIKE(segment, '.*[0-9]+-[0-9]+.*') AS is_district
        FROM segments
    ),

    -- only get positions for anything with district pattern or region pattern
    position_lookup AS (
        SELECT
            adjusted_path,
            MAX(CASE WHEN is_region THEN segment_position END) AS region_segment_position,
            MAX(CASE WHEN is_district THEN segment_position END) AS district_segment_position
        FROM classified
        GROUP BY adjusted_path
        HAVING region_segment_position is not null or district_segment_position is not null
    ),

    --  just look at the first segment for division
    division_extracted as (
        SELECT adjusted_path,
            CASE
                WHEN SPLIT_PART(adjusted_path, '/', 1) in (select division_name from {{ ref("stg_market_data__division_types") }})
                    THEN SPLIT_PART(adjusted_path, '/', 1)
                ELSE NULL
            END AS division_name
        FROM classified c
    ),

    -- isolate the region from the corresponding delimited segment
    -- region number is the number after 'R'
    region_extracted AS (
        SELECT
            c.adjusted_path,
            c.segment AS region_segment_value, 
            TRY_CAST(REGEXP_SUBSTR(c.segment, 'R([1-9])', 1, 1, 'e', 1) AS INT) AS region,
            CASE
                WHEN REGEXP_SUBSTR(c.segment, 'R[1-9]+') IS NOT NULL THEN
                    TRIM(REGEXP_SUBSTR(c.segment, 'R[1-9][ -]([A-Za-z ]+)$', 1, 1, 'e', 1))
                ELSE NULL
            END AS region_name -- only populate region name if the region pattern is detected
        FROM classified c
        JOIN position_lookup p
            ON c.segment_position = p.region_segment_position
    ),

    -- isolate the district from the corresponding delimited segment
    district_extracted AS (
        SELECT
            c.adjusted_path,
            c.segment AS district_segment_value,
            COALESCE(REGEXP_SUBSTR(c.segment, '.*([0-9]+-[0-9]+).*', 1, 1, 'e', 1), NULL) AS district
        FROM classified c
        JOIN position_lookup p
            ON c.segment_position = p.district_segment_position
    ),

    combined as (

        SELECT *
        from quick_parse
        WHERE region IS NOT NULL
            OR district IS NOT NULL
            OR (division_name NOT IN ('Rental') AND division_name IS NOT NULL)

        UNION ALL

        SELECT distinct
            p.adjusted_path,
            div.division_name,
            r.region,
            r.region_name,
            d.district
        FROM additional_parsing p
        LEFT JOIN division_extracted div on p.adjusted_path = div.adjusted_path
        LEFT JOIN region_extracted r ON p.adjusted_path = r.adjusted_path
        LEFT JOIN district_extracted d ON p.adjusted_path = d.adjusted_path
    )

    select 
        c.adjusted_path,
        c.division_name,
        c.region,
        coalesce(r.name, c.region_name) as region_name,
        c.district
    from combined c
    left join {{ ref('platform', 'es_warehouse__public__regions') }} r
    on c.region = r.region_id