# Companies Transformation Documentation

This file contains documentation for columns created in intermediate company transformations.

## Company Lifecycle & Conversion Tracking

{% docs is_new_account %}
Boolean flag identifying companies with first_account_date_ct within 45 days. Used to track recent customer acquisitions in business reporting.
{% enddocs %}

{% docs company_conversion_status %}
Derived field using business logic to classify companies as:
- 'Converted': Has placed orders or rentals
- 'Pending': New account still within conversion window 
- 'Not Converted': Has not placed orders beyond conversion window
{% enddocs %}

{% docs company_lifetime_rental_status %}
Company's lifetime rental history status:
* `Has Rented` - has at least one completed/returned rental; terminal status, never downgraded
* `Has Reservation` - has at least one active reservation but no completed rentals
* `Never Rented` - never had a successful rental
{% enddocs %}

## Company Classification Flags

{% docs flag %}
Derived classification field combining multiple company categorizations. Values include: 'deleted', 'do_not_use', 'duplicate', 'employee', 'es_internal', 'misc', 'prospect', 'spam', 'test'. Used for filtering and segmentation in reporting.
{% enddocs %}

## Credit Application Processing

{% docs is_government_entity %}
Boolean flag derived from credit application data indicating if the company is a government entity, affecting credit terms and processing workflow.
{% enddocs %}

{% docs has_insurance_info %}
Boolean flag indicating whether insurance information was provided in the credit application, used for risk assessment and approval workflow.
{% enddocs %}

{% docs coi_received %}
Boolean flag tracking whether Certificate of Insurance (COI) has been received, critical for rental approval and risk management.
{% enddocs %}

{% docs is_salesperson_override %}
Boolean flag indicating when salesperson assignment was manually overridden from system defaults, used for commission tracking and territory management.
{% enddocs %}