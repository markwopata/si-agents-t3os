{% docs rental_order_requests__user_registration_type %}
Registration types are:
* `SELF_SIGNUP`
* `INVITED`
{% enddocs %}

{% docs rental_order_requests__user_created_at %}
Timestamp when user is created as a ESDB user.
{% enddocs %}

{% docs rental_order_requests__account_id %}
Unique identifier for the combination of `user_id` and `company_id`.
{% enddocs %}

{% docs rental_order_requests__request_id %}
Unique id for a request made from the Rental website.
{% enddocs %}

{% docs rental_order_requests__shift_plan_name %}
Values are Single, Double, Triple. This duplicates `quotes.quotes.shift.name`.
{% enddocs %}

{% docs rental_order_requests__dropoff_fee %}
This maps to `quotes.quotes.quote.pickup_fee`.
{% enddocs %}

{% docs rental_order_requests__delivery_instructions %}
This maps to `quotes.quotes.order_note.content`.
{% enddocs %}

{% docs rental_order_requests__shift_plan_description %}
When `shift_plan_name` = 'Single', the value is 'Standard'. Not a useful descriptor.
{% enddocs %}

{% docs rental_order_requests__request_status %}
This appears to be a static value. Value is always 'IN_PROGRESS'.
{% enddocs %}

{% docs rental_order_requests__request_type %}
This appears to be a static value. Value is always 'ORDER'.
{% enddocs %}

{% docs rental_order_requests__receiver_contact_phone %}
This maps to `quotes.quotes.quote.site_contact_phone`.
{% enddocs %}

{% docs rental_order_requests__receiver_option %}
This doesn't seem to go directly into the Quotes database. 
Values are `SELF` and `OTHERS` - just indicates if the user is the one expected to receive the item or if they have a designated contact.
We may be able to derive this to some extent by comparing `quotes.quotes.quote.contact_name` = `quotes.quotes.quotes.site_contact_name`.
{% enddocs %}

{% docs rental_order_requests__branch_id %}
This maps to `quotes.quotes.quote.branch_id`.
{% enddocs %}

{% docs rental_order_requests__user_id %}
This is the ESDB user_id of whoever is logged in. If they choose guest checkout, this value is `NULL`.
This maps to `quotes.quotes.quote.contact_id`.
{% enddocs %}

{% docs rental_order_requests__equipment_charges %}
This should match `quotes.quote_pricing.equipment_charges` but doesn't always. 
The value in the Quotes database is probably more reliable.
{% enddocs %}

{% docs rental_order_requests__rental_subtotal %}
This should match `quotes.quote_pricing.rental_subtotal` but doesn't always. 
The value in the Quotes database is probably more reliable.
{% enddocs %}

{% docs rental_order_requests__guest_user_request %}
This indicates if the customer used the guest checkout feature on the Rental website.
If the value is true, there is no ESDB user_id associated with this request.
{% enddocs %}

{% docs rental_order_requests__delivery_fee %}
This is maps to `quotes.quotes.quote.delivery_fee`.
{% enddocs %}

{% docs rental_order_requests__jobsite_address_id %}
This specifically ties to `rentaol_order_request.public.addresses`.
This maps to multiple fields in `quotes.quotes.quote`, specifically the fields for the Location section in Customer in the quote.
{% enddocs %}

{% docs rental_order_requests__rpp_cost %}
This should match `quotes.quote_pricing.rpp` but doesn't always. 
The value in the Quotes database is probably more reliable.
{% enddocs %}

{% docs rental_order_requests__get_directions_link %}
This is some Google Map link, probably using a link to the longitude / latitude of their jobsite.
{% enddocs %}

{% docs rental_order_requests__shift_id %}
This maps to `quotes.quotes.shift.id`. 
{% enddocs %}

{% docs rental_order_requests__rental_protection_plan %}
This doesn't directly map to Quotes. Values are 'STANDARD' and 'SELF'. 
Probably safe to assume if `quotes.quote.quote_pricing.rpp` = 0, then it's `SELF`.
{% enddocs %}

{% docs rental_order_requests__dropoff_option %}
This doesn't directly map to Quotes. Values are `PAID` and `SELF`. 
Probably safe to assume if `quotes.quote.pickup_fee` = 0, then it's `SELF`.
{% enddocs %}

{% docs rental_order_requests__timezone %}
This is probably the timezone of the jobsite.
{% enddocs %}

{% docs rental_order_requests__taxes %}
Should map to `quotes.quote_pricing.sales_tax` and/or `quotes.quote_pricing.rpp_tax`.
{% enddocs %}

{% docs rental_order_requests__shift_plan_multiplier %}
This maps to `quotes.quotes.shift.multiplier`.
{% enddocs %}

{% docs rental_order_requests__order_total %}
This should match up with `quotes.quote_pricing.total` but not always. 
The value in the Quotes database is probably more reliable.
{% enddocs %}

{% docs rental_order_requests__receiver_contact_name %}
This maps to `quotes.quotes.quote.site_contact_name`.
{% enddocs %}

{% docs rental_order_requests__created_date %}
This maps to `quotes.quotes.quote.created_date`.
{% enddocs %}

{% docs rental_order_requests__delivery_option %}
This doesn't directly map to Quotes. Values are `PAID` and `SELF`. 
Probably safe to assume if `quotes.quote.delivery_fee` = 0, then it's `SELF`. 
{% enddocs %}

{% docs rental_order_requests__company_id %}
This maps to `quotes.quotes.quote.company_id`.
This is only populated if `user_id` is populated + if the user is logged in.
{% enddocs %}

{% docs rental_order_requests__user_uuid %}
This ties to `rental_order_request.public.users`, which is unique to the Rental site / `rental_order_request` database.
This captures users specifically using the Rental website, capturing both users that have an account or created a new account + users doing guest checkout.
{% enddocs %}

{% docs rental_order_requests__rpp_percentage %}
This maps to `quotes.quotes.quote.rpp_name`.
{% enddocs %}

{% docs rental_order_requests__po_name %}
This shouldn't technically be called `po_number`. This maps to `quotes.quotes.quote.po_name`. 
Note: Currently, the Rental website allows free text, which can be subject to user error.
{% enddocs %} 

{% docs rental_order_requests__quote_id %}
This maps to `quotes.quotes.quote.id`.
Starting 2024-12-07, all requests made in the Rental site is automatically mapped to a quote in the Quotes system.
{% enddocs %} 
