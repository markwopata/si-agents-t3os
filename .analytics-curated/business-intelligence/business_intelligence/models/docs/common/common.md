{% docs is_null %}
This field seems to always be null.
{% enddocs %}

{% docs user_is_deleted %}
Soft delete flag for when the user is deleted from ESDB.
{% enddocs %}

{% docs es_user_id %}
This is EquipmentShare's user id.
{% enddocs %}

{% docs es_email %}
User's email address from ESDB.
{% enddocs %}

{% docs es_company_id %}
This is Equipment Share's company identifier.
{% enddocs %}

{% docs es_company_name %}
This is the name of a company.
{% enddocs %}

{% docs purchase_order_id %}
This is the purchase order id. A customer can have multiple purchase orders.
{% enddocs %}

{% docs purchase_order_name %}
This is the name of the purchase order. A customer can have multiple purchase orders.
{% enddocs %}

{% docs rental_protection_plan_id %}
This is the unique identifier for a rental protection 
This should match the ids in the rental_protection_plans table.
{% enddocs %}

{% docs rental_protection_plan_name %}
This is the name for the rental protection plan.
This should match the names in the rental_protection_plans table.
{% enddocs %}

{% docs company_division_id %}
Division-level identifier used for grouping companies within the organization.
{% enddocs %}

{% docs company_division_name %}
Company divisions are:
* `Gen Rents`
* `P&P`
* `ITL`
{% enddocs %}