{% macro generate_monday_table_from_column_map(board_id) %}
    
    {% set type_map = {
        'text': {
            'column_name': 'text',
            'column_type': 'text',
        },
        'mirror': {
            'column_name': 'display_value',
            'column_type': 'text',
        },
        'status': {
            'column_name': 'text',
            'column_type': 'text',
        },
        'transaction_type': {
            'column_name': 'text',
            'column_type': 'text',
        },
        'date': {
            'column_name': 'date',
            'column_type': 'date',
        },
        'last_updated': {
            'column_name': 'value_json:updated_at',
            'column_type': 'timestamptz',
        },
        'numbers': {
            'column_name': 'number',
            'column_type': 'float',
        },
        'people': {
            'column_name': 'text',
            'column_type': 'text',
        },
        'link': {
            'column_name': 'value_json:url',
            'column_type': 'text',
        },
        'item_id': {
            'column_name': 'item_id',
            'column_type': 'text',
        },
        'checkbox': {
            'column_name': 'checked',
            'column_type': 'boolean',
        },
        'email': {
            'column_name': 'text',
            'column_type': 'text',
        },
        'long_text': {
            'column_name': 'text',
            'column_type': 'text',
        },
        'dropdown': {
            'column_name': 'text',
            'column_type': 'text',
        },
        'board_relation': {
            'column_name': 'display_value',
            'column_type': 'text',
        },
        'file': {
            'column_name': 'display_value',
            'column_type': 'text',
        },
        'name': {
            'column_name': 'item_name',
            'column_type': 'text',
        },
        'timerange': {
            'column_name': 'text',
            'column_type': 'text',
        },
        'subtasks': {
            'column_name': 'text',
            'column_type': 'text',
        }
    } -%}
    
    {% set column_query %}
        select 
            mbcm.column_id,
            mbcm.column_name,
            mbcm.column_type_override,
            mbcm.skip_etl_flag,
            c.type
        from {{ ref('seed_monday_board_column_map') }} as mbcm
         left join {{ ref('stg_analytics_monday__columns') }} as c
                   on mbcm.column_id = c.id
                    and mbcm.board_id = c.board_id
        where mbcm.board_id = '{{ board_id }}'
            and not mbcm.skip_etl_flag
            and mbcm.column_name != 'item_id'
    {% endset %}

    {% set column_list = run_query(column_query) %}
    
    with data as (
        select 
            *
        from {{ ref('int_monday_unpivoted_values') }}
        where board_id = '{{ board_id }}'
    ),
    out as (
        select
            d.board_id,
            d.item_id,
            d.group_id,
            d.group_title,
            d.item_name,  -- Ensure item_name is always selected
            {% for row in column_list %}
                max(
                    {% if row[0] == 'item_name' %}
                        d.item_name
                    {% elif row[4] is not none and row[4] in type_map %}
                        case when d.column_id = '{{ row[0] }}' then d.{{ type_map[row[4]]['column_name'] }} end
                    {% else %}
                        case when d.column_id = '{{ row[0] }}' then d.text /*problem column*/ end
                    {% endif %}
                ){% if row[2] is not none %}::{{ row[2] }}{% elif row[4] is not none and row[4] in type_map %}::{{ type_map[row[4]]['column_type'] }}{% endif %} as {{ row[1] }},
            {% endfor %}
        from data as d
        group by all
    )
    select * from out

{% endmacro %}
