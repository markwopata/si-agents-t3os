{% docs fact_asset_purchase_metrics %}
This model takes the `asset_purchase_history` table and summarizes the cost acquisition each asset over time
This gives summarized cost metrics of an asset - original price, latest price, highest price, lowest price.
{% enddocs %}

{% docs fact_invoice_salesperson_count %}
This contains the number os secondary salespeople tied to a specific invoice.
{% enddocs %}

{% docs fact_quotes %}
This contains measureable parts of quotes (total price, quantity), foreign keys to other dimension tables.
{% enddocs %}

{% docs fact_quote_line_items %}
This contains details of individual line items in a quote, with the selected rate.
{% enddocs %}

{% docs fact_quote_customer_conversion %}
This tracks brand new brand new prospective customers that came through the quote system and were converted into ES customers.
{% enddocs %}

{% docs fact_quote_escalations %}
This gives escalation details of quotes flagged for leadership attention.
{% enddocs %}

{% docs fact_safety_observation_details %}
Safety observation details for each Jotform safety observation submission.
{% enddocs %}

{% docs fact_safety_observation_photos %}
Expands each safety observation record into each individual photo uploaded in the safety observation submission, with a fallback image URL if no photos are present.
There can be multiple photos in a submission. 
This table only has submissions that have uploaded photos.
{% enddocs %}

{% docs fact_asset_transfers_accumulating_snapshot %}
This model tracks the entire lifecycle of an asset transfer from one market/branch to another.
{% enddocs %}

{% docs fact_credit_applications %}
This shows every company's latest credit application details based on the last update.
{% enddocs %}

{% docs fact_company_customer_start %}
This model materializes the earliest date the company became a customer either by the log in their credit application or by their first order.
The first and earliest salesperson that handles the company is given credit for "onboarding" the company.
{% enddocs %}

{% docs fact_company_nearest_market %}
This fact table records the nearest rental market and distance for each company based on the company's billing location.
It helps identify the closest operational market to serve each customer and supports market assignment decisions.
{% enddocs %}

{% docs fact_tracker_vbus_events %}
This does a validation on each VBUS event, ensuring the only VBUS values that remain occur after the tracker installation date.
Only trackers with at least one valid VBUS event are included.

VBUS is a communication protocol used to connect and control devices. The protocol enables the communication between different devices and manufacturers. VBUS allows devices to be connected in a network and to exchange data, such as measurement values, configuration parameters and status information.
List of VBUS events:
- average_fuel_economy
- battery_voltage
- coolant_level_percent
- coolant_temperature
- engine_rpm
- engine_active
- engine_oil_pressure
- engine_oil_temperature
- fuel_consumption_rate_gph
- fuel_economy_instantaneous_mpg
- fuel_level
- max_speed_mph
- odometer
- total_engine_hours
- total_fuel_used_liters
- total_idle_fuel_used_liters
- total_idle_hours
- vbus_speed
- vin
{% enddocs %}