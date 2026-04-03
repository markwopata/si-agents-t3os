select
    bs.business_segment_id,
    bs.name as business_segment_name,
    bs.date_created,
    bs.date_updated,
    bs._es_update_timestamp
from {{ source('es_warehouse_public', 'business_segments') }} as bs
