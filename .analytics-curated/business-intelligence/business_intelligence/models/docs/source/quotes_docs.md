{% docs quotes__audit_history_id %}
Identifier for a specific action done on a quote.
{% enddocs %}

{% docs quotes__audit_event_type_id %}
Identifier for a quote's audit event type.
{% enddocs %}

{% docs quotes__audit_event_type_name %}
Types of events that can be audited for quotes are:
* `Created`
* `Generated` - this refers to generating the Quote PDF
* `Order_Created`
* `Viewed`
* `Updated`
* `Sent_To_Customer`
{% enddocs %}

{% docs quotes__quote_id %}
Unique identifier for a quote. 
This is what goes into a quote URL: https://quotes.estrack.com/[quote_id]
{% enddocs %}

{% docs quotes__quote_number %}
Numerical identifier for a quote. 
This is what customers would likely use to reference their quote.
{% enddocs %}

{% docs quotes__quote_json %}
JSON representation of the quote.
{% enddocs %}

{% docs quotes__audit_event_timestamp %}
Time when an audit event occurs.
{% enddocs %}

{% docs quotes__rate_type_id %}
This is the rate type identifier.
{% enddocs %}

{% docs quotes__rate_type_name %}
Rate types for quotes are:
* `Advertised`
* `Benchmark`
* `Book`
* `Combo`
* `Company`
* `Custom`
* `Deal`
* `Floor`
* `Optimal`
{% enddocs %}

{% docs quotes__role_id %}
This is the role id for a quote.
{% enddocs %}

{% docs quotes__role_name %}
Types of roles in quotes are:
* `edit`
* `owner`
* `read-only`
{% enddocs %}

{% docs quotes__has_pdf %}
Indicates whether a downloadable PDF has been generated for the quote. 
The PDF has the line-item breakdown, and each time the PDF is generated, it makes a call 
the billing API.
Multiple PDFs can be generated for a quote; a new version of the PDF is created 
each time and stored in the S3 bucket.
{% enddocs %}

{% docs quotes__order_created_by_user_id %}
A quote is converted to an order by an EquipmentShare user. This is EquipmentShare's user id.
{% enddocs %}

{% docs quotes__quote_created_datetime %}
Time when the quote was created in the database.
{% enddocs %}

{% docs quotes__salesperson_user_id %}
The salesperson's user id that created the quote.
{% enddocs %}

{% docs quotes__pricing_id %}
The unique identifier for a quote's prices.
{% enddocs %}

{% docs quotes__delivery_fee %}
This is the quoted delivery fee price.
This is located in the Pricing section of a quote under Delivery Fee.
{% enddocs %}

{% docs quotes__pickup_fee %}
This is the quoted pickup fee price.
This is located in the Pricing section of a quote under Pickup Fee.
{% enddocs %}

{% docs quotes__delivery_type_id %}
This is the delivery type id that's specific to quotes. This has no relation to actual deliveries.
{% enddocs %}

{% docs quotes__delivery_type %}
Delivery types here are specific to quotes. This has no relation to actual deliveries. 
The delivery types are: 
* `Internal`
* `Third Party`
* `Customer`
{% enddocs %}

{% docs quotes__contact_location_id %}
This id refers to the location of the party requesting the quote.
It refers to an existing location id or generates a new id if a new location is added 
during quote creation.
{% enddocs %}

{% docs quotes__contact_location_name %}
This field is only populated if during quote creation, when filling out the 
'Delivery details' section, a new location is entered instead of using the 
'Use existing location' option.
This is the location name of the party requesting the quote.
This shows up in the Customer section under 'Quote Contact' in a quote.
{% enddocs %}

{% docs quotes__contact_location_address %}
This field is only populated if during quote creation, when filling out the 
'Delivery details' section, a new location is entered instead of using the 
'Use existing location' option.
This is the location address of the party requesting the quote.
This shows up in the Customer section under 'Quote Contact' in a quote.
{% enddocs %}

{% docs quotes__contact_location_coordinates %}
This is lagitutde and longitude of the location address of the party requesting the quote.
{% enddocs %}

{% docs quotes__quote_start_time %}
Start date and time for the quote.
{% enddocs %}

{% docs quotes__quote_end_time %}
End date and time for the quote.
{% enddocs %}

{% docs quotes__escalation_id %}
This is the unique identifier for a quote escalation.
{% enddocs %}

{% docs quotes__escalation_attachment_file %}
If an attachment is included in the escalation.
The value in this field appears to be formatted as 
[attachment_id]__[YYYY-MM-DD-HH-MM-SS]__[file name].[file extension format].
{% enddocs %}

{% docs quotes__escalation_created_at %}
Time the escalation was created in the database.
{% enddocs %}

{% docs quotes__escalation_reason %}
The free text that the ES user inputs into 'Reason for Escalation' when escalating a quote.
{% enddocs %}

{% docs quotes__escalation_user_id %}
This is the user id of the ES user, usually a salesperson, that escalates the quote. This person 
is copied to the escalation email that's sent to the sales leadership. The user that escalates the 
quote does not have to be one of the salespeople the quote is associated with.
{% enddocs %}

{% docs quotes__escalation_email %}
This is the email of the ES user that escalated the quote. This email is copied to the escalation email that's sent to 
the sales leadership.
{% enddocs %}

{% docs quotes__escalation_user_name %}
This is the name of the ES user that escalated the quote. Should be the same as the information 
we have for them in the USERS table.
{% enddocs %}

{% docs quotes__escalation_updated_at %}
This is the last updated timestamp of when the escalation was updated.
Currently, escalations are a one-step process where updated timestamp is essentially the same as the created timestamp.
{% enddocs %}

{% docs quotes__quote_expiration_time %}
Per code commit and confirmation with Eng team on 3/20/25, quotes are default set to expire 30 days
from the expected start date of the quote.
Code reference: https://gitlab.internal.equipmentshare.com/demand-capture-and-orders/quotes-web-api/-/blob/main/alembic/versions/202312131721_2de142a6668d_update_existing_quote_expiry_dates_to_.py?ref_type=heads
{% enddocs %}

{% docs quotes__quote_is_tax_exempt %}
When creating a new quote, this is manually selected in the Modifications section in the 'Is Customer Tax Exempt'.
When updating a quote, this can be updated in the Pricing section of the existing quote.
{% enddocs %}

{% docs quotes__missed_quote_reason %}
An open or expired quote can be updated to be a Missed Quote.
This is a manual action from the TAM to go in and add in the reason. 
The list of available reasons (only one can be selected) are:
* Availability
* Lack of Transport
* Rate
* Other
{% enddocs %}

{% docs quotes__missed_quote_reason_other %}
An open or expired quote can be updated to be a Missed Quote.
This is a manual action from the TAM to go in and add in the reason. 
This is the text the Tam inputs when 'Other' is selected as the missed rental reason.
{% enddocs %}

<!-- CONTACT SECTION -->

{% docs quotes__contact_email %}
This is the email of the party requesting the quote.
This is part of the Customer section under 'Quote Contact' in a quote.
{% enddocs %}

{% docs quotes__contact_name %}
This is the name of the party requesting the quote.
This is part of the Customer section under 'Quote Contact' in a quote.
{% enddocs %}

{% docs quotes__contact_id %}
This is the identifier of the party requesting the quote.
This is part of the Customer section under 'Quote Contact' in a quote.
{% enddocs %}

{% docs quotes__contact_phone %}
This is the phone number of the party requesting the quote.
This is part of the Customer section under 'Quote Contact' in a quote.
{% enddocs %}

{% docs quotes__contact_location_description %}
This field is only populated if during quote creation, when filling out the 
'Delivery details' section, the 'Use existing location' is selected.
This is the location name and address of the party requesting the quote.
This shows up in the Customer section under 'Quote Contact' in a quote.
{% enddocs %}

{% docs quotes__contact_new_company_name %}
This field is only populated if a company name is entered that doesn't currently exist in 
the database. These are companies that are marked as pending validation and will be 
finalized once the quote is converted to an order.
{% enddocs %}

{% docs quotes__contact_new_location_info %}
This field is a JSON that can have some redundancy info about location that's also 
populated in the following fields:
* `location_description`
* `deliver_to`
* `deliver_to_address`
* `deliver_to_latitude`
* `deliver_to_longitude`
{% enddocs %}

{% docs quotes__order_created_time %}
This is the time the order is created from a quote.
This should match the timestamp in the ORDERS table, but small discrepancies
may occur from the time it's written to the ORDERS table vs the QUOTES table.
{% enddocs %}

{% docs quotes__quote_last_modified_time %}
The time the quote was last modified.
{% enddocs %}

{% docs quotes__quote_last_modified_by_user_id %}
The user id that last modified the quote.
{% enddocs %}

{% docs quotes__project_type %}
This is an optional field that can be added to the customer details. A customer can be associated with multiple projects.
Available project types are:
* `Agricultural`
* `Business Services`
* `Education`
* `Electric Services`
* `Governmental`
* `Health Services`
* `Heavy Construction except Highway`
* `Highway/Street Heavy Construction`
* `Hotels and Motels`
* `Industrial Plant`
* `Manufacturing`
* `Multi-Family Residence`
* `Office Building Construction`
* `Oil and Gas`
* `Other`
* `Public Order and Safety`
* `Recreational`
* `Religious Organizations`
* `Retail`
* `Single Family Residence`
* `Transportation Services`
* `Warehouse`
* `Water/Sewer/Utility Construction`
{% enddocs %}

{% docs quotes__site_contact_name %}
This is an optional field for the name of a site contact.
This shows up in the Customer section under 'Site Contact' in a quote.
{% enddocs %}

{% docs quotes__site_contact_phone %}
This is an optional field for the phone number of a site contact.
This shows up in the Customer section under 'Site Contact' in a quote.
{% enddocs %}

{% docs quotes__duplicated_from_quote_id %}
This is an indicator that the quote was duplicated from another quote.
This is more used to help salespeople create quotes more quickly by 
cloning an existing quote that may be similar.
{% enddocs %}

{% docs quotes__shift_type_id %}
This is the unique identifier of a shift.
{% enddocs %}

{% docs quotes__shift_type_multiplier %}
Multiplier values are: 
* `1`
* `1.5`
* `2`
{% enddocs %}

{% docs quotes__shift_type_name %}
Shift type names are:
* `Single`
* `Double`
* `Triple`
{% enddocs %}

{% docs quotes__customer_id %}
This is the unique identifier of a customer. This is the customer id representing both prospective and existing customers in the quote system.
This is meant to represent both new customers (that don't exist in the database) and existing customers 
while deprecating redudnat fields like `new_company_name` and `company_id`. 
This seems to have been added into the database late Jan 2025. This field is always populated since it's been added as a new field.
{% enddocs %}

{% docs quotes__secondary_salesperson_user_id %}
This is the user id of the secondary sales person for a quote.
{% enddocs %}

{% docs quotes__sale_item_id %}
This is the unique identifier for an item under 'Sale items' in a quote.
{% enddocs %}

{% docs quotes__sale_item_description %}
If the Line Item Type is not `Parts Retail Sale`, the description is manually inputted.
If the Line Item Type = `Parts Retail Sale`. a dropdown is provided with a list of part names.
{% enddocs %}

{% enddocs %}

{% docs quotes__sale_item_price %}
The value stored is the sale_item.quantity x manually inputted price.
{% enddocs %}

{% docs quotes__sale_item_quantity %}
The number of units of the sale item. This is inputted manually.
{% enddocs %}

{% docs quotes__sale_item_part_id %}
This should only be populated when the Sale Item Type = `Parts Retail Sale`.
{% enddocs %}

{% docs quotes__equipment_type_id %}
This is the unique identifier for the quoted asset or quoted part and their corresponding pricing.
{% enddocs %}

{% docs quotes__equipment_parent_line_item_id %}
This field seems to be more for the UI and doesn't serve much purpose outside of how it's laid out on the page.
When an asset ('Equipment') is chosen, there is an option to add bulk item(s) in the same section of the quote 
instead of in the separate 'Bulk equipment' section. 
{% enddocs %}

{% docs quotes__equipment_selected_rate_type_id %}
This is the rate type selected with the corresponding quoted rates for an individual equipment item.
{% enddocs %}

{% docs quotes__quote_created_by_user_id %}
User that created the quote.
{% enddocs %}

{% docs quotes__quote_pricing_created_time %}
This timestamp is when the values are written into the `QUOTE_PRICING` table but is always after the 
timestamp in the `QUOTE` table.
{% enddocs %}

{% docs quotes__quote_pricing_created_by_user_id %}
Quote pricing created by user.
{% enddocs %}

{% docs quotes__equipment_charges %} 
This is the amount that shows in 'Equipment Charges' in the 'Pricing' section of the quote.
Behind-the-scenes, this lumps together additional charges such as Environmental Fees into this amount.
{% enddocs %}

{% docs quotes__rental_subtotal %} 
This is the total amount for equipment - both rentals and bulk parts.
This shows up in the 'Pricing' section as 'Rental Subtotal'.
{% enddocs %}

{% docs quotes__rental_protection_plan_price %} 
This is the price associated with a rental protection plan for the quote.
This value is not directly visible in the quote - it is included in the overall 'RPP'
value in the 'Pricing' section and only appears in the section if a rental protection plan was 
selected for the quote.
{% enddocs %}

{% docs quotes__rental_protection_plan_tax %} 
This is the tax associated with a rental protection plan.
This value is not directly visible in the quote - it is included in the overall 'RPP'
value in the 'Pricing' section and only appears in the section if a rental protection plan was 
selected for the quote.
{% enddocs %}

{% docs quotes__sales_tax %} 
This is the total sales tax associated with the quote and includes the rental protection plan tax.
This value is not directly visible in the quote - the quote shows the 'Sales Tax' without
the RPP tax, but the value stored in the database is the equipment taxes + RPP tax.
{% enddocs %}

{% docs quotes__sales_items_subtotal %} 
This is the total amount for sales items.
This shows up in the 'Pricing' section as 'Sale Items Subtotal'.
{% enddocs %}

{% docs quotes__total_amount %} 
This is the total amount entire quote.
This shows up in the 'Pricing' section as 'Total without COI'.
{% enddocs %}

{% docs quotes__equipment_item_quantity %}
The number of units of the asset or bulk part. This is inputted manually.
{% enddocs %}

{% docs quotes__equipment_day_rate %}
This is the day rate quoted for the item.
{% enddocs %}

{% docs quotes__equipment_week_rate %}
This is the 1-week rate quoted for the item.
{% enddocs %}

{% docs quotes__equipment_month_rate %}
This is the 4-week rate quoted for the item.
{% enddocs %}

<!-- The rates are offered when creating a quote -->
{% docs quotes__advertised_rate_description %}
An advertised rate can fluctuate due to market demands. Advertised rate does not affect the commission structure.
The value stored here is a reference to the specified rate that is stored in 
`ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES` at the time of quote creation; the actual rate 
in the ES table may have been updated since.
{% enddocs %}

{% docs quotes__benchmark_rate_description %}
A benchmark rate is a target rate aiming for around the market average.
The value stored here is a reference to the specified rate that is stored in 
`ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES` at the time of quote creation; the actual rate 
in the ES table may have been updated since.
{% enddocs %}

{% docs quotes__book_rate_description %}
A book rate replaces the former online rate and is generally 30% over the benchmark.
The value stored here is a reference to the specified rate that is stored in 
`ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES` at the time of quote creation; the actual rate 
in the ES table may have been updated since.
{% enddocs %}

{% docs quotes__company_rate_description %}
A company rate is an exclusive rate with the customer and is a reference to the value stored in
`ES_WAREHOUSE.PUBLIC.COMPANY_RENTAL_RATES` at the time of quote creation.
This shows up on the UI side as 'Pre-negotiated Rate'.
{% enddocs %}

{% docs quotes__deal_rate_description %}
(Reference doc: https://www.notion.so/equipmentshare/Rate-Management-Platform-d400794683a64300975bb4d306e7280f#f3a645549f594fbdaf520451970f5010)
A deal rate is a rate sales managers create on a class/district level. The deal rate is 
a distinct rate type and does not impact floor/bench/online rates. Deal rates only exist as a price per month, 
and the hour/day/week rates will remain at the floor. 
This deal rate will be used solely for commissions purposes — any rental at/above the 
deal rate will receive 4% commission, even if the rate is below floor. 
There is no approval process, and these rates become active immediately upon submission. 
Deal rates come from a Retool app, and the value is a reference to the value stored 
in `ANALYTICS.RATE_ACHIEVEMENT.DISCOUNT_RATES` at the time of quote creation.
{% enddocs %}

{% docs quotes__floor_rate_description %}
A floor rate is the lowest rate and requires the General Manager’s approval to go below.
Floor rate is not a visible option when creating a quote or order. It is used for other 
rate calculations as well as to display a warning when a rate is entered below the floor.
The value stored here is a reference to the specified rate that is stored in 
`ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES` at the time of quote creation; the actual rate 
in the ES table may have been updated since.
{% enddocs %}

{% docs quotes__online_rate_description %}
An online rate is 20-30% above benchmark. It appears to calculated on-the-fly.
{% enddocs %}

{% docs quotes__equipment_order_index %}
Numerical order the equipment is added to the quote and order equipment is displayed on the quote.
{% enddocs %}

{% docs quotes__equipment_note %}
Free text displayed under an equipment under 'Notes'.
{% enddocs %}

{% docs quotes__rental_service_provider_company_id %} 
This is pretty much always hardcoded as 1854. RSPs are determined on an individual asset level, 
so this field serves no purpose for the context of a quote.
{% enddocs %}

{% docs quotes__quote_request_source_id %} 
This is specific to the Quotes database. It is the unique identifier for where a quote originates from.
{% enddocs %}

{% docs quotes__quote_source_name %} 
Quotes can be created from multiple sources. The valid sources quotes can come from
* `ESMAX` - indicates the quote is created through the internal-facing Quotes tool
* `RETAIL` - indicates the quote is created through the retail / external-facing Rental Website.
     Note: this identifier hould be reliable after 2024-12-07. Any potential rental website requests can be identified through the `rental_order_request` database. 
* `UNKNOWN` - a catch-all for anything that is an outlier
{% enddocs %}

{% docs quotes__customer_company_billing_location_id %} 
This pulls in the billing location id from companies. This information is redundant.
{% enddocs %}

{% docs quotes__customer_created_at %} 
Timestamp when customer record was created in quotes DB.
{% enddocs %}

{% docs quotes__customer_archived_at %} 
This field is used to indicate customer records which are no longer associated with any open quotes (i.e., quotes which have not expired/missed rentals).
When this field is populated, it allows us to filter showing these customers in the dropdown in the Quotes app, reducing noise in all potential customers.

If a quote has a draft customer of Person A and that quote is updated to a different customer, and Person A is now orphaned, 
i.e., not associated with any open quotes, then the customer record for Person A will be archived by setting a timestamp on `archived_at`.
 
A lambda function is invoked at regular intervals which looks for any orphaned draft customers and sets `archived_at` .
Code source: https://gitlab.internal.equipmentshare.com/demand-capture-and-orders/quotes-web-api/-/blob/46fec0fe5d0276497fe09ab36c1ee4763732249b/app/services/quote_service.py#L467-470
{% enddocs %}

{% docs quotes__customer_updated_at %} 
The timestamp the customer record was updated
{% enddocs %}

{% docs quotes__customer_created_by %} 
User ID that manually created the quote customer.
Application-side creates a Customer record for every ESDB company to allow them to be searchable and selectable in the Quotes app. Customers records populated via this pipeline will not have a `created_by` value.
{% enddocs %}

{% docs quotes__customer_esdb_company_id %} 
Redundant storage in the quotes database for application lookup.
{% enddocs %}

{% docs quotes__customer_company_net_terms_id %} 
Redundant storage in the quotes database for application lookup.
{% enddocs %}

{% docs quotes__customer_company_name %} 
Redundant storage in the quotes database for application lookup. This stores a point-in-time reference of 
the company_name when the quote was made.
{% enddocs %}

{% docs quotes__customer_updated_by %} 
User ID that manually created the quote customer. Usually from an automated process.
{% enddocs %}

{% docs quotes__customer_company_do_not_rent %} 
Redundant storage in the quotes database for application lookup. This stores a point-in-time reference of 
the company's do_not_rent value when the quote was made.
{% enddocs %}

{% docs quotes__part_id %}
This value is only populated when the quoted equipment is a bulk part.
This value should be redundant and should match the value in `ES_WAREHOUSE.INVENTORY.PARTS.NAME`.
{% enddocs %}

{% docs quotes__part_name %}
This value is only populated when the quoted equipment is a bulk part.
This value should be redundant and should match the value in `ES_WAREHOUSE.INVENTORY.PARTS.NAME`.
If it doesn't match, it's because the name had been updated for the `part_id` after the quote was created.
{% enddocs %}

{% docs quotes__part_type_id %}
This value is only populated when the quoted equipment is a bulk part.
This value should be redundant and should match the value in `ES_WAREHOUSE.INVENTORY.PART_TYPES.PART_TYPE_ID`.
{% enddocs %}

{% docs quotes__equipment_cat_class %}
This value is only populated when the quoted equipment is a bulk equipment / non-serialized asset (has a corresponding `PART_ID`).
This value is redundant and also exists in the `CAT_CLASS` field of `ES_WAREHOUSE.INVENTORY.PRODUCT_CLASSES`.
{% enddocs %}

{% docs quotes__bulk_part_purchase_price %}
This value is only populated when the item a bulk equipment / non-serialized asset (has a corresponding `PART_ID`).
This value is redundant and also exists in the `MSRP` field of `ES_WAREHOUSE.INVENTORY.PARTS`.
{% enddocs %}