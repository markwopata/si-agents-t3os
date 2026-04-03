select
    -- kafka envelope
    TRY_TO_NUMBER(record_metadata__offset)                                                                      as kafka_offset,
    TRY_TO_NUMBER(record_metadata__partition)                                                                   as kafka_partition,
    TRY_TO_NUMBER(record_metadata__CreateTime)                                                                  as kafka_create_time_epoch,
    TO_TIMESTAMP(TRY_TO_NUMBER(record_metadata__CreateTime) / 1000)                                            as kafka_create_timestamp,
    record_metadata__topic                                                                                      as kafka_topic,
    record_metadata__key                                                                                        as kafka_key,

    -- datadog tracing headers
    record_metadata__headers__traceparent                                                                       as datadog_traceparent,
    record_metadata__headers__tracestate                                                                        as datadog_tracestate,
    record_metadata__headers__x_datadog_trace_id                                                               as datadog_trace_id,
    record_metadata__headers__x_datadog_parent_id                                                              as datadog_parent_id,
    record_metadata__headers__x_datadog_sampling_priority                                                      as datadog_sampling_priority,
    record_metadata__headers__x_datadog_tags                                                                   as datadog_tags,

    -- cloudevents
    record_content__id                                                                                          as event_id,
    record_content__source                                                                                      as event_source,
    record_content__specversion                                                                                 as event_spec_version,
    TRY_TO_TIMESTAMP(record_content__time)                                                                      as event_timestamp,
    SPLIT_PART(record_content__type, '.', -1)                                                                   as event_type,

    -- event payload
    TRY_TO_NUMBER(record_content__data__t3_asset_id)                                                           as t3_asset_id,

    -- operator assignment
    record_content__data__operator_assignment__operator_id                                                      as operator_id,
    INITCAP(REGEXP_REPLACE(TRIM(record_content__data__operator_assignment__operator_name), '\\s+', ' '))        as operator_name,
    record_content__data__operator_assignment__source                                                           as operator_assignment_source,
    TRY_TO_NUMBER(record_content__data__operator_assignment__t3_company_id)                                     as t3_company_id,
    TRY_TO_NUMBER(record_content__data__operator_assignment__t3_user_id)                                        as t3_user_id,
    record_content__data__operator_assignment__attempted_overwrites_raw                                         as attempted_overwrites_raw,
    coalesce(
        array_size(record_content__data__operator_assignment__attempted_overwrites_raw) > 0,
        false
    )                                                                                                           as has_attempted_overwrites,

    _updated_recordtimestamp

from {{ ref('raw_confluent__operator_assignments_parsed') }}
