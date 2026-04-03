### Live Branch Earnings Models

#### Sales Cogs Credits
##### Model: int_live_branch_earnings_sales_cogs_credits

Invoices and credits come through revenue accounts

When an invoice has an asset is sale on it (one of the sales line item types), and a credit is originated from that sales invoice:
If the credit amount is greater than or equal to the total amount of the invoice, then the Cost of Goods Sold (COGS) is fully credited (i.e., the entire COGS amount related to the invoice is reversed). Otherwise, no action

### Live Branch Earnings
AR invoices
	- Non-Sales Revenue/credits
		- Join through arrecord or no?
		- Pass through non-sales cleanly
		- Reclass split on line item types
	- LSD - just include above? It’s disconnected from the cogs
	- Sales go to sales labeled accounts
		-  Cogs if there is sale
	- sales credits clean
		- Cogs - find originating invoice in past (snap or live)
	- COGS LSD
		- Asset company transfer to an LSD company
		
- AP/receipts/variance (3.AP, 9.PO, or APA_TRUE_UP)
	- Receipt & Closed PO - post to account
	- AP post if no receipt (but this is just 3.AP to relevant account)
	- apa_true_up -> variance and pull in invoice/receipt detail
	- How to check:
		- All 3 of above should be separable sections - may be some difficulty in the BE side
			- Variance is labeled
			- Bill should have a concur link
			- Otherwise receipt? (Costcapture link)
- Credit card transactions
	- Citi/amex
		- pull from cc table, use mcc to pick account
		- Get company directory employee EOM
		- For region/district/national, allocate out
		- How to check:
			- Compare citi total vs cc_fuel_and_spend_all total for month
			- Compare amex total vs cc_and_fuel_spend
				- But there is a misc account for AMEX done separately (Willy). We do not have AMEX data in table for this
		- Gotchas:
			- We are doing something manual to remove telematics employees in BE (Brody)
			- Allocating incorrectly? (There appeared to be some incorrect or missed allocations from 99999X departments)
			- Manual reclasses to other departments or accounts done in Excel (cc_and_fuel_spend_all would not reflect)
			- Any period mismatches? E.g. credit card statement crosses periods but we should theoretically be accruing all transactions to the month they were incurred - just a potential difference in how data looks on the GL side.
	- Fuel
		- (No mcc)
		- Use employee id to account hack through history on gl detail, using transaction id to credit card table
		- Else default to an account
			- Gotcha: this will cause some diff, but total should line up
		- Location: For region/district/national, allocate out
- Profit sharing
	- Cannot check - exclude from analysis because LBE vs BE method are different. LBE is a dummy % on NI.
	- Shows up in multiple payroll accounts (Admin, Equipment Rental, Maintenance)
- Payroll tax? --- MISSING
	- Should be a % of payroll estimate
	- How to check:
		- Compare vs expected or GL
	- Gotchas:
		- Will not match exactly because accruals for payroll tax are either not done or not done correctly in the GL
		- In the GL, there is no separation of different employee types' payroll tax (e.g. payroll tax includes telematics employees), but LBE (and BE) exclude the telematics payroll account. Our % estimate will be slightly off by this.
- Payroll (Exclude profit sharing)
	- LBE Method: Estimate of hours/wages live from PA team
	- How to check:
		- Day 1-30: buildup from PA's estimates, no inclusion of reversal
		- After payroll posted in GL: exact match to GL
- Corporate Allocation
	- Basis: market's tier + some minor rules. Correlates to # of markets
		- Make sure corp allocation is parent only
			- Is this a gotcha? Method correct in BE?
	- Gotchas: if we back date a market's start date, BE may not have had the corp allocation for the month. This is rare, but it happened for April - 7+ markets.
- Health insurance
	- Basis: # of employees at EOM times flat rate
		- Should not change ever because we don't update back in time EOM
	- How to check:
		- It should match Expected exactly on the account total
- Work comp insurance
	- Straight from premium table
	- How to check:
		- Exact match to BE account, make sure markets are filtered appropriately
	- Gotcha:
		- Timing - if we update rates LBE will show a diff. We don't update very often and it needs to happen before we release May
- Auto insurance
	- Pretty much the same as above, different premium table
- Other Insurance
	- Repeating entry
	- How to check: use previous month's BE
- Repeating Entries
	- Includes:
		- HGAD - Building rent
			- should not change MoM -> use last
		- HIAB - Personal Property Tax
			- Not supposed to change drastically, but this is not actually correct - we should % to OEC
- Real property tax (HIAC)
	- Basis: real property tax sheet
		- Should not change very often (yearly)
	- How to check: should match expected on account
- Depreciation (non-asset)
	- Repeating entries
	- (MoM changes should be minor/close enough -> use repeating)
	- How to check:
		- Should match prior month BE
- Part Transactions (GDDA, GDDAA, GDDAB)
	- Use pit table - WAC times quantity
	- Split on some things used to identify line item type id/wo billing/transaction type id
	- drop telematics vans
	- make sure types and adjustment reasons match BE
	- How to check:
		- compare vs
	- Gotchas:
		- null WAC is coalescing in cost
			- shouldn't cause large differences though because everything is supposed to have a WAC
		- (small possible) WAC can be back dated, but there's supposed to be a limit based on closed date. Theory - BE's basis shouldn't change
		- Manual adjustments out (Branch requests credit for some part transaction) (edited) 