{% docs confluent__operator_assignments %}
Raw Confluent topic containing operator assignment events from the operators API.
Each row is a Kafka message with a `record_metadata` envelope (Kafka protocol fields) and a `record_content` envelope (CloudEvents fields + event payload). Both columns are VARIANT.
{% enddocs %}

{% docs raw_confluent__operator_assignments %}
This model flattens `record_metadata` and `record_content` one level deep.
Scalar fields are cast to string, nested fields (OBJECT/ARRAY) are kept as VARIANT with a `_raw` suffix for further processing downstream.

Scalar fields are cast to string; nested fields (OBJECT/ARRAY) are kept as VARIANT with a `_raw` suffix and flattened in a downstream model:
- `record_metadata__*` — Kafka protocol fields (offset, partition, topic, key, CreateTime)
- `record_metadata__headers_raw` — Kafka message headers (Datadog tracing), kept as VARIANT
- `record_content__*` — CloudEvents envelope fields (id, source, type, time, specversion)
- `record_content__data_raw` — Event payload, kept as VARIANT
{% enddocs %}

{% docs raw_confluent__operator_assignments_parsed %}
This model further flattens the VARIANT columns from `raw_confluent__operator_assignments`.
Uses `flatten_nested_fields` to flatten all remaining VARIANT columns one level, and `flatten_field` to go one level deeper into `operator_assignment` specifically.

Handles: 
- Mixed-type `operator_assignment` for when it's a nested object and when it's a null field - rows where it is null return null for all `operator_assignment__*` columns; rows where it is a JSON object return the extracted field values.
- Deduplicates on `record_content__id`, keeping the latest delivery. This handles Kafka at-least-once redeliveries where the same event is appended to the source table multiple times with identical payload.

Produced columns follow the `<envelope>__<field>__<subfield>` naming convention:
- `record_metadata__headers__*` — Datadog tracing headers extracted from Kafka headers
- `record_content__data__*` — Event payload fields (t3_asset_id, operator_assignment)
- `record_content__data__operator_assignment__*` — Operator assignment fields
- `record_content__data__operator_assignment__attempted_overwrites_raw` — Array of prior assignment attempts, kept as VARIANT
{% enddocs %}
