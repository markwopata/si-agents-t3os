{% docs dds_read_timestamp %}
Datetime this row was read by Sage Intacct's DDS (Data Delivery Service).
{% enddocs %}

{% docs fk_subledger_header_id %}
Foreign key to base intacct object header table (e.g. po header). Coalesced the 2 header keys available
because only 1 of them is non null at a time.
{% enddocs %}

{% docs fk_subledger_line_id %}
Foreign key to base intacct object line table (e.g. po line). Coalesced the 2 line keys available because
only 1 of them is non null at a time. Should join using this AND module key because multiple base tables
may have the same numeric key.
{% enddocs %}

{% docs customer_id %}
ID for customer or company. This is varchar because there are customers starting with C- used for rebates that
are not in admin/T3. customer_id = admin company_id
{% enddocs %}

{% docs customer_name %}
Name of customer. Should be similar to admin company name, but not guaranteed to be same.
{% enddocs %}

{% docs vendor_id %}
ID for vendor. This is varchar and looks like V<number>.
{% enddocs %}

{% docs vendor_name %}
Name of vendor.
{% enddocs %}

{% docs fk_intacct_user_id %}
Foreign key to Intacct user table
{% enddocs %}

{% docs is_statistical %}
Bool that identifies if the entry is a statistical entry. Statistical entries are entries that don't add to
the general ledger - typically non-ledger metrics.
{% enddocs %}

{% docs entry_state %}
State of the entry - Posted, Draft, Declined, etc. Only Posted is relevant for end financial reporting.
{% enddocs %}

{% docs journal_state %}
State of the journal - Posted, Draft, Declined, etc. Only Posted is relevant for end financial reporting. This can be
different from entry state, most likely because of sync timing or other DDS issues
{% enddocs %}

{% docs combined_state %}
This is posted if either entry or journal are posted, otherwise uses entry state. There are a few instances
where gle.state != glb.state, probably due to DDS not syncing one of the objects over or updating one of
the docs.
{% enddocs %}

{% docs gl_dim_transaction_identifier %}
User keyed in value - additional descriptor for this GL entry line. Sage additional dimension
{% enddocs %}

{% docs gl_dim_asset_id %}
User keyed in asset id. Sage dimension
{% enddocs %}

{% docs fk_account_id %}
Foreign key to GL account table
{% enddocs %}

{% docs account_number %}
GL account number, 4 digit number as a varchar
{% enddocs %}

{% docs account_name %}
GL account name
{% enddocs %}

{% docs account_normal_balance %}
Identifies whether the GL account normally holds a debit or credit balance.
{% enddocs %}

{% docs account_type %}
Type of GL account: incomestatement or balancesheet
{% enddocs %}

{% docs fk_entity_id %}
Foreign numeric key to Intacct entity table (entity also called location in some spots)
{% enddocs %}

{% docs entity_id %}
Actual entity id, looks like E1. Named 'location' in some spots of Sage, but known as entity.
{% enddocs %}

{% docs entity_name %}
Name of entity
{% enddocs %}

{% docs extended_entity_name %}
Extended or descriptive name of entity. Name used while printing.
{% enddocs %}

{% docs fk_department_id %}
Foreign numeric key to Intacct department table
{% enddocs %}

{% docs department_id %}
Actual department id. This needs to be a string because it includes things like CORP1. This is mainly market_ids but it
can also contain our corporate sub department ids (e.g. 1000019). This can be null.
{% enddocs %}

{% docs department_name %}
Name of department (or sub-department or market).
{% enddocs %}

{% docs fk_expense_type_id %}
Foreign numeric key to Intacct expense_type table. Currently known as expense line, expect this to change.
{% enddocs %}

{% docs expense_type %}
Name of expense type. Currently known as expense line, expect this to change.
{% enddocs %}

{% docs expense_category %}
Higher level categorization of each expense type
{% enddocs %}

{% docs fk_journal_id %}
Foreign key to intacct journal table. Journal = batch
{% enddocs %}

{% docs journal_title %}
The title of the journal. Journal = batch
{% enddocs %}

{% docs url_journal %}
Link to Sage front end for the journal. May be null
{% enddocs %}

{% docs debit_credit %}
Column identifying if the line is a debit or credit
{% enddocs %}

{% docs debit_credit_sign %}
Sign (1 or -1) representing a debit or credit
{% enddocs %}

{% docs fk_ud_loan_id %}
Numeric id for user defined loan dimension.
{% enddocs %}

{% docs gle_raw_amount %}
Raw positive amount (no signs applied)
{% enddocs %}

{% docs gle_raw_amount_w_sl %}
Raw positive amount (no signs applied), with subledger raw_amount coalesced in.
{% enddocs %}

{% docs gle_net_amount %}
Purely debit minus credit
{% enddocs %}

{% docs gle_net_amount_w_sl %}
Purely debit minus credit, with subledger net_amount coalesced in
{% enddocs %}

{% docs gle_amount %}
Opinionated application of signs to raw amount for end financial reporting. For P&L, this is positive revenues, negative
expenses. For balance sheet accounts, assets are positive and liabilities/equities are negative.
{% enddocs %}

{% docs gle_amount_w_sl %}
Opinionated application of signs to raw amount for end financial reporting. For P&L, this is positive revenues, negative
expenses. For balance sheet accounts, assets are positive and liabilities/equities are negative. Coalesces subledger 
amount in.
{% enddocs %}

{% docs gle_applied_sign %}
Applied sign is a combination of all signs being applied to raw_amount
{% enddocs %}

{% docs positive_revenue_sign %}
Apply -1 sign to net_amount so revenues are positive.
{% enddocs %}

{% docs currency_code %}
The currency code is a three-letter code that uniquely identifies a specific currency. This is the transaction's
currency code
{% enddocs %}

{% docs base_currency_code %}
Book's default currency code - if different from currency code, Sage will convert to base currency
{% enddocs %}

{% docs exchange_rate_date %}
Date used for applying exchange rate
{% enddocs %}

{% docs ud_t3_work_order_number %}
User defined dimension for T3 work order number. Used rarely at time of model implementation.
{% enddocs %}

{% docs ud_admin_invoice_number %}
User defined dimension for admin invoice number.
{% enddocs %}

{% docs journal_type %}
Journal type, short-code form e.g. APA, GJ
{% enddocs %}

{% docs extended_journal_type %}
Full descriptive name of journal type
{% enddocs %}

{% docs fk_gl_entry_id %}
Foreign key to gl_entry table
{% enddocs %}

{% docs fk_gl_resolve_id %}
Foreign key to gl_resolve table which is the subledger linkage table.
{% enddocs %}

{% docs fk_reversed_from_journal_id %}
Foreign key to fk_journal_id. Points to journal this entry was reversed from
{% enddocs %}

{% docs date_reversed %}
Date the journal was reversed. If populated, this journal is reversed from another journal
{% enddocs %}

{% docs intacct_module %}
Code that identifies the Intacct Module that generated this entry or transaction. Examples 3.AP, 2.GL
{% enddocs %}

{% docs journal_transaction_number %}
Unique transaction number that identifies a journal. This number is unique when combined with journal type. AKA batch
number, but transaction number in Sage front end.
{% enddocs %}

{% docs entry_description %}
The description on each line of GL entry. AKA memo on the front end
{% enddocs %}

{% docs exchange_rate %}
Currency exchange rate to convert currency to base currency
{% enddocs %}

{% docs gle_document %}
User keyed in a document number. Could be anything depending on user.
{% enddocs %}

{% docs trx_amount %}
Same as amount but in the entry line's original currency
{% enddocs %}

{% docs net_trx_amount %}
Same as net_amount but in the entry line's original currency
{% enddocs %}

{% docs raw_trx_amount %}
Same as raw_amount but in the entry line's original currency
{% enddocs %}

{% docs gle_line_number %}
Line number of the entry line within a journal
{% enddocs %}

{% docs entry_date %}
Line number of the entry line within a journal
{% enddocs %}

{% docs entry_amount %}
Same as amount - applies opinionated signs to raw amount. Keeps track of original gl entry amount. Summing on this directly will get have unexpected results. 
{% enddocs %}

{% docs net_entry_amount %}
Same as net_amount but tracking original entry's amount
{% enddocs %}

{% docs raw_entry_amount %}
Same as raw_amount but tracking original entry's amount
{% enddocs %}

{% docs balance_sheet_sign %}
Apply -1 to amount if account normal balance is debit for balance sheet accounts
{% enddocs %}
