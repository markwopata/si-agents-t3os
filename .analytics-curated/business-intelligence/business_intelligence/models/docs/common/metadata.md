# Metadata Columns Documentation

This file contains documentation for metadata columns used across all data layers (SCD2, historical tracking, CDC, etc.).

{% docs _valid_from %}
Used for a historical model to indicate when the current version of the record became valid.
{% enddocs %}

{% docs _valid_to %}
Used for a historical model to indicate when the record ends activity, either from being deleted or being closed out
when a new record is created.
{% enddocs %}

{% docs _is_current %}
Boolean flag on a historical model to mark the latest record.
{% enddocs %}

{% docs _last_instance_indicator %}
Boolean flag on tables with Change Data Capture enabled.
This field is meant for PIT tables.
{% enddocs %}

{% docs _effective_end_utc_datetime %}
Timestamp on tables with Change Data Capture when the record was invalidated by the presence of a change. 
This field is meant for PIT tables.
{% enddocs %}

{% docs _effective_start_utc_datetime %}
Timestamp from Data Ops' silver layer when the current version of the record became valid.
{% enddocs %}

{% docs _effective_delete_utc_datetime %}
Serves as a soft delete flag from the source database. If it's populated, the record has been deleted from the source.
{% enddocs %}

{% docs _es_update_timestamp %}
This is the timestamp when the record is loaded from the source into Snowflake.
{% enddocs %}

{% docs _created_recordtimestamp %}
Timestamp when the record was created in the dim/fact table.
{% enddocs %}

{% docs _updated_recordtimestamp %}
Timestamp when the record was updated in the dim/fact table.
{% enddocs %}

{% docs _dbt_updated_timestamp %} 
The timestamp when the record was processed and inserted/updated by a dbt run job.
{% enddocs %}

{% docs _fivetran_synced %}
Indicates the time when Fivetran last successfully extracted the row.
{% enddocs %}

{% docs _fivetran_start %}
When history mode is activated, this field is used to record the time that 
a record is ingested by Fivetran. This value may not be identical to the time 
the record was created in the source system.
{% enddocs %}

{% docs _fivetran_end %}
When history mode is activated, this field is used to record the time 
when a record became inactive in the source system.
{% enddocs %}

{% docs _fivetran_active %}
When history mode is activated, this field is used to identify an active record.
{% enddocs %}
