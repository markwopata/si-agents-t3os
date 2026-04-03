<!-- These are definitions copied and pasted from platform project. 
Temporary workaround while projects cannot share definitions, but enforcing data contracts require columns to be defined.
-->

<!-------------------- DIM_ASSETS -------------------->

{% docs platform__asset_key %} 
Surrogate Key for the Assets Dimension
{% enddocs %}

{% docs platform__asset_source %} 
Source System of the Asset Data
{% enddocs %}

{% docs platform__asset_id %} 
Source or Natural Key for the Asse
{% enddocs %}

{% docs platform__asset_active %} 
Active flag for the Asset
{% enddocs %}

{% docs platform__asset_year %} 
Model Year for the Asset
{% enddocs %}

{% docs platform__asset_description %} 
Description for the Asset
{% enddocs %}

{% docs platform__asset_vin %} 
VIN for the Asset
{% enddocs %}

{% docs platform__asset_serial_number %} 
Serial Number for the Asset
{% enddocs %}

{% docs platform__asset_inventory_market_id %} 
Inventory Market ID (Reference Number) for the Asset
{% enddocs %}

{% docs platform__asset_inventory_market_key %} 
Inventory Market Surrogate Key for the Asset
{% enddocs %}

{% docs platform__asset_rental_market_id %} 
Rental Market ID (Reference Number) for the Asset
{% enddocs %}

{% docs platform__asset_rental_market_key %} 
Rental Market Surrogate Key for the Asset
{% enddocs %}

{% docs platform__asset_service_market_id %} 
Service Market ID (Reference Number) for the Asset
{% enddocs %}

{% docs platform__asset_service_market_key %} 
Service Market Surrogate Key for the Asset
{% enddocs %}

{% docs platform__asset_market_id %} 
Logic Derived Market ID (Reference Number).  If Rental Market is populated show first, if not then show Inventory Market, and finally if both are empty show Default Market Record
{% enddocs %}

{% docs platform__asset_market_key %} 
Logic Dervied Market Surrogate Key.  If Rental Market is populated show first, if not then show Inventory Market, and finally if both are empty show Default Market Record"
{% enddocs %}

{% docs platform__asset_company_id %} 
Company ID (Reference Number) tied to the Asset
{% enddocs %}

{% docs platform__asset_company_key %} 
Company Surrogate Key tied to the Asset
{% enddocs %}

{% docs platform__asset_tracker_id %} 
Tracker ID (Reference Number) tied to the Asset.  There are multiple ways to link Assets and Trackers together and this is one.  This column will be in the table for other intermediate creation processes but will be left out of the end user views in favor of the int_asset_tracker_mapping model.
{% enddocs %}

{% docs platform__asset_equipment_make %} 
Make of the Asset
{% enddocs %}

{% docs platform__asset_equipment_type %} 
Type of Asset
{% enddocs %}

{% docs platform__asset_equipment_model_name %} 
Model of the Asset
{% enddocs %}

{% docs platform__asset_equipment_class_name %} 
Class of the Asset
{% enddocs %}

{% docs platform__asset_equipment_subcategory_name %} 
Subcategory Name of the Asset
{% enddocs %}

{% docs platform__asset_equipment_category_name %} 
Category Name of the Asset
{% enddocs %}

{% docs platform__asset_equipment_contractor_owned %} 
Flag indicating if the Asset is Contractor Owned
{% enddocs %}

{% docs platform__asset_payout_program %} 
Payout Program the Asset is tied to
{% enddocs %}

{% docs platform__asset_payout_program_type %} 
Payout Program the Asset is tied to
{% enddocs %}

{% docs platform__asset_payout_program_billing_type %} 
Payout Program Billing Type the Asset is tied to
{% enddocs %}

{% docs platform__asset_payout_program_percentage %} 
Payout Program Percentage the Asset is tied to
{% enddocs %}

{% docs platform__asset_oem_delivery_date %} 
OEM Delivery Date of the Asset
{% enddocs %}

{% docs platform__asset_purchase_date %} 
Purchase Date of the Asset
{% enddocs %}

{% docs platform__asset_date_created %} 
Created Date of the Asset
{% enddocs %}

{% docs platform__asset_date_updated %} 
Updated Date of the Asset
{% enddocs %}

{% docs platform__asset_current_oec %} 
Current OEC Value of the Asset
{% enddocs %}

{% docs platform__asset_rentable %} 
Flag indicating if the Asset is Rentable
{% enddocs %}

{% docs platform__asset_first_rental_start_date %} 
First Rental Start Date of the Asset
{% enddocs %}

{% docs platform__asset_most_recent_on_rent_date %} 
Most Recent On Rent Date of the Asset
{% enddocs %}

{% docs platform__asset_inventory_status %} 
Inventory Status of the Asset
{% enddocs %}

{% docs platform__asset_inventory_status_date %} 
Inventory Status Date of the Asset
{% enddocs %}

{% docs platform__asset_hours %} 
Hours Reading on the Asset
{% enddocs %}

{% docs platform__asset_odometer %} 
Odometer Reading of the Asset
{% enddocs %}

{% docs platform__asset_underperforming_flag %} 
Flag indicating an Asset is Underperforming.
Asset must be Active, have an Inventory Status set to 'Ready to Rent',
Purchase Date over 90 days ago, has been Rented at least 1 time, and hasn't been rented in the past 90 days.
{% enddocs %}

{% docs platform__asset_never_rented %} 
Flag indicating an Asset has Never been Rented.
Asset must be Active, have an Inventory Status set to 'Ready to Rent',
Purchase Date over 1 year ago, has never been rented before, and has been in 'Ready to Rent' status for over 1 year.
{% enddocs %}

{% docs platform__asset_net_book_value %} 
Net Book Value (NBV) of the Asset.  This calculation is from an Asset Persepective and meant to be used as a descriptive attribute slicer 
(ie. Show only Assets with NBV greater than 55,000).  NBV can be calculated in different ways depending on the business intent/scope/perspective.
To be as accurate as possible, this calculation converts to a daily rate and dynamically calculates the NBV based on this rate (and the corresponding date range
for each Asset).  Most Accounting versions of this calculation will use a Day 15 or Mid-Month based rate for partial time periods.  Additionally, if any 
data is missing or out of normal range this calculation will show 0 (zero)
{% enddocs %}

{% docs platform__asset_ifta_reporting %} 
Indicator that shows if the Asset is flagged for IFTA Reporting. IFTA = International Fuel Tax Agreement
{% enddocs %}

{% docs platform__asset_alert_enter_geofence %} 
Indicator that shows if the Asset is configured to Alert on Entering a Geofence.
{% enddocs %}

{% docs platform__asset_alert_exit_geofence %} 
Indicator that shows if the Asset is configured to Alert on Exiting a Geofence.
{% enddocs %}

{% docs platform__asset_last_location %} 
Last Location Coordinates for the Asset.  This string representation of the coordinates is derived from the ASKV Location 
Value which is converted to geography data type and formatted accordingly.
{% enddocs %}

<!-------------------- DIM_DATES-------------------->

{% docs platform__dt_key %}
Surrogate Key for the Dates Dimension
{% enddocs %}

{% docs platform__dt_date %}
Source or Natural Key of the Date Record
{% enddocs %}

{% docs platform__dt_year %}
Year number of the Date Record.
{% enddocs %}

{% docs platform__dt_month %}
Month number of the Date Record
{% enddocs %}

{% docs platform__dt_month_name %}
Month Name of the Date Record
{% enddocs %}

{% docs platform__dt_period %}
Period of the Date Record in the format of '<<Month Name>> YYYY'
{% enddocs %}

{% docs platform__dt_prior_period %}
Prior Period of the Date Record in the format of '<<Month Name>> YYYY'
{% enddocs %}

{% docs platform__dt_next_period %}
Next Period of the Date Record in the format of '<<Month Name>> YYYY'
{% enddocs %}

{% docs platform__dt_year_month %}
Year Month text representation that the Date Record belongs to.  
Useful for Sorting Years and Months in Calendar order.
{% enddocs %}

{% docs platform__dt_day %}
Day number of the Date Record
{% enddocs %}

{% docs platform__dt_day_of_week %}
Day of the Week number of the Date Record
{% enddocs %}

{% docs platform__dt_week_of_year %}
Day of the Year number of the Date Record
{% enddocs %}

{% docs platform__dt_day_of_year %}
Day of the Year number of the Date Record
{% enddocs %}

{% docs platform__dt_weekday %}
Weekday Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_last_30_days %}
Last 30 Days Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_last_60_days %}
Last 60 Days Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_last_90_days %}
Last 90 Days Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_last_120_days %}
Last 120 Days Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_last_180_days %}
Last 180 Days Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_year_to_date %}
Year to Date Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_quarter_to_date %}
Quarter to Date Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_month_to_date %}
Month to Date Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_prior_year_to_date %}
Prior Year to Date Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_prior_month_to_date %}
Prior Month to Date Indciator of the Date Record
{% enddocs %}

{% docs platform__dt_prior_month %}
Prior Month Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_current_month %}
Current Month Indicator of the Date Record
{% enddocs %}

{% docs platform__dt_prior_quarter %}
Prior Quarter Indicator of the Date Record
{% enddocs %}

<!-------------------- DIM_COMPANIES ------------------->

{% docs platform__company_key %}
Identifier or description for `COMPANY_KEY`.
{% enddocs %}

{% docs platform__company_source %}
Identifier or description for `COMPANY_SOURCE`.
{% enddocs %}

{% docs platform__company_id %}
Identifier or description for `COMPANY_ID`.
{% enddocs %}

{% docs platform__company_name %}
Identifier or description for `COMPANY_NAME`.
{% enddocs %}

{% docs platform__company_has_fleet %}
Identifier or description for `COMPANY_HAS_FLEET`.
{% enddocs %}

{% docs platform__company_has_fleet_cam %}
Identifier or description for `COMPANY_HAS_FLEET_CAM`.
{% enddocs %}

{% docs platform__company_timezone %}
Identifier or description for `COMPANY_TIMEZONE`.
{% enddocs %}

{% docs platform__company_credit_limit %}
Identifier or description for `COMPANY_CREDIT_LIMIT`.
{% enddocs %}

{% docs platform__company_do_not_rent %}
Identifier or description for `COMPANY_DO_NOT_RENT`.
{% enddocs %}

{% docs platform__company_has_msa %}
Identifier or description for `COMPANY_HAS_MSA`.
{% enddocs %}

{% docs platform__company_has_rentals %}
Identifier or description for `COMPANY_HAS_RENTALS`.
{% enddocs %}

{% docs platform__company_net_terms %}
Identifier or description for `COMPANY_NET_TERMS`.
{% enddocs %}

{% docs platform__company_is_eligible_for_payouts %}
Identifier or description for `COMPANY_IS_ELIGIBLE_FOR_PAYOUTS`.
{% enddocs %}

{% docs platform__company_is_rsp_partner %}
Identifier or description for `COMPANY_IS_RSP_PARTNER`.
{% enddocs %}

{% docs platform__company_is_telematics_service_provider %}
Identifier or description for `COMPANY_IS_TELEMATICS_SERVICE_PROVIDER`.
{% enddocs %}

<!-------------------- DIM_USERS ------------------->
{% docs platform__user_key %}
Surrogate Key for the Users Dimension.
{% enddocs %}

{% docs platform__user_source %}
Source System of User Record
{% enddocs %}

{% docs platform__user_id %}
Source or Natural Key for the User Record
{% enddocs %}

{% docs platform__user_username %}
Username of the User Record
{% enddocs %}

{% docs platform__user_deleted %}
Deleted Indicator for the User record
{% enddocs %}

{% docs platform__user_company_key %}
Surrogate Key from the Dim Companies table.
{% enddocs %}

{% docs platform__user_company_id %}
Source or Natural Key for the Company tied to the User record.
{% enddocs %}

{% docs platform__user_first_name %}
First Name for the User
{% enddocs %}

{% docs platform__user_last_name %}
Last Name for the User
{% enddocs %}

{% docs platform__user_full_name %}
Logic derived column that puts the First and Last Name fields together in the following format: First <<space>> Last.
{% enddocs %}

{% docs platform__user_timezone %}
Timezone tied to the User record.
{% enddocs %}

{% docs platform__user_accepted_terms %}
Accepted Terms Indicator for the User record.
{% enddocs %}

{% docs platform__user_approved_for_purchase_orders %}
Approved for Purchase Orders Indicator for the User record.
{% enddocs %}

{% docs platform__user_is_salesperson %}
Is Salesperson Indicator for the User record.
{% enddocs %}

{% docs platform__user_can_access_camera %}
Can Access Camera Indicator for the User record.
{% enddocs %}

{% docs platform__user_can_create_asset_financial_records %}
Can Create Asset Financial Records Indicator for the User record.
{% enddocs %}

{% docs platform__user_can_grant_permissions %}
Can Grant Permissions Indicator for the User record.
{% enddocs %}

{% docs platform__user_can_read_asset_financial_records %}
Can Read Asset Financial Records for the User record.
{% enddocs %}

{% docs platform__user_can_rent %}
Can Rent Indicator for the User record.
{% enddocs %}

{% docs platform__user_sms_opted_out %}
SMS Opted Out Indicator for the User record.
{% enddocs %}

{% docs platform__user_read_only %}
Read Only Indicator for the User record.
{% enddocs %}

<!-------------------- DIM_ORDERS -------------------->

{% docs platform__order_key %} 
Surrogate Key for the Order Dimension
{% enddocs %}

{% docs platform__order_id %}
Natural key (business key) for the order record.
{% enddocs %}

{% docs platform__order_source %}
Source system for the order record.
{% enddocs %}

{% docs platform__order_recordtimestamp %}
Timestamp field used for incremental processing of order records.
{% enddocs %}

{% docs platform__order_status %}
Current status of the order.
{% enddocs %}

{% docs platform__order_total_amount %}
Total monetary amount of the order.
{% enddocs %}

{% docs platform__order_created_date %}
Date when the order was created.
{% enddocs %}

<!-------------------- DIM_MARKETS -------------------->

{% docs platform__market_key %} 
Surrogate Key for the Markets Dimension
{% enddocs %}

{% docs platform__market_id %}
Natural key (business key) for the market record.
{% enddocs %}

{% docs platform__market_source %}
Source system for the market record.
{% enddocs %}

{% docs platform__market_recordtimestamp %}
Timestamp field used for incremental processing of market records.
{% enddocs %}

{% docs platform__market_name %}
Name of the market location.
{% enddocs %}

{% docs platform__market_region %}
Geographic region the market belongs to.
{% enddocs %}

{% docs platform__market_active %}
Flag indicating if the market is currently active.
{% enddocs %}

{% docs platform__market_company_id %}
Company ID that owns/operates this market location.
{% enddocs %}

{% docs platform__market_company_key %}
Company surrogate key that owns/operates this market location.
{% enddocs %}

{% docs platform__market_division_id %}
Division identifier for the market (e.g., Rental, Corp, Tele, etc.).
{% enddocs %}

{% docs platform__market_division_name %}
Division name the market belongs to (Rental, Corp, Tele, E-Commerce, Manufacturing, Materials, T3, National).
{% enddocs %}

{% docs platform__market_district %}
District identifier in the region > district > market hierarchy.
{% enddocs %}

{% docs platform__market_region_name %}
Region name in the region > district > market hierarchy.
{% enddocs %}

{% docs platform__market_address %}
Physical address of the market location.
{% enddocs %}

{% docs platform__market_city %}
City where the market is located.
{% enddocs %}

{% docs platform__market_state %}
State or province where the market is located.
{% enddocs %}

{% docs platform__market_zip_code %}
ZIP or postal code for the market location.
{% enddocs %}

{% docs platform__market_phone %}
Primary phone number for the market location.
{% enddocs %}

{% docs platform__market_email %}
Primary email address for the market location.
{% enddocs %}

{% docs platform__market_manager_user_id %}
User ID of the market manager.
{% enddocs %}

{% docs platform__market_manager_user_key %}
User surrogate key of the market manager.
{% enddocs %}

{% docs platform__market_timezone %}
Timezone for the market location.
{% enddocs %}

{% docs platform__market_public_rsp %}
Flag indicating if this market participates in public RSP (Rental Service Provider) network.
{% enddocs %}

{% docs platform__market_latitude %}
Latitude coordinate of the market location.
{% enddocs %}

{% docs platform__market_longitude %}
Longitude coordinate of the market location.
{% enddocs %}

{% docs platform__market_date_opened %}
Date when the market location was opened for business.
{% enddocs %}

{% docs platform__market_date_closed %}
Date when the market location was closed (if applicable).
{% enddocs %}

{% docs platform__market_square_footage %}
Total square footage of the market facility.
{% enddocs %}

{% docs platform__market_lot_size %}
Size of the market lot/property in square feet or acres.
{% enddocs %}

<!-------------------- DIM_PARTS -------------------->

{% docs platform__part_key %} 
Surrogate Key for the Parts Dimension
{% enddocs %}

{% docs platform__part_id %}
Natural key (business key) for the part record.
{% enddocs %}

{% docs platform__part_source %}
Source system for the part record.
{% enddocs %}

{% docs platform__part_recordtimestamp %}
Timestamp field used for incremental processing of part records.
{% enddocs %}

{% docs platform__part_name %}
Name or description of the part.
{% enddocs %}

{% docs platform__part_category %}
Category classification of the part.
{% enddocs %}

{% docs platform__part_active %}
Flag indicating if the part is currently active in inventory.
{% enddocs %}

{% docs platform__part_type_id %}
Part type identifier linking to part type classification.
{% enddocs %}

{% docs platform__part_type_name %}
Name of the part type classification.
{% enddocs %}

{% docs platform__part_description %}
Detailed description of the part.
{% enddocs %}

{% docs platform__part_manufacturer %}
Manufacturer or brand of the part.
{% enddocs %}

{% docs platform__part_model_number %}
Model number or SKU of the part.
{% enddocs %}

{% docs platform__part_unit_price %}
Standard unit price for the part.
{% enddocs %}

{% docs platform__part_cost %}
Cost basis of the part for inventory valuation.
{% enddocs %}

{% docs platform__part_weight %}
Weight of the part for shipping and logistics.
{% enddocs %}

{% docs platform__part_dimensions %}
Physical dimensions of the part.
{% enddocs %}

<!-------------------- DIM_LINE_ITEMS -------------------->

{% docs platform__line_item_key %}
Surrogate Key for the Line Items Dimension
{% enddocs %}

{% docs platform__line_item_id %}
Natural key (business key) for the line item record.
{% enddocs %}

{% docs platform__line_item_source %}
Source system for the line item record.
{% enddocs %}

{% docs platform__line_item_recordtimestamp %}
Timestamp field used for incremental processing of line item records.
{% enddocs %}

{% docs platform__line_item_type_id %}
Line item type identifier for categorization (e.g., rental=8, accessory=44).
{% enddocs %}

{% docs platform__line_item_type_name %}
Name of the line item type classification.
{% enddocs %}

{% docs platform__line_item_description %}
Description of the line item.
{% enddocs %}

{% docs platform__line_item_quantity %}
Quantity of the line item.
{% enddocs %}

{% docs platform__line_item_unit_price %}
Unit price for the line item.
{% enddocs %}

{% docs platform__line_item_total_amount %}
Total amount for the line item (quantity * unit_price).
{% enddocs %}

{% docs platform__line_item_discount_amount %}
Any discount applied to the line item.
{% enddocs %}

{% docs platform__line_item_tax_amount %}
Tax amount applied to the line item.
{% enddocs %}

{% docs platform__line_item_start_date %}
Start date for rental or service line items.
{% enddocs %}

{% docs platform__line_item_end_date %}
End date for rental or service line items.
{% enddocs %}

{% docs platform__line_item_duration %}
Duration in days for rental or service line items.
{% enddocs %}

{% docs platform__line_item_is_rental %}
Boolean flag indicating if this is a rental line item (line_item_type_id = 8).
{% enddocs %}

{% docs platform__line_item_is_accessory %}
Boolean flag indicating if this is an accessory line item (line_item_type_id = 44).
{% enddocs %}

{% docs platform__line_item_asset_id %}
Asset identifier for equipment rental line items.
{% enddocs %}

{% docs platform__line_item_part_id %}
Part identifier for parts/accessory line items.
{% enddocs %}

<!-------------------- DIM_TRACKERS ------------------->

{% docs platform__tracker_key %}
Surrogate Key for the Tracker Dimension
{% enddocs %}

{% docs platform__tracker_source %}
Source System of the Tracker Data
{% enddocs %}

{% docs platform__tracker_id_trackersdb %}
Tracker ID from the TrackersDB Source System
{% enddocs %}

{% docs platform__tracker_id_esdb %}
Tracker ID from the ESDB Source System
{% enddocs %}

{% docs platform__tracker_device_serial %}
Device Serial Number for the Tracker
{% enddocs %}

{% docs platform__tracker_date_installed %}
Date Installed for the Tracker. (Derived from Asset Tracker Assignments table Date Installed and the Asset table Date Updated columns. Includes a simple check to ensure that the Date Installed, if available and a Tracker ID is set on the Asset Record, is greater than the Asset Date Updated. If not, then put a default timestamp indicating an Unknown Date Installed.)
{% enddocs %}

<!-------------------- DIM_INVOICES -------------------->
{% docs platform__invoice_key %}
Surrogate Key for the Invoices Dimension
{% enddocs %}