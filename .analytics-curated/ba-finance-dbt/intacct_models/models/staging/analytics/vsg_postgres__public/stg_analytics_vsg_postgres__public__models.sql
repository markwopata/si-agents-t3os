select
    m.id,
    m.created_at,
    m.name,
    m.hq_id,
    m.public_image_link,
    m.active,
    m.top_speed_mph,
    m.mile_range,
    m.drivetrain,
    m.zero_to_sixty_mph_seconds,
    m.seating_capacity,
    m.year,
    m.features,
    m._fivetran_deleted,
    m._fivetran_synced
from {{ source('analytics_vsg_postgres__public', 'models') }} as m
