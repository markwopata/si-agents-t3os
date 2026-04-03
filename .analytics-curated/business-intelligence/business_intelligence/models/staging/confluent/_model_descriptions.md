{% docs stg_confluent__operator_assignments %}
This model renames and type casts the flattened fields from `raw_confluent__operator_assignments_parsed` into clean business-readable names.
Kafka envelope fields are prefixed with `kafka_`, CloudEvents fields with `event_`, and Datadog tracing fields with `datadog_`.
{% enddocs %}