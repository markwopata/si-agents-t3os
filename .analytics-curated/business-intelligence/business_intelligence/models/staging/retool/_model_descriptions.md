{% docs analytics__bi_ops__credit_app_master_retool %}
Credit Specialists enter data into the Retool app, which is stored in this table.
As of 2025, we enabled customers to be able to apply for credit applications on the retail website, which gets added into the table via scheduled Snowflake procedure.

The Retool app was implemented around April 2024, migrating from a legacy manual spreadsheet.
This lets us know if a company is approved to rent/buy on credit vs having to have cash on hand.
When companies are approved, it doesn't matter what market they technically applied for; approval in one should mean approval in all.
Details can be found in:
* https://www.notion.so/equipmentshare/Credit-Applications-f3ac3d74db6a4a0e8df321c7759a7b7f
* https://www.notion.so/equipmentshare/Credit-Application-Technical-Design-1933ad4a46228097bd60d92be445d352#19d3ad4a462280bc8327e5cd7f4dd071

Starting ~September 2025, companies can submit credit applications before setting up a company account in our system. Those are marked with `initial_web_unauthenticated = true`.

## Data Update Patterns

**Manual Updates (Retool)**: When credit specialists make edits to an application in Retool, a new record is **inserted** with a new `date_created` value.

**Automated Updates (Stored Procedure)**: The table has a nightly process `UPDATE_CREDIT_APP_MASTER_RETOOL_PROC()` that runs before midnight Central Time:
1. **INSERTs** new companies into the table with different defaults based on their signup type:
   - **Web self-signup accounts (not approved for credit)**:
     -  Sets `source = 'Web'`, `app_status = 'COD Web'`, `notes = 'Automated record'`, `initial_web_self_signup = TRUE`
     - NO salesperson, market, or credit specialist assigned (all NULL)
     - These automated records represent unactioned applications
     - When credit specialists later assign a rep/market via Retool, a new record is inserted with those values
   - **Non-self-signup accounts (or self-signup accounts already approved)**: Only sets `initial_web_self_signup = FALSE`, all other fields are NULL
     - Creates a placeholder record for companies not yet in the system
2. **UPDATEs** records from yesterday that have not been touched by credit specialists (`app_status IS NULL`), setting their status based on the company's current `net_terms_id`:
   - If `net_terms_id = 1` (COD): Sets `source = 'Branch'`, `app_status = 'COD Branch'`, `notes = 'Automated record'`
   - If `net_terms_id <> 1` (Credit approved): Sets `source = 'System'`, `app_status = 'Approved'`, `notes = 'Automated record'`
   - Sets `date_completed = date_received` (yesterday's date)

This mixed INSERT/UPDATE pattern means the table is **mostly append-only**, except for automated records in their first day that haven't yet been reviewed by credit specialists.

There can be multiple company applications - ex: company forgot they have credit with us and reapplied.
{% enddocs %}

{% docs stg_retool__credit_app_master_retool %}
Staging model for credit application master data from Retool. Light tranformations include parsing salesperson / credit specialist fields and basic data cleansing.
{% enddocs %}