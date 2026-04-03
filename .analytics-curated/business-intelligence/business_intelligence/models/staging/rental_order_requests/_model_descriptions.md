{% docs rental_order_requests__rental_requests %}
This comes from `rental_order_requests.public.rental_requests`. 
This table represents all quotes submitted from the Rental website (https://www.equipmentshare.com/rent/).
We should be able to assume all details in here are captured in quotes - see this model's column descriptions for mapping to their 
coresponding fields in the `quote` database. 

The main thing for this model is to test that all `quote_id` created from the Rental site actually end up in the `quote` database,
to identify whether a quote was originally created via guest checkout `guest_user_request`, and to supplement the quotes model on 
identifying whether the quote originated from the Rental Website (specifically ones created prior to 2024-12-07).
{% enddocs %}

{% docs rental_order_requests__self_signup_accounts %}
This comes from `rental_order_requests.public.self_signup_accounts`. 
This indicates whether a user was created via self signup or invite.
{% enddocs %}