select
    safety_observation_photo_key
    , safety_observation_key
    , photo

    , _created_recordtimestamp
    , _updated_recordtimestamp
    
from {{ ref('fact_safety_observation_photos') }}