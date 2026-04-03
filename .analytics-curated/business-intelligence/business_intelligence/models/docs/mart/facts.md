# Fact Tables Documentation

This file contains documentation for fact table columns in the marts layer.

<!-------------------- QUOTES -------------------->
{% docs quote_line_item_key %}
Surrogate key for unique quote and line item. This is generated in `fact_quote_line_items`.
{% enddocs %}

{% docs quote_escalation_key %}
Foreign key for a unique escalation for a quote.
{% enddocs %}

{% docs num_days_quoted %} 
This is a calculated field between the requested start date and requested end date of the quote, rounded up to the nearest day.
This should match what shows up in the Quote UI as well.
{% enddocs %}

{% docs quote_item_id %} 
Since a quote line item can be an equipment rental, accessory rental, or add on item, this field is the 
{% enddocs %}

{% docs quote_line_item_id %} 
A quote line item can be an equipment rental, accessory rental, or add on item. This serves as a unified identifier 
representing either an equipment type (`equipment_type_id`) or a sale line item (`sale_line_item_id`)`, depending on the source of the record. 
This allows the model to standardize references that do not share a common item structure.
{% enddocs %}

{% docs quote_line_item_description %} 
A quote line item can be an equipment rental, accessory rental, or add on item. This serves as a unified identifier 
representing either a rental equipment's class name (`equipment_class_name`), an accessory part name (`part_name`), 
or an add-on item name (`sale_item`)`, depending on the source of the record. 
This allows the model to standardize references that do not share a common item structure.
{% enddocs %}

{% docs quote_flat_rate %} 
This field only applies to the add-on items (non-rentals). For equipment or accessory rentals, this value is `null`.
{% enddocs %}

{% docs quote_num_days_to_escalation %}
Number of days it took between a quote creation and quote escalation.
{% enddocs %}

{% docs quote_escalation_has_attachment %}
Boolean for whether the escalation included an uploaded attachment.
{% enddocs %}

{% docs quote_contact_user_key %}
Surrogate key that ties to `dim_users`. 
Default key if user that requested the quote has not yet created an account.
{% enddocs %}

{% docs quote_line_item_note %}
Optional attached note for the line item.
{% enddocs %}

{% docs quote_line_item_quantity %}
Quantity of the line item.
{% enddocs %}

{% docs quote_line_item_day_rate %}
This is the day rate quoted for the item.
{% enddocs %}

{% docs quote_line_item_week_rate %}
This is the 1-week rate quoted for the item.
{% enddocs %}

{% docs quote_line_item_four_week_rate %}
This is the 4-week rate quoted for the item.
{% enddocs %}

{% docs quote_has_equipment_rentals %}
This is a helper dimension to indicate whether the quote contains any equipment rental line items (line_item_type_id = 8).
{% enddocs %}

{% docs quote_has_accessories %}
This is a helper dimension to indicate whether the quote contains any accessory line items (line_item_type_id = 44).
{% enddocs %}

{% docs quote_has_sale_items %}
This is a helper dimension to indicate whether the quote contains any sale items (not equipment rentals or accessories).
{% enddocs %}

<!-------------------- INVOICES -------------------->

{% docs invoice_num_primary_salesperson %}
Count of primary salespeople associated to an individual invoice.
{% enddocs %}

{% docs invoice_num_secondary_salesperson %}
Count of secondary salespeople associated to an individual invoice.
{% enddocs %}

{% docs invoice_total_num_salesperson %}
Sum of num_primary_salesperson and num_secondary_salesperson.
{% enddocs %}


<!-------------------- SAFETY OBSERVATION -------------------->
{% docs safety_observation_key %}
Surrogate key for a unique Jotform `safety_observation_id`.
{% enddocs %}

{% docs safety_observation_photo_key %}
Surrogate key for a unique safety_observation_id and uploaded photo url.
{% enddocs %}

{% docs safety_observation_submission_date_key %}
Surrogate key for the safety observation form submission date.
{% enddocs %}

{% docs safety_observation_submission_time_key %}
Surrogate key for the safety observation form submission time.
{% enddocs %}

{% docs safety_observation_observation_date_key %}
Surrogate key for the date the employee reported in the safety observation form.
{% enddocs %}

{% docs safety_observation_observation_time_key %}
Surrogate key for the time the employee reported in the safety observation form.
{% enddocs %}

{% docs safety_observation_observation_date_final_key %}
Surrogate key for the earlier date between the Jotform submission date and the reported observation date.
{% enddocs %}

{% docs safety_observation_observation_time_final_key %}
Surrogate key for the time associated with the earlier timestamp between the Jotform submission date and the reported observation date.
{% enddocs %}

{% docs safety_observation_employee_key %}
Surrogate key for the employee that filled the safety observation form.
{% enddocs %}

{% docs safety_observation_market_key %}
Surrogate key for the market / branch that the observation occurred.
{% enddocs %}

{% docs safety_observation_observation_description_summary %}
Summary produced by passing the free-text in `observation_description` into Snowflake's Cortex.
{% enddocs %}

{% docs safety_observation_has_uploaded_photos %}
Boolean for whether a safety observation form had photos uploaded with the form submission.
{% enddocs %}

{% docs safety_observation_requires_safety_manager_escalation %}
True if observation needs to be escalated to the safety manager. False if it does not. Can also be null.
{% enddocs %}

{% docs safety_observation_photo %}
URL or reference to the photo uploaded with the safety observation Jotform submission.
Defaults to a placeholder image if no photo is provided.
{% enddocs %}


<!-------------------- ASSET TRANSFERS -------------------->
{% docs asset_transfer_order_key %}
Surrogate key for the unique asset transfer order request.
{% enddocs %}

{% docs asset_transfer_order_asset_key %}
Surrogate key for asset tied to the transfer order request.
{% enddocs %}

{% docs asset_transfer_order_company_key %}
Surrogate key for company tied to the transfer order request.
{% enddocs %}

{% docs asset_transfer_order_from_market_key %}
Surrogate key for the market / branch that holds the asset in the transfer order request.
{% enddocs %}

{% docs asset_transfer_order_to_market_key %}
Surrogate key for the destination market / branch to which the asset is transferring.
{% enddocs %}

{% docs asset_transfer_is_active_transfer %} 
Boolean indicating whether the transfer is active or closed.
True if transfer order is in progress, false if request is closed.
An asset can only ever have one active transfer.
{% enddocs %}

{% docs asset_transfer_order_created_date_key %}
Surrogate key for the date the asset transer order was requested.
{% enddocs %}

{% docs asset_transfer_order_created_time_key %}
Surrogate key for the time the asset transer order was requested.
{% enddocs %}

{% docs asset_transfer_order_requester_user_key %}
Surrogate key for the user that made the asset transfer order request.
{% enddocs %}

{% docs asset_transfer_order_request_cancelled_date_key %}
Surrogate key for the date the asset transfer order request was cancelled.
{% enddocs %}

{% docs asset_transfer_order_request_cancelled_time_key %}
Surrogate key for the time the asset transfer order request was cancelled.
{% enddocs %}

{% docs asset_transfer_order_rejected_date_key %}
Surrogate key for the date the asset transfer order request was rejected.
{% enddocs %}

{% docs asset_transfer_order_rejected_time_key %}
Surrogate key for the time the asset transfer order request was rejected.
{% enddocs %}

{% docs asset_transfer_order_approved_date_key %}
Surrogate key for the date the asset transfer order request was approved.
{% enddocs %}

{% docs asset_transfer_order_approved_time_key %}
Surrogate key for the time the asset transfer order request was approved.
{% enddocs %}

{% docs asset_transfer_order_approver_user_key %}
Surrogate key for the user that approved the asset tranfer order.
{% enddocs %}

{% docs asset_transfer_order_transfer_cancelled_date_key %}
Surrogate key for the date the asset transfer order request was cancelled after it was already approved.
{% enddocs %}

{% docs asset_transfer_order_transfer_cancelled_time_key %}
Surrogate key for the time the asset transfer order request was cancelled after it was already approved.
{% enddocs %}

{% docs asset_transfer_order_received_date_key %}
Surrogate key for the date the asset was received at the destination branch.
{% enddocs %}

{% docs asset_transfer_order_received_time_key %}
Surrogate key for the time the asset was received at the destination branch.
{% enddocs %}

{% docs asset_transfer_order_receiver_user_key %}
Surrogate key for the user that received the asset at the destination branch.
{% enddocs %}

<!-------------------- TRACKERS -------------------->

{% docs tracker_vbus__valid_event_count %}
Count of non-null VBUS events that occur after the installation date for this tracker
{% enddocs %}

<!-------------------- CREDIT APP MODELS -------------------->

{% docs credit_application_company_key %}
Surrogate key for the company tied to the credit application.
{% enddocs %}

{% docs credit_application_created_by_employee_user_key %}
Surrogate key for the employee that created the credit application.
{% enddocs %}

{% docs credit_application_salesperson_user_key %}
Surrogate key for the salesperson associated with the credit application.
{% enddocs %}

{% docs credit_application_credit_specialist_user_key %}
Surrogate key for the credit specialist associated with the credit application.
{% enddocs %}

{% docs credit_application_created_date_key %}
Surrogate key for the date the credit application record was inserted into the database. 
This does not always have business context, unlike how `received_date` and `completed_date` do.
{% enddocs %}

{% docs credit_application_received_date_key %}
Surrogate key for the date the credit application was received.
{% enddocs %}

{% docs credit_application_completed_date_key %}
Surrogate key for the date the credit application was completed.
{% enddocs %}

<!-------------------- COMPANY START MODELS -------------------->

{% docs company_first_account_date_ct_key %}
Surrogate key for the earliest date the company was identified as a customer, either via their credit application history or by their first order. Date is already pre-converted to Central Time.
{% enddocs %}

{% docs company_first_account_source %}
Indicates whether the `company_customer_start_date_key` is derived from the first order or from the credit applications.
If it's derived from the first order, the field would be `Order`.

Otherwise, the field is a passthrough of the credit application:
* `Attention Needed`: Application is incomplete
* `Branch`: Assumes a rental branch filled out the application because a credit specialist hasn't touched it in 24-48h 
* `Credit Specialist`: Application is by a credit specialist
* `System`: Possibly from bulk insert at table creation
* `Web`: When a customer created their own account (self signed up) and a credit specialist didn't touch it later, 
    which should be only when the credit status is also COD (cash-on-delivery)
{% enddocs %}