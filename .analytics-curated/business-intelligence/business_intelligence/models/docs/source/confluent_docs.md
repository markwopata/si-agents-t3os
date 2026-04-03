{% docs confluent__record_metadata %}
Kafka record metadata containing information about the message offset, partition, timestamp, and other Kafka-specific attributes.
{% enddocs %}

{% docs confluent__record_content %}
The actual payload content of the Kafka message containing operator assignment data in JSON/variant format.
{% enddocs %}

{% docs confluent__record_metadata__headers_raw %}
Kafka message headers as VARIANT. Contains Datadog distributed tracing fields (traceparent,
tracestate, x-datadog-*). Flattened into `record_metadata__headers__*` columns in
`raw_confluent__operator_assignments_parsed`.
{% enddocs %}

{% docs confluent__record_content__data_raw %}
Full event payload as VARIANT. Contains the t3_asset_id and operator_assignment object.
Flattened into `record_content__data__*` columns in `raw_confluent__operator_assignments_parsed`.
{% enddocs %}

{% docs confluent__operator_assignment_source %}
Source system or mechanism that triggered the operator assignment (e.g., manual assignment, automated rule).
{% enddocs %}

{% docs confluent__attempted_overwrites_raw %}
Array of prior operator assignment attempts as VARIANT. Null when no overwrite was attempted,
empty array when attempted but unpopulated, or a populated array of prior assignment objects.
Use LATERAL FLATTEN with outer => true in a separate model for row-level analysis.
{% enddocs %}

{% docs confluent__datadog_traceparent %}
W3C traceparent header for distributed tracing. Encodes the trace ID, parent span ID, and trace flags.
{% enddocs %}

{% docs confluent__datadog_tracestate %}
W3C tracestate header for distributed tracing. Contains vendor-specific trace context.
{% enddocs %}

{% docs confluent__datadog_sampling_priority %}
Datadog sampling priority flag. Controls whether the trace is sampled and retained by Datadog.
{% enddocs %}

{% docs confluent__datadog_tags %}
Datadog trace tags propagated through Kafka message headers for trace correlation.
{% enddocs %}

{% docs confluent__kafka_offset %}
The Kafka message offset within the partition, indicating the position of this message in the Kafka log.
{% enddocs %}

{% docs confluent__kafka_partition %}
The Kafka partition number where this message was stored.
{% enddocs %}

{% docs confluent__kafka_create_time_epoch %}
The epoch timestamp in milliseconds when this message was created in Kafka.
{% enddocs %}

{% docs confluent__kafka_create_timestamp %}
The timestamp when this message was created in Kafka, converted from epoch milliseconds to timestamp.
{% enddocs %}

{% docs confluent__kafka_topic %}
The Kafka topic name where this message originated.
{% enddocs %}

{% docs confluent__kafka_key %}
The Kafka message key used for partitioning and message ordering.
{% enddocs %}

{% docs confluent__event_id %}
Unique CloudEvents identifier for this event message (UUID format).
{% enddocs %}

{% docs confluent__event_source %}
CloudEvents source field indicating the originating service or API endpoint.
{% enddocs %}

{% docs confluent__event_spec_version %}
CloudEvents specification version used for this event (typically "1.0").
{% enddocs %}

{% docs confluent__event_timestamp %}
CloudEvents timestamp when the event was generated at the source.
{% enddocs %}

{% docs confluent__event_type %}
CloudEvents type field describing the nature of the event (e.g., "operators-api.operators.created_operator_assignment").
{% enddocs %}

{% docs confluent__operator_id %}
Unique identifier for the operator from the operators API system.
{% enddocs %}

{% docs confluent__operator_name %}
Full name of the operator assigned to the equipment.
{% enddocs %}

{% docs confluent__t3_company_id %}
T3 system company identifier associated with the operator.
{% enddocs %}

{% docs confluent__t3_user_id %}
T3 system user identifier for the operator.
{% enddocs %}

{% docs confluent__t3_asset_id %}
T3 system asset identifier for the equipment being assigned to the operator.
{% enddocs %}

{% docs confluent__datadog_trace_id %}
Datadog distributed tracing trace ID for debugging and monitoring purposes.
{% enddocs %}

{% docs confluent__datadog_parent_id %}
Datadog distributed tracing parent span ID for debugging and monitoring purposes.
{% enddocs %}