<!-- START OF CUSTOM PROPERTIES  -->

{% docs heap__user_company_timezone %} 
This represents the timezone in which the user's company
operates and can be used to understand the geographical location and
working hours of the company.
{% enddocs %}

{% docs heap__mimic_user %}
This indicates whether the user is making updates on
behalf of another user. This is usually done by customer service.
{% enddocs %}

{% docs heap__user_created_at %}
This is the date when the user account was created. 
It was originally stored as a string in the format 'MON DD, YYYY'
but converted into DATE data type.
{% enddocs %}

{% docs heap__company_name %}
This contains the name of the company that the user is associated with.
{% enddocs %}

{% docs heap__company_id %}
This is EquipmentShare's company id and ties to ESDB.
{% enddocs %}

{% docs heap__user_timezone %}
This field represents the timezone in which the user is located. It
is a string data type and can be used to understand the user's
geographical location and schedule communications accordingly.
{% enddocs %}

{% docs heap__user_name %}
This field represents the full name of the user. It is a string
data type and can be used for personalizing communications or
identifying the user.
{% enddocs %}

{% docs heap__user_cohort %}
This field represents the timestamp of when the user was grouped
into a specific cohort. Cohorts are often used in business analysis to
group users who share common characteristics within a defined
time-span. This information can be useful for understanding user
behavior, segmentation, and trend analysis.
{% enddocs %}


{% docs heap__app_type %}
Custom property for app type.  
Values are: 
- Desktop Web
- Mobile App
- Mobile Web
- Mobile App WebView
{% enddocs %}


{% docs heap__browser_type %}
Custom property for web browser.  
Values are: 
- Chrome
- Edge
- Facebook
- Firefox
- Internet Explorer
- Opera
- Other Browser
- Safari
- Samsung Internet
{% enddocs %}

{% docs heap__platform_type %}
Custom property for platform type.  
Values are: 
- null
- Android
- iOS
{% enddocs %}

{% docs heap__platform_type_os %}
Custom property for platform type operating system.
{% enddocs %}

<!-- END OF CUSTOM PROPERTIES -->


<!-- START OF BUILT-IN PROPERTIES  -->

{% docs heap__user_id %} 
Heap's randomly generated unique ID for an associated user.
If Heap identifies the user, Heap will consolidate the user and all events 
tied to that user into one behind-the-scenes, and that 
migration history is stored in the USER_MIGRATIONS table.
{% enddocs %}

{% docs heap__user_join_date %} 
Timestamp without time zone of when the user was first seen in Heap.
{% enddocs %}

{% docs heap__user_last_modified %} 
Per Heap support, this timestamp represents the last time 
tihs user called the userProperties API. Note: The record updates any time
the API is called, regardless of whether a property is actually changed.
{% enddocs %}

{% docs heap__user_identity %} 
User’s username or other unique token, passed via 
heap.identify API. Must be unique.
{% enddocs %}

{% docs heap__user_handle %} 
User’s username or other unique token, passed in via 
heap.addUserProperties API.
{% enddocs %}

{% docs heap__user_email %} 
User’s email address, passed in via heap.addUserProperties API.
{% enddocs %}

{% docs heap__event_id %} 
Heap's randomly generated unique ID for an associated event.
{% enddocs %}

{% docs heap__timestamp %}
Timestamp without timezone for when the respective table's event happened.
This was renamed from the source from 'time' to '[associated_table]_time'.
{% enddocs %}

{% docs heap__session_id %}
Heap's randomly generated unique ID for an associated session.
{% enddocs %}

{% docs heap__event_table_name %}
Table name given to the event when synced to Snowflake.
{% enddocs %}

{% docs heap__library %}
Version of Heap library on which event occurred. Can be one of “web”, “iOS”, or “server”.
{% enddocs %}

{% docs heap__platform %}
User’s operating system and version.  
Only applies to web and iOS.
{% enddocs %}

{% docs heap__device_type %}
Device type, which can be one of “Mobile”, “Tablet”, or “Desktop”.  
Only applies to web and iOS.
{% enddocs %}

{% docs heap__country %}
Country in which user session occurred, based on IP.  
Only applies to web and iOS.
{% enddocs %}

{% docs heap__region %}
Region in which user session occurred, based on IP.  
Only applies to web and iOS.
{% enddocs %}

{% docs heap__city %}
City in which user session occurred, based on IP.  
Only applies to web and iOS.
{% enddocs %}

{% docs heap__ip %}
The IP address for the session, which is used for determining geolocation.  
Only applies to web and iOS.
{% enddocs %}

{% docs heap__referrer %}
URL that linked to your site and started the session.
If the user navigated directly to your site, or referral headers were stripped, 
then this value will appear as NULL downstream and as 'direct' in Heap's UI.  
Only applies to web.
{% enddocs %}

{% docs heap__landing_page %}
URL of the first pageview of the session.  
Only applies to web.
{% enddocs %}

{% docs heap__landing_page_query %}
The query parameters of the first page of the user’s session.  
Only applies to web.
{% enddocs %}

{% docs heap__landing_page_hash %}
The hash route of the first page of the user’s session.  
Only applies to web.
{% enddocs %}

{% docs heap__browser %}
User’s browser + browser version.  
Only applies to web.
{% enddocs %}

{% docs heap__search_keyword %}
Search term that brought the user to your site. [Deprecated]. 
Only applies to web.
{% enddocs %}

{% docs heap__utm_source %}
GA-based utm_source tag associated with the session’s initial pageview.  
Only applies to web.
{% enddocs %}

{% docs heap__utm_campaign %}
GA-based utm_campaign tag associated with the session’s initial pageview.  
Only applies to web.
{% enddocs %}

{% docs heap__utm_medium %}
GA-based utm_medium tag associated with the session’s initial pageview.  
Only applies to web.
{% enddocs %}

{% docs heap__utm_term %}
GA-based utm_term tag associated with the session’s initial pageview.  
Only applies to web.
{% enddocs %}

{% docs heap__utm_content %}
GA-based utm_content tag associated with the session’s initial pageview.  
Only applies to web.
{% enddocs %}


{% docs heap__domain %}
Domain including subdomain, e.g. blog.heap.io
{% enddocs %}

{% docs heap__pageview_path %}
The path of the pageview.  
Only applies to web.
{% enddocs %}

{% docs heap__pageview_query %}
The query parameters associated with the pageview.  
Only applies to web.
{% enddocs %}

{% docs heap__pageview_hash %}
The query parameters associated with the pageview.  
Only applies to web.
{% enddocs %}

{% docs heap__pageview_title %}
Title of the current page.  
Only applies to web.
{% enddocs %}

{% docs heap__previous_page %}
The previous page visited in this session.  
Only applies to web.
{% enddocs %}

<!--        MOBILE-RELATED DATA         -->
{% docs heap__device_carrier %}
User’s Android or iOS mobile carrier, if available.
{% enddocs %}

{% docs heap__app_name %}
Current name of Android or iOS app. 
iOS app name is determined by CFBundleName.
{% enddocs %}

{% docs heap__app_version %}
Current version of Android or iOS app.
iOS version is determined by CFBundleShortVersionString.
{% enddocs %}

{% docs heap__device_model %}
User’s Android or iOS model.
{% enddocs %}

{% docs heap__device_model_legacy %}
The same as device.
Heap customer support said customers requested the field to be 
improved to make it more noticeable they were specifically Heap fields.

For some reason, heap_device is not populated but device is, so this is
the opposite of app_name vs heap_app_name and app_version vs heap_app_version
{% enddocs %}

{% docs heap__app_name_legacy %}
The same as heap_app_name.
Heap customer support said customers requested the field to be 
improved to make it more noticeable they were specifically Heap fields.
This field was kept for legacy / older versions of the Heap SDK.
{% enddocs %}

{% docs heap__app_version_legacy %}
The same as heap_app_version.
Heap customer support said customers requested the field to be 
improved to make it more noticeable they were specifically Heap fields.
This field was kept for legacy / older versions of the Heap SDK.
{% enddocs %}

<!--        iOS-SPECIFIC DATA         -->

{% docs heap__iOS_view_controller %}
Name of the iOS current view controller.
{% enddocs %}

{% docs heap__iOS_screen_a11y_id %}
accessibilityIdentifier for the current iOS view controller.
{% enddocs %}

{% docs heap__iOS_screen_a11y_label %}
accessibilityLabel for the current iOS view controller.
{% enddocs %}

{% docs heap__iOS_screen_target_a11y_label %}
accessibilityLabel of an iOS action’s target.
{% enddocs %}



<!--        INTERCOM         -->
<!-- https://help.heap.io/integrations/customer-success-integrations/intercom/ -->
{% docs heap__intercom_event_type %}
Event types from Intercom:
* Start Inbound Conversation
* Reply to Conversation
* Conversation was Closed
* Rate Conversation
{% enddocs %}

{% docs heap__intercom_assigned_admin_email %}
The email of the last admin assigned to the conversation.
{% enddocs %}

{% docs heap__intercom_first_message_delivered_as %}
How the first message was delivered by Intercom. 
* customer_initiated
* automated
* campaigns_initiated
* admin_initiated
* operator_initiated
{% enddocs %}

{% docs heap__intercom_first_message_type %}
The type of message that started the conversation.
* conversation
* push
* facebook
* twitter
* email
{% enddocs %}

{% docs heap__intercom_conversation_id %}
The Intercom ID representing the conversation.
{% enddocs %}

{% docs heap__intercom_first_message_author_email %}
The email of the individual that started the conversation 
(only applicable to admins).
{% enddocs %}

{% docs heap__intercom_first_message_author_type %}
The type of individual that started the conversation.
* user
* lead 
* admin
* team
* bot
{% enddocs %}

{% docs heap__intercom_num_conversation_parts %}
The number of parts to the conversation, as described in Intercom’s 
developer documentation. 
Per deveoper documentation: The maximum number of conversation parts 
that can be returned via the API is 500.
{% enddocs %}

{% docs heap__intercom_url %}
The URL where the user’s first message occurred.
{% enddocs %}

{% docs heap__intercom_conversation_rating %}
The rating, between 1 and 5, for the conversation.
{% enddocs %}

{% docs heap__intercom_session_id %}
From Heap support: Intercom is a server side integration so the 
session_ids are meaningless here since session_ids are a client-side
attribute.
{% enddocs %}