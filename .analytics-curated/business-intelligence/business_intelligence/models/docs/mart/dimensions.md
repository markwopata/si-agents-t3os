# Dimension Tables Documentation

This file contains documentation for dimension table columns that only exist in the marts layer.

<!-------------------- EMPLOYEE / PAYROLL MODELS -------------------->

{% docs employee_key %}
Unique / surrogate key for a unique `employee_id` and `valid_from` when collapsing the 
snapshot tables into SCD2.
{% enddocs %}

{% docs salesperson_key %}
Similar to `employee_key`. Unique / surrogate key for a unique `employee_id` and `valid_from`,
but because salesperson-specific tables are at a different granularity than the overall employee tables,
the keys generated would be different. Giving it a distinct name hopefully denotes that difference.
{% enddocs %}

{% docs manager_employee_key %}
Unique / surrogate key for a unique `employee_id`.
{% enddocs %}

{% docs direct_manager_user_id %}
ESDB user id for the employee's manager.
{% enddocs %}

{% docs direct_manager_email_address %}
The employee's manager's email.
{% enddocs %}

<!-------------------- QUOTE MODELS -------------------->

{% docs quote_key %}
Foreign key for a unique quote id. This is generated in `dim_quotes`.
{% enddocs %}

{% docs quote_created_date_key %}
Foreign key for the create date of the quote. This is generated from `dim_dates`.
{% enddocs %}

{% docs quote_item_created_date_key %}
Foreign key for the create date of the quoted item. This is generated from `dim_dates`.
{% enddocs %}

{% docs quote_updated_date_key %}
Foreign key for the update date of the quote. This is generated from `dim_dates`.
{% enddocs %}

{% docs quote_created_by_user_key %}
Foreign key for the user that created the quote. This is generated from `dim_users`.
{% enddocs %}

{% docs converted_to_order_by_user_key %}
Foreign key for the user that converetd the quote to the order. This is generated from `dim_users`.
{% enddocs %}

{% docs quote_requested_start_date_key %}
Foreign key for the start date of the quoted period. This is generated from `dim_dates`.
{% enddocs %}

{% docs quote_requested_start_time_key %}
Foreign key for the start time of the quoted period. This is generated from `dim_times`.
{% enddocs %}

{% docs quote_requested_end_date_key %}
Foreign key for the end date of the quoted period. This is generated from `dim_dates`.
{% enddocs %}

{% docs quote_requested_end_time_key %}
Foreign key for the end time of the quoted period. This is generated from `dim_times`.
{% enddocs %}

{% docs quote_expiration_date_key %}
Foreign key for the expiration date of the quote. This is generated from `dim_dates`.
Quotes are default set to expire 30 days from the expected start date of the quote.
{% enddocs %}

{% docs quote_expiration_time_key %}
Foreign key for the expiration time of the quote. This is generated from `dim_times`.
Quotes are default set to expire 30 days from the expected start date of the quote.
{% enddocs %}

{% docs quote_status %}
This is the status of the quote. Statuses can be
- `Order Created` - when there's an order id associated with the quote
- `Missed Quote` - when someone goes in to manually mark a quote as missed with an associated reason
- `Expired` - when the quote is past the expiration date
- `Escalated` - when the quote is escalated
- `Open`
{% enddocs %}

{% docs quote_escalated_date_key %}
Foreign key for the escalated date of the quote. This is generated from `dim_dates`.
{% enddocs %}

{% docs quote_escalated_by_user_key %}
Foreign key for the ESDB user that escalated the quote. Usually one of the salespeople associated with the quote.
This is generated from `dim_users`.
{% enddocs %}

{% docs quote_customer_key %}
Surrogate key for quote source + quote customer id.
{% enddocs %}

{% docs quote_customer_is_archived %}
This indicates the customer is archived in the quote system.
This means if the customer submits a quote as a guest, and the quote became expired or missed / wasn't converted to an order,
the customer will be marked as archived.
{% enddocs %}

{% docs quote_company_key %}
Surrogate key that ties to `dim_companies`.
{% enddocs %}

{% docs quote_company_id %}
ESDB company id. 
-1 if it's a guest that has not been tied to a company or has not created an account.
{% enddocs %}

{% docs quote_company_name %}
If the customer is a guest, the value will be the company name entered manually into the quote.
If the customer is an existing customer, the value will be the company name from `dim_companies`.
{% enddocs %}

{% docs quote_customer_converted_date_key %}
Surrogate key for the date when the company appeared in ESDB after submitting a quote as a brand new customer.
{% enddocs %}

{% docs quote_customer_converted_time_key %}
Surrogate key for the time when the company appeared in ESDB after submitting a quote as a brand new customer.
{% enddocs %}

<!-------------------- EQUIPMENT CLASSES  -------------------->

{% docs equipment_class_key %}
Surrogate key for the unique equipment class, equipment category, and business segment.
{% enddocs %}

{% docs equipment_class_is_rentable %}
Boolean value for whether the equipment class is rentable.
{% enddocs %}

{% docs equipment_class_is_deleted %}
Boolean value for whether the equipment class has been deleted (and marked as soft deleted).
{% enddocs %}

{% docs equipment_category_is_active %}
Boolean value for whether the equipment category is active.
{% enddocs %}

{% docs equipment_class_category_id %}
The category id assigned to group the equipment class under (lowest level in the hierarchy).
{% enddocs %}

{% docs equipment_class_category_name %}
The category name used to group the equipment classes (lowest level in the hierarchy).
{% enddocs %}

{% docs equipment_class_parent_category_name %}
The parent of the category the equipment class is grouped under (one level above in the hierarchy), if applicable.
{% enddocs %}

{% docs equipment_class_grandparent_category_name %}
The top-level category the equipment class is grouped under, if applicable.
{% enddocs %}

{% docs equipment_class_category_description %}
Additional description of the category the equipment class is grouped under.
{% enddocs %}

{% docs equipment_class_business_segment_name %}
Business segments the equipment class can be grouped under. Possible values are:
* `Gen Rental`
* `Advanced Solutions`
* `ITL`
{% enddocs %}

<!-------------------- ORDER MODELS -------------------->
{% docs order_key %}
Surrogate key for a unique order id. This is generated in `dim_orders`.
{% enddocs %}

<!-------------------- DIM_DATES_BI -------------------->

{% docs dt_first_day_of_month %}
Indicator for first day of the calendar month.
{% enddocs %}

{% docs dt_last_day_of_month %}
Indicator for last day of the calendar month.
{% enddocs %}

<!-------------------- COMPANIES -------------------->

{% docs company_is_new_account %}
Boolean to indicate if a company is a new account. A neew account is defined as an account made in the last 45 days.
{% enddocs %}

{% docs company_has_orders %}
Boolean to indicate if a company has ever had an uncancelled order.
{% enddocs %}

{% docs company_is_vip %}
Indicator for VIP company.
{% enddocs %}

{% docs company_is_current_vip %}
Indicator for a VIP company that is currently still a VIP company.
{% enddocs %}

{% docs company_is_soft_deleted %}
Indicator for being soft deleted AKA having 'delete' in the company name.
{% enddocs %}

{% docs company_is_do_not_use %}
Indicator for a company marked as 'do not use' in the company name.
{% enddocs %}

{% docs company_is_duplicate %}
Indicator for a company marked with 'duplicate' in the company name that is not a system 'duplicate-merge-to-' pattern.
{% enddocs %}

{% docs company_is_employee %}
Indicator for a company with the name of an EquipmentShare employee / email address.
{% enddocs %}

{% docs company_is_es_internal %}
Identifier for a company manually flagged as an internal company.
{% enddocs %}

{% docs company_is_misc %}
Identifier for a company that's flagged but is not categorized.
{% enddocs %}

{% docs company_is_prospect %}
Identifier for a comopany that has 'Prospect' in their name. 
These are usually placeholders for companies to help expedite through the onboarding process so we can rent to them ASAP.
{% enddocs %}

{% docs company_is_spam %}
Identifier for a company that has been marked as spam. Currently, anything that looks spammy or from the domain 'qq.com'
{% enddocs %}

{% docs company_is_test %}
Identifier for a company that has 'demo' or 'test' in the company name or are a known company that's used for dev testing.
{% enddocs %}

{% docs company_merged_to_company_id %}
Mapping the company to a different company id based on:
* has 'duplicate-merge-to' pattern
* has some pattern of 'use [account_id]' in the naming pattern
{% enddocs %}

{% docs company_credit_status %}
Company credit status is derived from the net terms field. Valid values are:
* `Credit`
* `COD`
* `null`
{% enddocs %}

{% docs company_activity_status %}
Company's activity status:
* `Unconverted` - company has entered the system but has never had any revenue activity
* `Pending` - company has an active order that has not yet been invoiced
* `Inactive` - >= 90 days and < 120 since last invoice
* `Dormant` - >= 120 days since the last invoice
* `Active` - active customer
* `Not Applicable` - basically a catch-all unknown status
{% enddocs %}

{% docs company_is_sub_renter_only %}
True if the company has exclusively done business as a sub-renter.
{% enddocs %}

{% docs company_fleet_mimic_link %}
Mimic link URL for fleet application access. This link allows authorized users to seamlessly access the fleet platform (app.estrack.com) as the selected user without requiring separate authentication. The link is generated for the highest priority user from each company based on access level and support role. Mimic link is only available if there's a non-deleted user in the company. Otherwise, the default value is 'Not Applicable'.
{% enddocs %}

{% docs company_analytics_mimic_link %}
Mimic link URL for analytics application access. This link allows authorized users to seamlessly access the analytics platform (analytics.estrack.com) as the selected user without requiring separate authentication. The link is generated for the highest priority user from each companybased on access level and support role. Mimic link is only available if there's a non-deleted user in the company. Otherwise, the default value is 'Not Applicable'.
{% enddocs %}

<!-------------------- ASSETS MODELS -------------------->
{% docs asset_ownership %}
Derived field to classify ownership of each asset. Asset ownership is defined as:
* `ES` - EquipmentShare owned companies
* `RR` - ReRent = we were filling a need for an asset we don't have on hand and had to rent an asset from another company to rent to our customer;
    - Company 11606 is a holding company for Temporary Re-Rental
* `DELETED` - Company 155 is Jeff's 'junk yard', where retired/junk assets go when they die
* `DEMO` - Junk / test / demo companies
* `RETAIL` - retail locations;  
    - 'IES' is the company prefix for our dealership locations
    - 'VLP' is short for Victor L Phillips, the Case dealer we acquired in Kansas but had to keep the name
    - excludes company ids 31003, 66681, 82785 - they have 'IES' in their name but are valid companies that happen to have the same prefix
* `STOLEN` - Assets deemed as lost/stolen and assigned to those holding companies to organize the assets
* `EQUIPT` - This is an equipment rental company that we own in New Zealand. It is managed separately for the most part but on our platforms.
* `ES-DNR` - Special and/or temporary holding companies, such as DNR = Do Not Rent
* `OWN` - Asset is in the OWN program, which means the asset was purchased by a customer but we are allowed to rent them out
* `CUSTOMER`
{% enddocs %}

<!-------------------- DIM USERS  -------------------->

{% docs user_employee_key %}
Surrogate key linking to the dim_employees table. Uses a default key if no employee match is found.
{% enddocs %}

{% docs user_is_employee %}
Boolean indicator for whether the user is an employee.
{% enddocs %}

{% docs user_is_support_user %}
Boolean indicator for whether the user is a customer support representative. Determined by pattern matching on user's first and last names.
{% enddocs %}