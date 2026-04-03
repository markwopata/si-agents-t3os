{% docs credit_application_is_automated_entry %}
Record-level flag that identifies the first credit application record for each company that was automatically added or updated by the stored procedure. TRUE only for the first record (by date_created_ct) that has `notes = 'Automated record'` and `source IN ('Branch', 'System')`. All other records for the company are FALSE, even if they also match the pattern. This represents ongoing automated processing when credit specialists don't manually touch records.
{% enddocs %}

{% docs credit_application_is_batch_loaded_entry %}
Record-level flag that identifies the first credit application record for each company that was loaded during the initial table setup (one-time historical load). TRUE only for the first record (by date_created_ct) that has `notes = 'Batch added at table initialization'` and `source = 'System'`. All other records for the company are FALSE. This represents the one-time bulk data load when the credit application table was first initialized.
{% enddocs %}

{% docs credit_application_date_created_ct %}
Field converted to Chicago timezone to match the other date fields in the Retool form that already come in in Central Time.
This is kept in timezone instead of date for more flexibility; it's casted to date type downstream for specific needs.
{% enddocs %}

{% docs credit_application_salesperson_user_id %}
Light cleansing on the raw `sp_user_id` field:
* Converting 0 values into `null`
{% enddocs %}

{% docs credit_application_notes%}
Light cleansing on the raw `notes` field:
* Trimmed whitespace and null if empty
{% enddocs %}

{% docs credit_application_salesperson_name %}
Salesperson name parsed from the `salesperson` field (text before ' - ' delimiter). Trimmed and null if empty.
{% enddocs %}

{% docs credit_application_salesperson_employee_id %}
The employee ID of the salesperson associated with the credit application.
This should tie to the HR payroll system's employee_id in `analytics.payroll.company_directory`.
{% enddocs %}

{% docs credit_application_credit_specialist_name %}
Salesperson name parsed from the `credit_specialist` field (text before ' - ' delimiter). Trimmed and null if empty.
{% enddocs %}

{% docs credit_application_credit_specialist_employee_id %}
The employee ID of the credit specialist associated with the credit application.
This should tie to the HR payroll system's employee_id in `analytics.payroll.company_directory`.
{% enddocs %}

{% docs credit_application_type %}
This is specifically derived from the `app_status` field from credit applications, normalizing the raw application status into:
* `Credit` - if the `app_status` = 'Approved'
* `COD` - if the `app_status` has 'cod'
* null
{% enddocs %}

{% docs credit_application_created_by_employee_user_id %}
The mapped user_id for the employee who created the credit application record
{% enddocs %}

{% docs credit_application_is_locked %}
Helper flag to indicate the grace period window has closed for a company.
- **Automated intake**: Locks when grace period ends from first meaningful activity (credit app or order). Re-evaluates if first order changes.
- **Standard intake**: Locks when grace period ends from the company's first application with salesperson. Stays unlocked if no salesperson assigned (can be re-evaluated when salesperson is assigned).
When TRUE, attribution is locked. When FALSE, still within grace period or awaiting salesperson assignment.
{% enddocs %}

{% docs credit_application_first_account_date_ct %}
The earliest date the company was identified as a customer, either when the credit application was received (if applicable), when the credit application was inputted, or by the first order. Date is already pre-converted to Central Time.
{% enddocs %}