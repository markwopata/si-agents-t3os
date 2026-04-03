{% docs quotes__customer %}
Customers can either represent a user from a company or a guest / not-logged-in user. 
Most of the fields that are stored here are duplications of data from ES companies and can be deemed as redundant.
{% enddocs %}

{% docs quotes__audit_event_type %}
Quotes can be updated and is tracked through a list of defined event types.
The available audit event types that can be recorded are stored in this table.
{% enddocs %}

{% docs quotes__audit_history %}
This contains an audit history of all the actions performed on each quote. 
This allows us to capture the full lifecycle of a quote to order
{% enddocs %}

{% docs quotes__equipment_types %}
This contains the rates for both rental equipment and bulk parts that will 
be created in an order. These are the line items listed under 'Equipment' 
(EQUIPMENT_CLASS_ID is populated) and 'Bulk equipment' (PART_ID is populated) in a quote. 
This contains both the quoted rate type and rate that would transfer to the order 
but also the list of available rate types and quoted rates that could have been selected 
at that point in time.f

Floor rate is not selectable nor visible in the quote, but it is used as a reference for 
when a custom rate is entered las lower than the floor rate or when it's a deal rate on 
the UI side of the Quotes application.
{% enddocs %}

{% docs quotes__escalations %}
Escalations can only happen on quotes when the quote in the 'open' status. 
This allows a quote to be flagged for quicker attention from sales leadership, with 
a description or supporting documents (ie. competitor's pricing, etc). Once escalated, 
an email is sent to sales leadership with the salesperson copied on the email; the sales 
leadership and salesperson are to exchange about their decided outcome and adjust the quote
as necessary.
Details: 
* https://updates.equipmentshare.com/release/c3sEr-internal-streamline-quote-escalation-process-in-esmax
* https://www.notion.so/equipmentshare/Order-and-Quote-Escalations-in-ESMax-1273ad4a462280c1bb0edf09d5d2b07f
{% enddocs %}

{% docs quotes__quote %}
This contains core information about a quote.
{% enddocs %}

{% docs quotes__quote_pricing %}
When a quote is generated, the system will automatically store all pricing 
information fields: Rent Subtotal, Sale Items SubTotal, RPP, Equipment Charges, 
Delivery Fee, Pickup Fee, Sales Tax, and Total. The purpose of this table is to allow
district sales managers or a general manager of a branch to assess total revenue opportunity 
and line item revenue as well as see price quotes vs actual order billed.
{% enddocs %}

{% docs quotes__rate_type %}
Rates in a quote are determined by the type of rate they are associated with.
{% enddocs %}

{% docs quotes__request_source %}
This is the source system the quote is created from, such as an indicator for the external-facing 
Rental website or the internal Quotes tool.
{% enddocs %}

{% docs quotes__role %}
The role type for a quote determines if a user has read-only, edit, or owner access on the quote. 
This is determined in the user's user_security_level.
{% enddocs %}

{% docs quotes__sale_item %}
This contains the non-rental line items listed under 'Sale items' in a quote.
{% enddocs %}

{% docs quotes__secondary_sales_rep %}
Secondary sales representatives didn't create a quote but have permission to update.
Quotes can have multiple secondary sales reps associated.
{% enddocs %}

{% docs quotes__shift %}
This describe the shift type to be applied to a piece of equipment.
Shifts refers to how many shifts will the equipment be used for per day.
* Single: 1x rate
* Double: 1.5x rate
* Triple: 2x rate
Shift-based billing feature is described in 
https://www.notion.so/equipmentshare/Shift-Based-Billing-for-Equipment-Rentals-366e1e4c05f04a1e95ce1ce2f61cc32d
{% enddocs %}


<!-------------------- PIT -------------------->
{% docs quotes__customer_pit %}
Point-in-time history for a quote customer's record.
{% enddocs %}
