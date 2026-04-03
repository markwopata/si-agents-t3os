{% docs dim_assets_bi %}
This model is an enhancement to `platform.gold.dim_assets`. 
Additional attributes in this model that isn't originally in platform are owned by the BI team.
Additional fields in this model are:
* `asset_ownership`
{% enddocs %}

{% docs dim_companies_bi %}
This enhances the existing `dim_companies` model from Platform with the following fields:
* company_is_soft_deleted
* company_is_do_not_use
* company_is_duplicate
* company_is_employee
* company_is_es_internal
* company_is_misc
* company_is_prospect
* company_is_spam
* company_is_test
* company_merged_to_company_id
* company_is_new_account_at_risk
* company_is_new_account_at_risk_with_no_orders
* company_is_converted
* company_credit_status
* company_activity_status
* company_lifetime_rental_status
* company_is_sub_renter_only
* company_fleet_mimic_link
* company_analytics_mimic_link
The model is currently set to full refresh.
{% enddocs %}

{% docs dim_dates_bi %}
This enhances the existing `dim_dates` model from Platform with the following fields:
* dt_first_date_of_month
* dt_last_date_of_month
* dt_last_7_days
* dt_last_28_days
* dt_last_31_days
* dt_trailing_12_months
* dt_current_date
{% enddocs %}

{% docs dim_salesperson_enhanced %}
This isolates all users identified as having a salesperson title at one point in time with their 
historical employment status, title, and market assignment.
{% enddocs %}

{% docs dim_quote_customers %}
This is exclusive to quotes and consolidates details around customers specific to quotes. This captures customers that are 
existing customers, customers that may have sent in quotes without originally logging in, and prospective new customers.

If a customer checks out as a guest but are technically an existing customer, the rental coordinator 
would associate the quote with the existing account. If a customer checks out as a guest and are a new customer, the rental coordinator
would create an account for them that gets updated in both the quote and order system.
Conversion to order always means they have an account in ESDB.
{% enddocs %}

{% docs dim_quotes %}
This contains descriptive attributes of a specific quote.
{% enddocs %}

{% docs dim_equipment_classes %}
This gives details of a specific equipment class. It's specifically used for quotes because we quote on equipment class, 
not on individual assets. If an equipment class gets assigned to a different equipment category, it'll create a new record 
with a new equipment_class_key, so this would be a slowly changing dimension
{% enddocs %}

{% docs dim_employees %}
Dimensions for employees in the HR system.
{% enddocs %}

{% docs dim_users_bi %}
This enhances the existing `dim_users` model from Platform with the following fields:
* user_is_support_user
* user_employee_key
* user_is_employee
{% enddocs %}