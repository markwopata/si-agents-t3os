{% docs int_company_directory_history %}
This model converts the periodic snapshots on `analytics.payroll.company_directory_vault`
into a SCD2 model across all fields that exist, capturing all changes that have 
occurred in `analytics.payroll.company_directory` over time.
{% enddocs %}

{% docs ep_company_directory_history__parse_cost_center_path %}
This model is a helper model does the heavy lifting to parse through a list of unique cost center paths
based on known patterns. It
1) tries to standardize the `DEFAULT_COST_CENTERS_FULL_PATH`, at least for anything that has a R[1-9] or RH, 
since those seem to indicate rental markets
2) parses through the `DEFAULT_COST_CENTERS_FULL_PATH` to isolate the various levels that exist 
in the organizatonal hierarchy based on the cost center paths

Ultimately, for a given cost center path, it returns additional fields:
- `division_name`
- `region`
- `region_name`
- `district`
{% enddocs %}

{% docs int_company_directory_history__split_cost_center_path %}
This model ultimately adds market-level details to the company directory tracking changes, `int_company_directory_history`.

It combines `int_company_directory_history` with `ep_company_directory_history__parse_cost_center_path`
as well as `dim_markets` to add the following fields:
- `market_name`
- `market_division_name`
- `market_region`
- `market_region_name`
- `market_district`

This is helpful because an employee may be assigned to a specific level within the organizational hierarchy.
For example, an employee assigned to be a regional-level employee may not assigned a specific market but instead 
a market region.
{% enddocs %}

{% docs int_company_directory_history__salesperson %}
This model isolates employees that have ever had a salesperson title in their history with the company from 
 `int_company_directory_history`. Valid salesperson titles come from a predefined list of known titles. 
{% enddocs %}

{% docs int_salesperson__title_market_history %}
For salespeople, we only care about a subset of fields that change, specifically if their employment status, 
employment title, and the market they're assigned to. This model further collapses the salesperson table, 
`int_company_directory_history__salesperson` to track changes for the fields that are relevant, reducing noise 
from HR changes that may not be relevant for sales-related analyses.
{% enddocs %}

{% docs int_salesperson__hybrid %}
This model is a hybrid structure made up of some fields from the historical salesperson table 
with select fields tracked (`int_salesperson__title_market_history`) and some fields 
from the latest record (`analytics.payroll.company_directory`). The fields that are historical 
are appended with (`_hist`) while the fields that are kept up-to-date are appended with (`_current`).

This is also where `first_salesperson_date` and `first_TAM_date` is being calculated. It recalculates 
these two dates using the entire history of that employee.
{% enddocs %}

{% docs int_salesperson__hybrid__first_dates %}
This is where `first_salesperson_date` and `first_TAM_date` is calculated. It recalculates the two fields 
for any employee that was updated in the latest incremental run.
{% enddocs %}