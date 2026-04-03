{% docs int_companies_seed_flagged %}
Combines all companies that were flagged manually.
{% enddocs %}

{% docs int_companies_seed_merged %}
Combines all companies identified with some sort of merge mapping.
{% enddocs %}

{% docs int_companies_duplicate_merged_to %}
Companies that were merged via 'Merge Duplicate Account' feature get their names updated to 
'duplicate-merged-to-[company_id]'. This maps the original company id to the new company_id indicated in the name.
{% enddocs %}

{% docs int_companies_merged %}
Combines all companies that have been:
* mapped to each other by email
* manually mapped to each other
* merged through the automated process
and recursively resolves merges into a final single target company.
{% enddocs %}

{% docs int_user_company_email_merge_mapping %}
Maps users' companies to companies by email domain.

- Type 1: exact match where `lower(user.email) = lower(company_name)` but company IDs differ in users vs companies.
- Type 2: domain match where a domain maps to exactly one `company_id` among users; join companies sharing that domain; IDs differ.
- Outputs distinct pairs (with names) and excludes `to_company_id` in the flagged list.
{% enddocs %}

{% docs int_credit_app_map_missing_salesperson_user_id %}
There is a `salesperson` and `salesperson_user_id` field in the Credit Application form.
Before Retool, it wasn't standardized that when one field was populated, the other was also populated. Post-Retool, this seems to be guaranteed.
This model is a small cleaning step on mapping applications before Retool where `salesperson_user_id` is null and populates it with a `user_id` that's in ESDB.
{% enddocs %}

{% docs int_credit_app_map_user_employee %}
Maps credit application users to the latest user-employee relationships from staging data.
This is necessary because while the data in the credit application is accurate at that point in time,
the user-employee relationship may have changed since.

Example scenario:
* On the credit app, salesperson_user_id = 28090 and salesperson_employee_id = 727, but this relationship doesn't exist in the bridge table
* This is because maybe the user got updated to remove the connection to that employee_id, and it got associated elsewhere
* The users table (at the time of this writing) tells us employee_id = 727 is tied to user_id = 13496 --> so this should be our source of truth

This model:
* References staging credit applications directly (includes all records, even deleted)
* Maps `created_by_email` to a user
* Maps the credit app salesperson to the current salesperson user_id and employee_id
* Maps the credit app credit specialist to their respective user_id and employee_id
{% enddocs %}

{% docs int_credit_app_base %}
The foundational credit application model that consolidates staging data with user mappings, filters deleted records, and adds computed business logic fields.

This model:
* Filters soft deletes (`WHERE is_deleted = false`)
* Handles hard deletes via post-hook (removes records marked as deleted after initial load)
* Brings in user/employee mappings from `int_credit_app_map_user_employee`
* Adds computed fields:
  - `app_type`: Categorizes as 'Credit' or 'COD' based on app_status
  - `is_automated_entry`: Flags automated records from Branch/System source
  - `is_batch_loaded_entry`: Flags batch-loaded entries at table initialization

This is the base model for all downstream credit application analysis.
{% enddocs %}

{% docs int_credit_app_lookup_valid_applications %}
Lookup table that filters out credit applications marked as 'Duplicate' or companies flagged as duplicates manually or by name.
Returns only `camr_id` and `company_id` - join to `int_credit_app_base` for detailed fields.
{% enddocs %}

{% docs int_credit_app_lookup_first_application %}
Lookup table identifying the first credit application per company based on `date_created_ct`.
Excludes credit applications requesting credit evaluation but have not set up a company in our system (no associated company_id).
Returns only `camr_id` and `company_id` - join to `int_credit_app_base` for detailed fields.
{% enddocs %}

{% docs int_credit_app_lookup_first_application_with_salesperson %}
Lookup table identifying the first credit application per company that has a salesperson assigned.
Returns only `camr_id` and `company_id` - join to `int_credit_app_base` for detailed fields.
{% enddocs %}

{% docs int_credit_app_lookup_grace_period %}
For **standard intake companies**, captures the credit application to use after a grace period.

**Grace Period Start Logic:**
- Prefers the first application WITH salesperson (from `int_credit_app_lookup_first_application_with_salesperson`)
- Falls back to the absolute first application if no salesperson ever assigned
- If a salesperson is assigned after the initial grace period closes, the model **re-evaluates** with a new grace period starting from that assignment date

**Grace Period Window:**
Credit specialists have a grace period from the determined start date to assign the correct salesperson.
The model takes the **absolute latest** credit application record within the grace period window. After the grace period expires, the credit application record selection is locked. However, if a company receives their first salesperson assignment, the model re-evaluates with a new grace period starting from that first assignment date.
This model does not guarantee there is a salesperson assignment.

Returns only `camr_id` and `company_id` - join to `int_credit_app_base` for detailed fields.

```mermaid
graph TB
    START[Standard Intake Company] --> SALESP{First app with<br/>salesperson exists?}
    SALESP -->|Yes| FIRST_SP[Use first app with salesperson<br/>as grace period start]
    SALESP -->|No| FIRST[Use first application<br/>as grace period start]
    FIRST_SP --> CHECK_REEVAL{Within grace period<br/>OR<br/>First salesperson assigned in credit apps?}
    FIRST --> CHECK_REEVAL
    CHECK_REEVAL -->|Yes| LATEST[Select latest record in grace period window]
    CHECK_REEVAL -->|No| SKIP[No additional processing]

    style START fill:#FFE6E6
    style SKIP fill:#A9A9A9
    style LATEST fill:#90EE90
```
{% enddocs %}

{% docs int_credit_app_automated_intake_activity %}
For **automated intake companies** (self-signup or automated entry records), creates an activity log of all credit applications and orders within a grace period of the first meaningful activity.
This model excludes the first credit application record of each company if it has no salesperson, but includes all other activity records.
This model does not guarantee there is a salesperson assignment.

**Logic:**
- Identifies companies where `is_initial_web_self_signup = true` OR `is_automated_entry = true`
- Excludes first record in credit application log if it has no salesperson (null or 'Pending Rep Assignment')
- Builds activity log: credit apps + first order (if exists)
- Filters to records within the grace period of first meaningful activity
- Tracks `is_locked` flag: when the grace period expires, the record would get `is_locked = true`

**Re-evaluation:** Only re-processes if:
1. New company
2. Still unlocked (`is_locked = false`) and new credit apps arrive
3. First order changes

```mermaid
graph TB
    START[Automated Intake Company<br/>Self-Signup or Automated Entry] --> REEVAL{Is this a<br/>new company<br/>OR is_locked=false<br/>OR has their order history changed?}
    REEVAL -->|No| SKIP[No additional processing]
    REEVAL -->|Yes| CHECK_SP{Does the first credit app <br/> in their log history <br/>have a salesperson?}
    CHECK_SP -->|No| EXCLUDE[Exclude first app from grace period window;<br/>Start the grace period window from next record]
    CHECK_SP -->|Yes| INCLUDE[Include first app for the grace period window]
    EXCLUDE --> FIRST_MEANINGFUL[Create the grace period window of credit application activity<br/>+ their first order, if it exists and is in the same timeframe]
    INCLUDE --> FIRST_MEANINGFUL
    FIRST_MEANINGFUL --> AUTOMATED_LOCK{Has grace period expired<br/>since first meaningful activity?}
    AUTOMATED_LOCK -->|Yes| LOCKED[Set is_locked=true]
    AUTOMATED_LOCK -->|No| UNLOCKED[Set is_locked=false]

    style START fill:#FFE6E6
    style SKIP fill:#A9A9A9
```
{% enddocs %}

{% docs int_credit_app_lookup_current_application %}
Lookup table identifying the latest (current) credit application per company that is not hard-deleted.
Excludes credit applications requesting credit evaluation but have not set up a company in our system (no associated company_id).
Returns only `camr_id` and `company_id` - join to `int_credit_app_base` for detailed fields.
{% enddocs %}

{% docs int_credit_app_first_intake_resolved %}
Combines standard and automated intake paths to resolve the final salesperson attribution for each company.
This model filters both paths to guarantee records with valid salesperson assignments.

**Note:** This diagram shows the complete intake resolution flow, including logic from upstream models
(`int_credit_app_lookup_grace_period` and `int_credit_app_automated_intake_activity`).

**Logic:**
- **Standard apps**: Use latest credit app within grace period window from first application (from `int_credit_app_lookup_grace_period`)
- **Automated intake apps**: Use activity log from `int_credit_app_automated_intake_activity`. Prioritize order salesperson if order exists; otherwise use latest credit app.
    - If it resolves to the order record, the expected fields are:
      - `camr_id`,`date_received_ct`, `date_completed_ct`: NULL
      - `date_created_ct`: order date (Chicago timezone)
      - `source`: `Order`
      - `app_status`: `COD` if `net_term_id=1`at the time of the order, `Approved` if `net_terms<>1`
      - `app_type`: `COD` if `net_term_id=1` at the time of the order, `Credit'` if `net_terms<>1`
      - `notes`: `First order with salesperson`
      - `salesperson_user_id`: primary salesperson user id from order
      - `first_account_date_ct`: order date in Central Time

```mermaid
graph TB
    START[Company Credit Application] --> TYPE{Is automated intake?<br/>self-signup or automated entry}

    %% Standard Intake Flow (from int_credit_app_lookup_grace_period)
    TYPE -->|No - Standard Intake| STD_SALESP{First app with<br/>salesperson exists?}
    STD_SALESP -->|Yes| STD_FIRST_SP[Use first app with salesperson<br/>as grace period start]
    STD_SALESP -->|No| STD_FIRST[Use first application<br/>as grace period start]
    STD_FIRST_SP --> STD_CHECK{Within grace period<br/>OR<br/>First salesperson assigned in credit apps?}
    STD_FIRST --> STD_CHECK
    STD_CHECK -->|Yes| STD_LATEST[Select latest record in grace period window]
    STD_CHECK -->|No| STD_SKIP[No additional processing]
    STD_LATEST -->|Filter: salesperson_user_id IS NOT NULL| FINAL

    %% Automated Intake Flow (from int_credit_app_automated_intake_activity)
    TYPE -->|Yes - Automated Intake| AUTO_REEVAL{New company<br/>OR is_locked=false<br/>OR order history changed?}
    AUTO_REEVAL -->|No| AUTO_SKIP[Skip - no additional processing]
    AUTO_REEVAL -->|Yes| AUTO_CHECK_SP{Does first credit app<br/>in log history<br/>have a salesperson?}
    AUTO_CHECK_SP -->|No| AUTO_EXCLUDE[Exclude first app from grace period window]
    AUTO_CHECK_SP -->|Yes| AUTO_INCLUDE[Include first app in grace period window]
    AUTO_EXCLUDE --> AUTO_WINDOW[Create grace period window:<br/>credit app activity + first order if exists]
    AUTO_INCLUDE --> AUTO_WINDOW
    AUTO_WINDOW --> AUTO_LOCK{Grace period expired<br/>since first meaningful activity?}
    AUTO_LOCK -->|Yes| AUTO_LOCKED[Set is_locked=true]
    AUTO_LOCK -->|No| AUTO_UNLOCKED[Set is_locked=false]
    AUTO_LOCKED --> AUTO_RESOLVE[Prioritize: Order > Latest Credit App]
    AUTO_UNLOCKED --> AUTO_RESOLVE
    AUTO_RESOLVE -->|Filter: salesperson_user_id IS NOT NULL| FINAL

    %% Re-trigger path
    AUTO_UNLOCKED -.->|New apps or<br/>order changes<br/>re-trigger| AUTO_REEVAL

    FINAL[First Intake Resolved<br/>Union of both paths with valid salesperson]

    style START fill:#FFE6E6
    style STD_SKIP fill:#A9A9A9
    style AUTO_SKIP fill:#A9A9A9
    style FINAL fill:#90EE90
```
{% enddocs %}

{% docs int_company_first_order %}
This model pulls the first order that was not cancelled or hard-deleted for a company.
{% enddocs %}

{% docs int_company_first_rental %}
This model pulls the first rental that was not cancelled or hard-deleted for a company.
{% enddocs %}

{% docs int_company_last_invoice %}
Identifies the most recent invoice for each company based on the latest billing cycle end date.
{% enddocs %}

{% docs int_company_first_order_with_salesperson %}
Identifies the first order per company where the order has a salesperson assigned, since orders do not always have to have a salesperson.
Uses post-hook for cleaning up orphaned records caused by assignment changes.
{% enddocs %}

{% docs int_company_first_rental_with_salesperson %}
Identifies the first rental per company where the rental has a salesperson assigned.
Rental activity is a better indicator of salespeople (TAM) involvement.
Uses post-hook for cleaning up orphaned records caused by assignment changes.
{% enddocs %}

{% docs int_company_open_quotes %}
Identifies companies that currently have open quotes.
{% enddocs %}

{% docs int_company_open_rentals %}
Identifies companies that currently have pending rentals (Draft, Pending) within the last 30 days or are currently On Rent.
{% enddocs %}

{% docs int_company_market_unconverted %}
Identifies unconverted companies and the markets / salespersons that may be able to help drive 
{% enddocs %}

{% docs int_company_conversion_flags %}
Determines conversion status for companies based on whether they have placed orders or rentals.
- 'Converted': Has orders or rentals
- 'Pending': New account (≤ 45 days) with no orders/rentals  
- 'Not Converted': Older account with no orders/rentals
{% enddocs %}

{% docs int_company_activity_status %}
Classifies companies by their activity level combining conversion status and recent business activity:
- 'Not Converted': Companies that have never converted (no orders/rentals)
- 'Pending': New account (≤ 45 days) with no orders/rentals or companies with pending business activity (via open quotes or rentals)
- 'Active': Companies with recent invoice activity (last invoice is within 90 days)
- 'Inactive': Companies with no recent business activity (90-119 days since last invoice)
- 'Dormant': Companies with no business activity for an extended period (≥120 days since last invoice)

```mermaid
graph TB
    COMPANY[Company] --> CONVERTED{Has Orders/Rentals?}

    CONVERTED -->|No| AGE{Age}
    AGE -->|≤45 days| PENDING[Pending]
    AGE -->|>45 days| NOT_CONV[Not Converted]

    CONVERTED -->|Yes| INVOICE{Last Invoice Billing Date}
    INVOICE -->|≤90 days| ACTIVE[Active]
    INVOICE -->|90-119 days| INACTIVE[Inactive]
    INVOICE -->|≥120 days| DORMANT[Dormant]

    style ACTIVE fill:#90EE90
    style PENDING fill:#FFD700
    style DORMANT fill:#FF6B6B
```

**Status:** Active (≤90 days), Inactive (90-119), Dormant (≥120), Pending (new or has open quotes/rentals), Not Converted (never ordered).

{% enddocs %}

{% docs int_company_lifetime_rental_status %}
Classifies each company by their lifetime rental history:
- 'Has Rented': Has at least one completed/returned rental (status_id in 5, 6, 7, 9) — terminal status, never downgraded
- 'Has Reservation': Has at least one active reservation (status_id in 1, 2, 3, 4) but no completed rentals
- 'Never Rented': No active non-cancelled rentals

The post-hook cleans up stale rows for companies with a recently-changed rental that now have zero active (non-cancelled, non-deleted) rentals (i.e. companies that would no longer appear in a full refresh).
{% enddocs %}

{% docs int_company_mimic_links %}
This model consolidates the mimic links at the user level into one mimic link per company.
Filtering out deleted users, the priority of user tied to the link:
1. Support users with company owner access (security_level_id = 2)
2. Support users without company owner access
3. Non-support users with company owner access (security_level_id = 2)
4. Random selection of any user with a mimic link
5. Users with no links at the bottom
{% enddocs %}
