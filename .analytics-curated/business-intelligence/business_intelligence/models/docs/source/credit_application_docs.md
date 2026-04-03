{% docs credit_application__credit_application_master_retool_id %}
Unique identifier for an entry in the Credit Applications Retool App.
{% enddocs %}

{% docs credit_application__date_created_utc %}
Datetime when the credit application entry was created in UTC.
This field represents when the record was created; when a credit specialist updates an existing application, 
the update is a new record in the data.
{% enddocs %}

{% docs credit_application__created_by_email %}
The EquimentShare employee that created the credit application, if applicable.
This is populated if an employee (someone with an @equipmentshare.com email) creates the credit application for a company's behalf.
Otherwise, it's mostly `null` due to the insert via scheduled Snowflake procedure.
{% enddocs %}

{% docs credit_application__source %}
This represents the credit application's status:
* `Attention Needed`: Application is incomplete
* `Branch`: Assumes a rental branch filled out the application because a credit specialist hasn't touched 
    it in 24-48h 
* `Credit Specialist`: Application is by a credit specialist
* `System`: Possibly from bulk insert at table creation
* `Web`: When a customer created their own account (self signed up) and a credit specialist didn't 
    touch it later, which should be only when the credit status is also COD (cash-on-delivery)
{% enddocs %}

{% docs credit_application__company_id %}
ID of the company that is applying for credit evaluation.
{% enddocs %}

{% docs credit_application__company %}
Name of the company inputted at the time of the credit application.
Note: This may deviate from the name stored in the companies source.
{% enddocs %}

{% docs credit_application__market_id %}
Market ID the company is associated with / applying to get approved for credit in, but credit applications should apply across all markets, not just one specific market.
So this field is not important for understanding whether a company is approved for credit or not.
{% enddocs %}

{% docs credit_application__market %}
Market name the company is associated with / applying to get approved for credit in, but credit applications should apply across all markets, not just one specific market.
So this field is not important for understanding whether a company is approved for credit or not.
{% enddocs %}

{% docs credit_application__duns %}
A DUNS number, or Data Universal Numbering System number, is a unique nine-digit 
identifier assigned by Dun & Bradstreet to businesses. The primary purpose of a DUNS number is to provide a 
standardized and unique identifier for businesses, allowing them to establish a business 
credit file and identify a business entity globally. DUNS numbers are widely used by businesses,
 lenders, and government agencies to track and identify companies. 
{% enddocs %}
 
{% docs credit_application__fein %}
A Federal Employer ID Number (FEIN) identifies a business entity. This number is also referred 
to as a Federal Tax ID Number. Generally, all businesses need an FEIN. 
Many one-person businesses use their Social Security Number as their FEIN.
{% enddocs %}

{% docs credit_application__sic %}
A SIC code, or Standard Industrial Classification, is a four-digit code used to classify 
industries based on their primary business activity for statistical analysis and economic reporting.
While the North American Industry Classification System (NAICS) is the current standard, 
SIC codes are still used by some government agencies and organizations, particularly in the US. 
{% enddocs %}

{% docs credit_application__naics_primary %}
NAICS, or the North American Industry Classification System, is a six-digit code system 
used to classify businesses by industry in the United States, Canada, and Mexico. 
It replaced the Standard Industrial Classification (SIC) system in 1997. 

The U.S. Census Bureau assigns one primary NAICS code to each business establishment 
based on its primary activity, typically the one generating the most revenue. 
{% enddocs %}

{% docs credit_application__naics_secondary %}
Populated if the business has multiple NAICS codes. Businesses can have multiple NAICS codes 
to reflect different aspects of their operations, especially if they offer a variety of products or services. 
{% enddocs %}

{% docs credit_application__date_received_ct %}
Date the credit application was received in Central Time.
{% enddocs %}

{% docs credit_application__date_completed_ct %}
Date the credit application was completed in Central Time.
{% enddocs %}

{% docs credit_application__application_status %}
Since the credit application flow has been standardized via Retool, app statuses are updated via a dropdown. 
Valid statuses since the Retool app has been in place:
* `Approved` - approved for credit
* `COD Per Request` - if a company's record remains unchanged within 24 hours of submitting a credit application 
    or creating a new company, a background process automatically updates the application status to 
    "COD per request," signifying that the customer does not require credit.
* `Declined COD` - declined from credit so this represents a COD-based account
* `COD Branch`
* `COD Web`
* null - means the record is a new entry
{% enddocs %}

{% docs credit_application__application_type %}
The type of credit application being processed.
{% enddocs %}

{% docs credit_application__notes %}
Manually inputted notes from the credit specialist or salesperson.
{% enddocs %}

{% docs credit_application__salesperson_user_id %}
The salesperson's ES user ID.
{% enddocs %}

{% docs credit_application__salesperson %}
Before standardizing in Retool, the names were manually entered.
Through the Retool app, after mid-Feb 2024, names are standardized as either:
*  salesperson's name + their Workday employee ID (ie. 'Jerry Haworth - 13686')
* 'Pending Rep Assignment'
{% enddocs %}

{% docs credit_application__credit_specialist_user_id %}
The credit specialist's ES user ID.
{% enddocs %}

{% docs credit_application__credit_specialist %}
Before standardizing in Retool, the names were manually entered.
Through the Retool app, after mid-Feb 2024, names are standardized as:
*  credit specialist's name + their Workday employee ID (ie. 'Lauren Godsy - 2586')
{% enddocs %}

{% docs credit_application__government_entity %}
Boolean flag to indicate if the credit application is classified as a government entity.
{% enddocs %}

{% docs credit_application__insurance_info %}
Flag to indicate the credit application has insurance info.
{% enddocs %}

{% docs credit_application__online_app_status %}
Flag to indicate if the credit application has an online application.
{% enddocs %}

{% docs credit_application__deleted %}
Soft delete flag for deletion of a credit application.
{% enddocs %}

{% docs credit_application__salesperson_override %}
Flag to indicate if a salesperson went in to override some details of the credit application.
{% enddocs %}

{% docs credit_application__initial_web_self_signup %}
Flag to indicate if the company signed up before going through the credit application.
This is added via stored procedure.
{% enddocs %}

{% docs credit_application__coi_received %}
Flag to indicate if the company uploaded their Certificates of Insurance.
{% enddocs %}

{% docs credit_application__credit_safe_number %}
An identifier from Creditsafe, a global business credit reporting and risk management provider. 
Format:CC#########
Structure:
Prefix (CC): The country code where the business is registered or where the credit file is maintained. In this case, US = United States.
Numeric portion: A unique identifier assigned by Creditsafe to a company
{% enddocs %}

{% docs credit_application__insurance_company %}
Name of the insurance company, if the company submitting the credit app has an insurance.
{% enddocs %}

{% docs credit_application__insurance_email %}
Email of the insurance company, if the company submitting the credit app has an insurance.
{% enddocs %}

{% docs credit_application__insurance_phone %}
Phone number of the insurance company, if the company submitting the credit app has an insurance.
{% enddocs %}

{% docs credit_application__initial_web_unauthenticated %}
This flag indicates that the application first came through the dot com portal through our "unauthenticated" process. 
This means the company requested credit / applied for the credit application before setting up a company in our system - cannot tie these to a ES company id yet.
(Product announcement: https://updates.equipmentshare.com/release/jlBEr-new-credit-application-process-available-on-equipmentshare-website) 
{% enddocs %}

{% docs credit_application__unauthenticated_dot_com_app_id %}
Only populated if credit application came through the unauthenticated process. This is strictly for API use; does not tie to any Snowflake tables.
Unauthenticated apps (no ES company id associated): Need this ID to pull their dot com details from this API
Authenticated apps (has ES company id associated): Can pull details from the ES API using the ES company ID as a parameter
{% enddocs %}