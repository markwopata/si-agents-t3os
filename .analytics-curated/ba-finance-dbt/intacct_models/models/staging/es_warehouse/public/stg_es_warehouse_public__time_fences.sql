SELECT
    tf.time_fence_id,
    tf.user_id,
    tf.start_time,
    tf.end_time,
    tf.monday,
    tf.tuesday,
    tf.wednesday,
    tf.thursday,
    tf.friday,
    tf.saturday,
    tf.sunday,
    tf.date_deactivated,
    tf.date_created,
    tf._es_update_timestamp
FROM {{ source('es_warehouse_public', 'time_fences') }} as tf
