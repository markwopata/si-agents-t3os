{% docs safety_observation__id %}
Generated unique identifier for each safety observation response.
{% enddocs %}

{% docs safety_observation__submission_datetime %}
Jotform-generated timestamp of when the observation was submitted.
{% enddocs %}

{% docs safety_observation__first_name %}
First name of the employee who submitted the observation. Free-text field in form.
{% enddocs %}

{% docs safety_observation__last_name %}
Last name of the employee who submitted the observation. Free-text field.
{% enddocs %}

{% docs safety_observation__employee_email %}
Email address of the employee who submitted the observation. Free-text field.
{% enddocs %}

{% docs safety_observation__branch_location %}
Branch location associated with the observation. Drop-down field.
{% enddocs %}

{% docs safety_observation__region %}
Region associated with the observation. Drop-down field.
{% enddocs %}

{% docs safety_observation__observation_category %}
Category of the safety observation. Defaults to 'Unspecified' if missing. Drop-down field.
{% enddocs %}

{% docs safety_observation__observation_type %}
Type of the safety observation. Drop-down field.
{% enddocs %}

{% docs safety_observation__observation_date %}
Date the employee selected for when the observation occurred. Data comes in as a timestamp from the API.
{% enddocs %}

{% docs safety_observation__observation_time_12h %}
Time the employee selected for when the observation occurred.
Format is `HH12:MI AM` - ie. 03:03 AM or 03:03 PM
{% enddocs %}

{% docs safety_observation__observation_datetime %}
Combines observation_date and observation_time into the same field.
{% enddocs %}

{% docs safety_observation__observation_datetime_final %}
Chooses the earlier of the timestamp between the Jotform submission date and the reported observation date.
This enforces logic that a reported observation should occur before the form was filled out.
{% enddocs %}

{% docs safety_observation__observation_location %}
Location where the observation took place. Drop-down field.
{% enddocs %}

{% docs safety_observation__observation_description %}
"Description of the observation. Free-text field."
{% enddocs %}

{% docs safety_observation__photos %}
A list of links to photos related to the observation, hosted by Jotform. File upload field.
{% enddocs %}

{% docs safety_observation__corrective_action %}
Description of any corrective action taken. Options are:
* null
* `Yes`
* `No`
* `No corrective action needed (positive recognition)`
{% enddocs %}

{% docs safety_observation__corrective_action_type %}
Type or category of corrective action taken. Drop-down field.
{% enddocs %}

{% docs safety_observation__corrective_action_explanation %}
Explanation or details for the corrective action taken. Free-text field.
{% enddocs %}

{% docs safety_observation__safety_manager_elevation %}
Does observation need to be escalated to the safety manager? Yes/No field.
{% enddocs %}

{% docs safety_observation__jotform_form_id %}
Jotform form ID associated with the Safety Observation form. All records should have the same value - 241206353999060. Default field from Jotform API.
{% enddocs %}

{% docs safety_observation__jotform_submission_status %}
Submission status or state from Jotform. Can be `ACTIVE` or `OVERQUOTA`. Default field from Jotform API.
{% enddocs %}

{% docs safety_observation__jotform_submission_is_new %}
Per API docs, 1 if this submission is not read? But seeing values as 0,1,2. May need to ask Jotform. Default field from Jotform API.
{% enddocs %}

{% docs safety_observation__jotform_submission_is_flagged %}
Represents flagging a form submission. Default field from Jotform API.
{% enddocs %}

{% docs safety_observation__jotform_submission_updated_at %}
Last updated timestamp from the original submission. Updates should be disabled for this form.
{% enddocs %}

{% docs safety_observation__jotform_workflow_status %}
Only appears if the form is connected to a Jotform Workflow. Default field from Jotform API.
{% enddocs %}

{% docs safety_observation__jotform_is_workflow_enabled %}
Only appears if the form is connected to a Jotform Workflow. Default field from Jotform API.
{% enddocs %}