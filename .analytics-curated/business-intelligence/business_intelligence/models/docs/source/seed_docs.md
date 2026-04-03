{% docs seed__from_company_id %}
The source company id that's being merged to another company id.
{% enddocs %}

{% docs seed__from_company_name %}
Reference of the source company name at the time of identification. 
There's a chance this goes out of sync, if it gets changed later.
{% enddocs %}

{% docs seed__to_company_id %}
The destination company id from merging company records.
{% enddocs %}

{% docs seed__to_company_name %}
Reference of the destination company name at the time of identification. 
There's a chance this goes out of sync from the value here, if it gets changed later.
{% enddocs %}

{% docs seed__company_is_current_vip %}
Indicator for whether a company id is an existing VIP company.
{% enddocs %}