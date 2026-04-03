SELECT
    t.task_id,
    t.task_list_id,
    t.date_deleted,
    t.display_name,
    t.priority,
    t.task_type_id,
    t.required,
    t.date_created,
    t.date_updated,
    t._es_update_timestamp
FROM {{ source('es_warehouse_public', 'tasks') }} as t
