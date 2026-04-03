# Bridge Tables Documentation

This file contains documentation for bridge table columns in the marts layer.

{% docs invoice_salesperson_key %} 
Surrogate key for invoice id + salesperson user id.
{% enddocs %}

{% docs order_salesperson_key %} 
Surrogate key for order id + salesperson user id.
{% enddocs %}

{% docs quote_salesperson_key %} 
Surrogate key for quote id + salesperson user id.
{% enddocs %}

{% docs salesperson_user_key %} 
An ESDB user that is marked as a salesperson for the respective business process. 
This specifically ties to `platform.gold.dim_users`.
{% enddocs %}

{% docs salesperson_type %} 
This identifies whether the salesperson in the business process is marked as `Primary` or `Secondary`.
{% enddocs %}

{% docs order_salesperson_id %}
Natural key for a unique order id + salesperson user id. 
This is a passthrough value from the source, `es_warehouse.public.order_salespersons`.
{% enddocs %}

{% docs order_salesperson_updated_at %}
The timestamp when the order was updated with salesperson(s).
This is essentially a passthrough value from the source, `es_warehouse.public.order_salespersons`.
{% enddocs %}