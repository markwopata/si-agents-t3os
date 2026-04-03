{% docs int_user_mimic_links %}
This model generates mimic links for all users. If the user does not have a valid company_id, security_level_id, and email_address, the field would be `null`. 
The pre-hook creates a Javascript UDF urlencodestring for URL encoding to properly encode special characters in URLs.
`is_deleted` flag is added for reliable filtering downstream.

Logic was developed based on the code in [sales-login-generator](https://gitlab.internal.equipmentshare.com/business-intelligence/archive/sales-login-generator/-/blob/master/sales_login_generator/app.py) and cross checking with the [Mimic app](https://mimic.estrack.com/search).
{% enddocs %}

{% docs int_user_flags %}
This model consolidates logic in grouping users into certain categories / flags.
Flags included in this model:
* `is_support_user`
{% enddocs %}