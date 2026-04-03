{% docs heap__all_events %}
`all_events` table is not listed in the `_sync_info` table. 
The `all_events` table records every table that is synced to Snowflake. This is the only table that is being fully refreshed daily.
{% enddocs %}

{% docs heap__sync_info %}
This table matches Heap's _SYNC_INFO table. 
`all_events` and `user_migrations` table are synced separately and does not leverage this.

Note: Heap support confirmed that this table can sometimes have duplicates. The syncs for the tables can have issues, so when that occurs, the process retries the sync, which ends up creating duplicate line items.
{% enddocs %}

{% docs heap__pageviews %}
Pageviews are collected when a user changes from webpage to webpage.
{% enddocs %}

{% docs heap__sessions %}
A session in Heap is a period of activity from a single user in your app or website. It can include many pageviews or events.
On web, a session ends after 30 minutes of pageview inactivity from the user.
On mobile, a session ends after 5 minutes of inactivity, regardless of whether the app’s background or foreground state.

Note: Server-side sessions do not appear in this table. It appears in the users view-in app, and data for server-side events are synced in the all_events and event tables. Heap Support confirmed that any server-side and integration-generated events will not be found here.
Example is the Intercom integration - Intercom event tables will have session ids but those session ids will not be in the sessions table.
{% enddocs %}

{% docs heap__user_migrations %}
Heap manages migrations internally and delivers us this data source to have visibility into the migrations that occur behind-the-scenes. Support confirmed they drop the table on every sync and re-sync it completely.

The incremental parameter ensures that if a user that was already migrated but  was part of another migration, it'll capture the updated to_user_id to stay in sync with the source.
{% enddocs %}

{% docs heap__users %}
Details about Heap users.
{% enddocs %}

<!------------------------ T3 -------------------->
{% docs heap__t3_analytics_any_event_click_any %}
Event table tracking any event click in the T3 Analytics application.
{% enddocs %}

<!------------------------ INTERCOM -------------------->

{% docs heap__intercom_events_conversation_was_closed %}
A user’s conversation in the Intercom messenger was closed by an admin.
{% enddocs %}

{% docs heap__intercom_events_rate_conversation %}
A user rated the conversation on a scale from 1 to 5.
{% enddocs %}

{% docs heap__intercom_events_start_inbound_conversation %}
A user starts a conversation in the Intercom messenger.
{% enddocs %}