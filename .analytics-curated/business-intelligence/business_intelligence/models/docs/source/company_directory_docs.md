{% docs employee_id %}
This is the an employee's Workday number.
{% enddocs %}

{% docs employee_first_name %}
An employee's first name.
{% enddocs %}

{% docs employee_last_name %}
An employee's last name.
{% enddocs %}

{% docs work_email %}
An employee's work email, usually ends with `@equipmentshare.com`.
{% enddocs %}

{% docs employee_type %}
Employee type should never be null after 2024-03-11. Employee types are:

- `Part Time Seasonal`
- `Part Time Employee`
- `Military Intern`
- `Full Time Employee`

Deprecated employee types are:
- `Part time Employee` (no longer used after 2023-12-05)
- `Full time Employee` (no longer used after 2024-05-13)
{% enddocs %}

{% docs employee_status %}
An employee's status should never be null. Valid employee statuses are:

- `Active`
- `Contractor`
- `External Payroll`
- `Intern (Fixed Term) (Trainee)`
- `Military Intern`
- `On Leave`
- `Seasonal (Fixed Term) (Seasonal)`
- `Temporary Worker`
- `Terminated`
- `Never Started`

Deprecated statuses are:
- `Not in Payroll` - no longer active since 2024-03-15
- `Not In Payroll` - no longer active since 2024-03-13
- `Inactive` - no longer active since 2024-01-16
{% enddocs %}

{% docs date_hired %}
Date an employee is hired in the payroll. This can be updated if an employee changes their start date.
These dates reflect general employment state — not role-level detail.
{% enddocs %}

{% docs date_rehired %}
Date an employee is rehired in the payroll. This can be updated if an employee changes their start date.
These dates reflect general employment state — not role-level detail.
{% enddocs %}

{% docs employee_title %}
Title the employee is given in the HR system.
{% enddocs %}

{% docs location %}
Location the employee is assigned.
{% enddocs %}

{% docs default_cost_centers_full_path %}
A cost center path is a hierarchical string or structure that represents how employee-related costs 
(like salary, benefits, bonuses) are allocated across the organization. It traces the chain of financial responsibility 
from the highest-level division (like company or region) down to the most specific department or team.
{% enddocs %}

{% docs direct_manager_employee_id %}
The employee's manager's Workday number.
{% enddocs %}

{% docs direct_manager_name %}
The employee's manager's name.
{% enddocs %}

{% docs work_phone %}
The employee's work phone number.
{% enddocs %}

{% docs date_terminated %}
Date an employee is terminated / no longer on the payroll.
If the employee is rehired, the date_terminated should be reset back to `NULL`.
These dates reflect general employment state — not role-level detail.
{% enddocs %}

{% docs nickname %}
The employee's nickname, if they opt to have one.
{% enddocs %}

{% docs personal_email %}
The employee's personal email.
{% enddocs %}

{% docs home_phone %}
The employee's personal phone number.
{% enddocs %}

{% docs greenhouse_application_id %}
The greenhouse application id tied to a job listing the employee was hired to.
{% enddocs %}

{% docs market_id %}
The market id an employee is assigned to.
{% enddocs %}

{% docs account_id %}
This is a specific Workday / UKG identifier.
{% enddocs %}

{% docs pay_calc %}
This classifies employees as 
- `Hourly`
- `Salary`

Other values in this field seem no longer relevant after 2024-03-18.
{% enddocs %}

{% docs ee_state %}
State in the US the employee is in.
{% enddocs %}

{% docs doc_uname %}
Username, which is usually an email. (Definition needs enhancement)
{% enddocs %}

{% docs tax_location %}
Taxable location the employee is in.
{% enddocs %}

{% docs labor_distribution_profile %}
If the employee is tied to a Rental location.
{% enddocs %}

{% docs position_effective_date %}
Effective date in the current title. 
This field seems be added starting 2024-03-20 but will stay `NULL` for historical employees.
{% enddocs %}

{% docs employee_is_on_leave %}
0 is False. 1 is True.
{% enddocs %}

{% docs worker_type %}
Worker_type should not be null since 2024-10-28. An employee's worker type classification can be
- `Employee`
- `Contingent Worker`
{% enddocs %}

{% docs last_updated_date %}
Last time the employee was updated in Workday.
{% enddocs %}

{% docs adjusted_path %}
This is the adjusted cost center path, adding an extra '/' if the first part of the string is 
a R[1-9] or RH.
{% enddocs %}

{% docs employee_email_current %}
This is the same as `work_email` but renamed to `employee_email`. 
{% enddocs %}

{% docs name_current %}
This comes from combining `first_name` or `nickname`, if available, and `last_name`.
When a `nickname` is available, this field would show `nickname` and `last_name`. 
{% enddocs %}

{% docs has_salesperson_title %}
This is a boolean value that flags any record that has an `employee_title` in the list of known salesperson titles, 
defined in the dbt_project.yml. 
{% enddocs %}

{% docs salesperson_jurisdiction %}
This field indicates the level the salesperson is responsible for in the hierarchy of 
region > district > market based on the derived fields `market_region`, `market_district`, `market_id`.

Possible values are:
- `Unassigned`
- `Region`
- `District`
- `Market`
{% enddocs %}

{% docs first_salesperson_date %}
This identifies the first date an employee held a salesperson title, which is derived from `analytics.payroll.company_directory_vault`.
If the employee was hired, rehired, or terminated before the snapshots began, we cannot assume thier starting title 
since we don't have a historical log, so these employees would be populated with `NULL`.
For those that have had historical logs, it would choose either the `date_hired` or `valid_from`, whichever is later, 
since the employee's start date may be after they are entered into the system.

`first_salesperson_date` reflects first known start date for a salesperson role — 
but if they are rehired into a new salesperson title (e.g. "General Manager"), that rehire resets the clock. 
Any earlier salesperson titles are not counted unless they continued into or beyond the rehire. 
{% enddocs %}

{% docs first_tam_date %}
The relevant Territorial Account Manager (TAM)-related titles are:
- `Territory Account Manager`
- `Strategic Account Manager`
- `Rental Territory Manager`

This field gives the first effective date the employee has held a TAM-related title, 
prioritizing rehires if applicable. 
This is because when a TAM is rehired, there are certain metrics that are part of their evaluation period,
such as their first 90 days. Even though they are a rehire, they would still be evaluated like a new TAM.
{% enddocs %}