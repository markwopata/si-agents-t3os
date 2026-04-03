{% docs int_quote_customer_conversion %}
This model identifies successful quote customer conversions by tracking prospects who requested quotes and later became actual customers with established company accounts.
{% enddocs %}

{% docs int_quote_customers %}
This model consolidates quote customer profiles, consolidating potentially new and existing customers. If the customer is an existing customer, company_id and quote_contact_user_id are populated. If the customer is a brand new customer that has not been converted, company_id and quote_contact_user_id are -1.
{% enddocs %}

{% docs int_quote_equipment_rentals %}
This model isolates the rental line items for a quote, including both rental equipment and non-rental equipment (accessories / small items). 
{% enddocs %}

{% docs int_quote_line_items %}
This model isolates the itemized breakdown of the quote, specifically around potential multiline items - rental equipment, accessories (small items), and sale / add-on services. Each line item would have the corresponding rate and quantity.
{% enddocs %}

{% docs int_quote_prices %}
This model combines prices at the quote level, such as subtotals, taxes, etc. It visually represents the prices that are seen in the ESMax application.
{% enddocs %}

{% docs int_quote_sale_items %}
This model isolates the add-on products / services in a given quote, with the price and quantity quoted. A quote can have multiple add-on products.
{% enddocs %}

{% docs int_quote_sources %}
This model consolidates the origins of the quote - the application source + whether the quote came from a guest. 
{% enddocs %}

{% docs int_quotes %}
This model contains various details that ultimately get split into the respective downstream facts and dimensions. It contains the logic for determining a quote's current status.
{% enddocs %}