{% macro create_seed_incremental(seed_ref, unique_id, update_cols=[]) %}

{#-- Dynamically fetch all column names from the seed table --#} 
{% set relation = ref(seed_ref) %}
{% set columns = adapter.get_columns_in_relation(relation) %}
{% set column_list = columns | map(attribute='name') | list %}

WITH new_records AS (
    SELECT
        {% for col in column_list %}seed.{{ col }}, {% endfor %}
        FALSE AS _is_deleted,
        {{ get_current_timestamp() }} AS _created_recordtimestamp,
        {{ get_current_timestamp() }} AS _updated_recordtimestamp,
        NULL AS _deleted_recordtimestamp
    FROM {{ ref(seed_ref) }} seed
    {% if is_incremental() %}
    WHERE seed.{{ unique_id }} NOT IN (SELECT cur.{{ unique_id }} FROM {{ this }} cur)
    {% endif %}
)

{% if is_incremental() %}
, updated_records AS (
    SELECT
        {% for col in column_list %}seed.{{ col }}, {% endfor %}
        FALSE AS _is_deleted,
        cur._created_recordtimestamp,
        {{ get_current_timestamp() }} AS _updated_recordtimestamp,
        NULL AS _deleted_recordtimestamp
    FROM {{ ref(seed_ref) }} seed
    JOIN {{ this }} cur
        ON cur.{{ unique_id }} = seed.{{ unique_id }}
    WHERE {% for col in update_cols %}seed.{{ col }} <> cur.{{ col }}{% if not loop.last %} OR {% endif %}{% endfor %}
),

deleted_records AS (
    SELECT
        {{ unique_id }},
        {% for col in update_cols %}{{ col }}, {% endfor %}
        TRUE AS _is_deleted,
        NULL AS _created_recordtimestamp,
        {{ get_current_timestamp() }} AS _updated_recordtimestamp,
        {{ get_current_timestamp() }} AS _deleted_recordtimestamp
    FROM {{ this }}
    WHERE {{ unique_id }} NOT IN (SELECT {{ unique_id }} FROM {{ ref(seed_ref) }})
      AND _is_deleted = FALSE
),

readded_records AS (
    SELECT
        seed.{{ unique_id }},
        {% for col in update_cols %}seed.{{ col }}, {% endfor %}
        FALSE AS _is_deleted,
        cur._created_recordtimestamp,
        {{ get_current_timestamp() }} AS _updated_recordtimestamp,
        NULL AS _deleted_recordtimestamp
    FROM {{ ref(seed_ref) }} seed
    JOIN {{ this }} cur
        ON cur.{{ unique_id }} = seed.{{ unique_id }}
    WHERE cur._is_deleted = TRUE
)
{% endif %}

SELECT * FROM new_records
{% if is_incremental() %}
UNION ALL
SELECT * FROM updated_records
UNION ALL
SELECT * FROM deleted_records
UNION ALL
SELECT * FROM readded_records
{% endif %}

{% endmacro %}
