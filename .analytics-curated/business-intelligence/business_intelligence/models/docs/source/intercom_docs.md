{% docs intercom__conversation_id %} 
This is Intercom's conversation id.
{% enddocs %}

{% docs intercom__conversation_created_at %}
The time the conversation was created.
{% enddocs %}

{% docs intercom__conversation_updated_at %}
The last time the conversation was updated.
{% enddocs %}

{% docs intercom__conversation_open %}
Indicates whether a conversation is open (true) or closed (false).
{% enddocs %}

{% docs intercom__conversation_state %}
Conversation states are:
* ```open```
* ```closed```
* ```snooze```
{% enddocs %}

{% docs intercom__conversation_read %}
Indicates whether a conversation has been read.
{% enddocs %}

{% docs intercom__conversation_waiting_since %}
The last time a Contact responded to an Admin. In other words, the time a customer started 
 waiting for a response. Set to null if last reply is from an Admin.
{% enddocs %}

{% docs intercom__conversation_snoozed_until %}
If set this is the time in the future when this conversation will be marked as open. 
i.e. it will be in a snoozed state until this time.
{% enddocs %}

{% docs intercom__conversation_priority %}
If marked as priority, it will return priority or else not_priority.
* ```priority```
* ```not_priority```
{% enddocs %}

{% docs intercom__conversation_title %}
The title given to the conversation.
{% enddocs %}

{% docs intercom__conversation_source_type %}
Source refers to conversation part that started the conversation.
Source types are:
* ```conversation```
* ``` email```
* ```facebook```
* ```instagram```
* ```phone_call```
* ```phone_switch```
* ```push```
* ```sms```
* ```twitter```
* ```whatsapp```
{% enddocs %}

{% docs intercom__conversation_source_id %}
The id representing the message.
{% enddocs %}

{% docs intercom__conversation_source_delivered_as %}
The conversation's initiation type. Possible values are:
* ```customer_initiated```
* ```campaigns_initiated``` (legacy campaigns)
* ```operator_initiated``` (Custom bot)
* ```automated``` (Series and other outbounds with dynamic audience message)
* ```admin_initiated``` (fixed audience message, ticket initiated by an admin, group email)
{% enddocs %}

{% docs intercom__conversation_source_subject %}
Optional. The message subject.
For Twitter, this will show a generic message regarding why the subject is obscured.
{% enddocs %}

{% docs intercom__conversation_source_body %}
The message body, which may contain HTML. 
For Twitter, this will show a generic message regarding why the body is obscured.
{% enddocs %}

{% docs intercom__conversation_source_url %}
The URL where the conversation was started. 
For Twitter, Email, and Bots, this will be null.
{% enddocs %}

{% docs intercom__conversation_source_author_type %}
The source author is the one that initiated the conversation.
Source author types are:
* ```user```
* ```lead```
* ```admin```
* ```team```
{% enddocs %}

{% docs intercom__conversation_source_author_id %}
The source author is the one that initiated the conversation.
Id of the author.
{% enddocs %}

{% docs intercom__conversation_team_assignee_id %}
The id of the team assigned to the conversation. 
If it's not assigned to a team it will return null.
{% enddocs %}

{% docs intercom__conversation_first_contact_reply_type %}
Represents the first user's message.
For a contact initiated message, this represents the user's original message.
* ```conversation```
* ``` email```
* ```facebook```
* ```instagram```
* ```phone_call```
* ```phone_switch```
* ```push```
* ```sms```
* ```twitter```
* ```whatsapp```
{% enddocs %}

{% docs intercom__conversation_first_contact_reply_url %}
Represents the first user's message.
For a contact initiated message, this represents the user's original message.
{% enddocs %}

{% docs intercom__conversation_first_contact_reply_created_at %}
Represents the first user's message.
For a contact initiated message, this represents the user's original message.
{% enddocs %}

{% docs intercom__conversation_rating_remark %}
An optional field to add a remark to correspond to the number rating
{% enddocs %}

{% docs intercom__conversation_rating_created_at %}
The time the rating was requested in the conversation being rated.
{% enddocs %}

{% docs intercom__conversation_rating_teammate_id %}
The ID of the teammate who received the rating.
{% enddocs %}

{% docs intercom__conversation_rating_value %}
The rating, between 1 and 5, for the conversation.
{% enddocs %}

{% docs intercom__conversation_statistics_time_to_assignment %}
Duration until last assignment before first admin reply. In seconds.
{% enddocs %}

{% docs intercom__conversation_statistics_time_to_admin_reply %}
Duration until first admin reply. Subtracts out of business hours. In seconds.
{% enddocs %}

{% docs intercom__conversation_statistics_time_to_first_close %}
Duration until conversation was closed first time. 
Subtracts out of business hours. In seconds.
{% enddocs %}

{% docs intercom__conversation_statistics_time_to_last_close %}
Duration until conversation was closed last time. 
Subtracts out of business hours. In seconds.
{% enddocs %}

{% docs intercom__conversation_statistics_median_time_to_reply %}
Median based on all admin replies after a contact reply. 
Subtracts out of business hours. In seconds.
{% enddocs %}

{% docs intercom__conversation_statistics_first_contact_reply_at %}
Time of first text conversation part from a contact.
{% enddocs %}

{% docs intercom__conversation_statistics_first_assignment_at %}
Time of first assignment after first_contact_reply_at.
{% enddocs %}

{% docs intercom__conversation_statistics_first_admin_reply_at %}
Time of first admin reply after first_contact_reply_at.
{% enddocs %}

{% docs intercom__conversation_statistics_first_close_at %}
Time of first close after first_contact_reply_at.
{% enddocs %}

{% docs intercom__conversation_statistics_last_assignment_at %}
Time of last assignment after first_contact_reply_at.
{% enddocs %}

{% docs intercom__conversation_statistics_last_assignment_admin_reply_at %}
Time of first admin reply since most recent assignment.
{% enddocs %}

{% docs intercom__conversation_statistics_last_contact_reply_at %}
Time of the last conversation part from a contact.
{% enddocs %}

{% docs intercom__conversation_statistics_last_admin_reply_at %}
Time of the last conversation part from an admin.
{% enddocs %}

{% docs intercom__conversation_statistics_last_close_at %}
Time of the last conversation close.
{% enddocs %}

{% docs intercom__conversation_statistics_last_closed_by_id %}
The last admin who closed the conversation. Returns a reference to an Admin object.
{% enddocs %}

{% docs intercom__conversation_statistics_count_reopens %}
Number of reopens after first_contact_reply_at.
{% enddocs %}

{% docs intercom__conversation_statistics_count_assignments %}
Number of assignments after first_contact_reply_at.
{% enddocs %}

{% docs intercom__conversation_statistics_count_conversation_parts %}
Total number of conversation parts.
{% enddocs %}

{% docs intercom__conversation_admin_assignee_id %}
The id of the admin assigned to the conversation. 
If it's not assigned to an admin it will return null.
{% enddocs %}

{% docs intercom__conversation_custom_type %}
Custom conversation type field.
{% enddocs %}

{% docs intercom__conversation_custom_language %}
Custom language setting for the conversation.
{% enddocs %}

{% docs intercom__conversation_custom_workflow_preview %}
Indicates if this conversation is using the workflow preview feature.
{% enddocs %}

{% docs intercom__conversation_custom_created_by %}
Custom field indicating who created the conversation.
{% enddocs %}

{% docs intercom__conversation_custom_default_description_ %}
Default description field for the conversation.
{% enddocs %}

{% docs intercom__conversation_custom_ticket_category %}
Custom field for categorizing the conversation ticket.
{% enddocs %}

{% docs intercom__conversation_custom_screenshots %}
Custom field containing screenshots related to the conversation.
{% enddocs %}

{% docs intercom__conversation_custom_default_title_ %}
Default title field for the conversation.
{% enddocs %}

{% docs intercom__conversation_custom_description_of_problem_ %}
Custom field describing the problem reported in the conversation.
{% enddocs %}

{% docs intercom__conversation_custom_team %}
Custom field indicating which team is handling the conversation.
{% enddocs %}

{% docs intercom__conversation_custom_severity %}
Custom field indicating the severity level of the issue.
{% enddocs %}

{% docs intercom__conversation_custom_tracker_type %}
Custom field indicating the type of tracker related to the conversation.
{% enddocs %}

{% docs intercom__conversation_custom_asset_information_ %}
Custom field containing asset information related to the conversation.
{% enddocs %}

{% docs intercom__conversation_custom_camera_serial_ %}
Custom field containing camera serial number information.
{% enddocs %}

{% docs intercom__conversation_custom_tracker_serial_ %}
Custom field containing tracker serial number information.
{% enddocs %}

{% docs intercom__conversation_custom_tracker_camera_serial %}
Custom field containing tracker camera serial number information.
{% enddocs %}

{% docs intercom__conversation_custom_t_3_application %}
Custom field indicating the T3 application related to the conversation.
{% enddocs %}

{% docs intercom__conversation_custom_copilot_used %}
Custom field indicating whether copilot was used in the conversation.
{% enddocs %}

{% docs intercom__conversation_custom_screenshot %}
Custom field containing a single screenshot related to the conversation.
{% enddocs %}


{% docs intercom__conversation_ai_agent_rating %}
The customer satisfaction rating given to AI Agent, from 1-5.
{% enddocs %}

{% docs intercom__conversation_ai_agent_participated %}
Indicates whether the AI Agent participated in the conversation.
{% enddocs %}

{% docs intercom__conversation_ai_agent_source_title %}
The title of the source that triggered AI Agent involvement 
in the conversation. 
If this is essentials_plan_setup then it will return null.
{% enddocs %}

{% docs intercom__conversation_ai_agent_last_answer_type %}
The type of the last answer delivered by AI Agent. 
If no answer was delivered then this will return null. 
Answer types are:
* ```null```
* ```ai_answer```
* ```custom_answer```
{% enddocs %}

{% docs intercom__conversation_ai_agent_rating_remark %}
The customer satisfaction rating remark given to AI Agent.
{% enddocs %}

{% docs intercom__conversation_ai_agent_source_type %}
The type of the source that triggered AI Agent involvement in 
the conversation. Source types are:
* ```essentials_plan_setup```
* ```profile```
* ```workflow```
* ```workflow_preview```
* ```fin_preview```
{% enddocs %}

{% docs intercom__conversation_ai_agent_resolution_state %}
The resolution state of AI Agent. If no AI or custom answer 
has been delivered then this will return null. States are: 
* ```assumed_resolution```
* ```confirmed_resolution```
* ```routed_to_team```
* ```abandoned```
* ```null```
{% enddocs %}

{% docs intercom__conversation_custom_ai_answer_length %}
Custom field for AI answer length preference.
{% enddocs %}

{% docs intercom__conversation_custom_ai_tone_of_voice %}
Custom field for AI tone of voice preference.
{% enddocs %}

{% docs intercom__conversation_custom_fin_ai_agent_preview %}
Custom field indicating if Fin AI agent preview is enabled.
{% enddocs %}

{% docs intercom__conversation_custom_ai_pronoun_formality %}
Custom field for AI pronoun formality preference.
{% enddocs %}