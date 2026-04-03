{% docs pk_generic %}
Primary key for this table.
{% enddocs %}

{% docs _es_update_timestamp %}
Date/time this row was loaded to Snowflake.
{% enddocs %}

{% docs date_created %}
Datetime this row was created in system.
{% enddocs %}

{% docs date_updated %}
Datetime this row was updated in system.
{% enddocs %}

{% docs company_id %}
Unique id for company or customer. Foreign key to company_id in es_warehouse companies table
{% enddocs %}

{% docs created_by_username %}
Created by user, login id or username.
{% enddocs %}

{% docs updated_by_username %}
Updated by user, login id or username.
{% enddocs %}

{% docs created_by_name %}
Created by user, full name.
{% enddocs %}

{% docs updated_by_name %}
Updated by user, full name.
{% enddocs %}

{% docs market_id %}
Numeric id for a market. Sometimes called branch_id
{% enddocs %}

{% docs market_name %}
Market's name in es_warehouse
{% enddocs %}

{% docs employee_id %}
Unique employee identifier in UKG
{% enddocs %}

{% docs url_t3_general %}
Link to T3. Could be a link to work order or purchase order
{% enddocs %}

{% docs url_t3_work_order %}
Link to T3 work order
{% enddocs %}

{% docs url_t3_purchase_order %}
Link to T3 CostCapture purchase order
{% enddocs %}

{% docs url_admin_general %}
Link to admin. Could be a link to invoice or rental
{% enddocs %}

{% docs url_admin_rental %}
Link to admin rental
{% enddocs %}

{% docs url_admin_invoice %}
Link to admin invoice
{% enddocs %}

{% docs url_concur %}
Sworks slow-link to the invoice pdf hosted in Concur
{% enddocs %}

{% docs work_order_id %}
Foreign key to es_warehouse work orders table.
{% enddocs %}

{% docs asset_code %}
Refers to a single asset within the Asset4000 system and includes both main mover and child assets. A main mover is a standalone asset whose acquisition can be traced to an invoice, lease buyout, or trade-in agreement. A child asset is dependent on a main mover and typically represents modifications or additions that wouldn’t exist independently.
{% enddocs %}

{% docs gl_account_number %}
are account numbers used to categorize types of financial transactions
{% enddocs %}

{% docs admin_asset_id %}
asset id in Admin
{% enddocs %}

{% docs oec %}
the cost we purchased the asset at
{% enddocs %}

{% docs nbv %}
net book value. it represents the value of an asset on a company's balance sheet after accounting for depreciation and amortization
{% enddocs %}

{% docs first_rental_date %}
when an asset was first rented
{% enddocs %}

{% docs orderly_liquidation_value %}
The estimated monetary value of an asset in a liquidation sale, where the seller, under time and location constraints, is given a reasonable amount of time to find one or more buyers.
{% enddocs %}

{% docs buyout_price %}
The price ES pays to purchase an asset from the banks, either by buying out a lease or buying the asset out of a lease
{% enddocs %}

{% docs asset_account %}
The GL account storing the asset on the balance sheet{% enddocs %}

{% docs accumulated_depreciation_account %}
The account that tracks how much has been depreciated from the asset
{% enddocs %}

{% docs depreciation_expense_account %}
the account where depreciation or amortization is recorded
{% enddocs %}

{% docs asset_gl_assignment_date %}
 the date the asset was tied to a particular GL account
 {% enddocs %}

{% docs sage_transaction_number %}
the journal transaction number entered in Sage
{% enddocs %}

{% docs year_to_date_depreciation_expense %}
the total accumulated depreciation expense recorded for an asset from the beginning of the current fiscal year up to the present date
{% enddocs %}

{% docs asset_disposal_date %}
the date the asset was disposed (for AS4K reporting)
{% enddocs %}

{% docs asset_disposal_reason %}
the reason the asset was disposed (for AS4K reporting). Most disposals are due to sales invoices when an asset is sold.
{% enddocs %}

{% docs period_depreciation_expense %}
the depreciation expense allocated to the asset for the given period
{% enddocs %}

{% docs asset_disposal_period %}
The accounting period in which the asset disposal occurred. This field is used to track the timing of asset disposals for reporting and analysis purposes.
{% enddocs %}

{% docs asset_disposal_user_created_by %}
The fixed assets accounting user who recorded the disposal
{% enddocs %}

{% docs asset_disposal_year %}
The year in which the asset was disposed of
{% enddocs %}

{% docs _fivetran_deleted %}
Indicates whether the record has been deleted by Fivetran's sync process. A value of true means the record was deleted in the source system and marked as such during ETL.
{% enddocs %}

{% docs disposal_timestamp %}
the timestamp indicating when the asset disposal occurred
{% enddocs %}

{% docs _fivetran_synced %}
the timestamp indicating when the record was last synchronized by Fivetran.
{% enddocs %}

{% docs rental_id %}
rental id in Admin
{% enddocs %}

{% docs drop_off_delivery_id %}
id for equipment drop offs
{% enddocs %}

{% docs return_delivery_id %}
id for equipment returns
{% enddocs %}

{% docs rental_start_date %}
The date on which the rental begins.
{% enddocs %}

{% docs rental_end_date %}
The date on which the rental ends.
{% enddocs %}

{% docs asset_next_rental_start_date %}
The asset’s next known rental start date
{% enddocs %}

{% docs rental_duration %}
Duration of the rental (in minutes)
{% enddocs %}

{% docs equipment_class_id %}
id for the equipment class. This is derived from the equipment model (i.e., one model ties to a class)
{% enddocs %}

{% docs admin_order_id %}
id for the order in the orders table. Each rental will tie to an order and multiple rentals can be placed on one order
{% enddocs %}

{% docs asset_4000_depreciation_date %}
the accounting date when depreciation is posted (month-end for AS4K)
{% enddocs %}


{% docs bt_branch_id %}
id for Materials stores from BisTrack - different than ES Market Ids
{% enddocs %}


#### ------------- Retail Sales ---------------------------

{% docs retail_sales_payment_method %}
How the customer is paying for the Asset (e.g., cash, finance).
{% enddocs %}
