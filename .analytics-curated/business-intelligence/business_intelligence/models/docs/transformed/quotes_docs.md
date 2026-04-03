# Quotes Transformation Documentation

This file contains documentation for columns created in intermediate quote transformations.

## Quote Status & Lifecycle Tracking

{% docs quote_sales_tax %}
Total sales tax of the quote, excluding sales tax associated with the rental protection plan.
{% enddocs %}

{% docs quote_rental_protection_plan_price %}
Total price of the rental protection plan, including sales tax associated with the plan.
{% enddocs %}

## Quote Source Tracking

{% docs is_guest_request %}
Boolean flag derived from rental request guest_user_request indicator. Identifies quotes initiated by non-registered users, used for lead source analysis and conversion tracking.
{% enddocs %}

## Customer Conversion Logic

{% docs converted_timestamp %}
Complex temporal business logic field identifying the precise moment when quote customers converted to established company accounts. Uses multi-step analysis matching quote customer updates to company creation timing for accurate conversion attribution.
{% enddocs %}