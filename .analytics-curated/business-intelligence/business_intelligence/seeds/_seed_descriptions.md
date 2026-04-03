{% docs seed_companies__employees %} 
This is a manually managed file listing companies that have @equipmentshare.com or 'employee'. Generally, employees haven't really behaved like customers, which is why we may want to isolate and exclude them from certain analyses.
{% enddocs %}

{% docs seed_companies__es_internal %} 
This is a manually managed file listing companies that seem to be owned by EquipmentShare and likely are not real customers.
There may be some overlap with `analytics.public.es_companies` that needs to be evaluated.
{% enddocs %}

{% docs seed_companies__manual_merge_mapping %} 
This is a manually managed file listing companies that were identified by Sara Jacobi. The manual mapping are for outliers that we know should be mapped to each other but do not follow the naming convention of something like "use account [number]" or "merged-to-[number]".
{% enddocs %}

{% docs seed_companies__misc %} 
This is a manually managed file listing companies that Sara Jacobi had originally flagged into demo/test companies.
These are a miscellaneous list that can probably be further classified. They tend to have 'deleted' or 'do not' in 
their naming patterns.
{% enddocs %}

{% docs seed_companies__prospect %} 
This is a manually managed file listing companies that have 'Prospect' in their name. 
These seem to have been set up for national accounts that have been "preapproved" to speed through the onboarding customer process so we can start renting to them ASAP. If they get converted, 'Prospect' may get removed from the naming.
{% enddocs %}

{% docs seed_companies__spam %} 
This is a manually managed file listing companies that have foreign characters in the company name or has 'qq.com'. 
These seem like companies that we can safely flag as spam.
{% enddocs %}

{% docs seed_companies__test %} 
This is a manually managed file listing companies that generally have 'demo' or 'test' in their name or they're confirmed 
to be test accounts created by the system / development / testing.
{% enddocs %}

{% docs seed_companies__use_account_merge_mapping %} 
This is a manually managed file listing companies that have variations of 'use account [number]' or 'use acct [number]' or 'use [number]' in their names. Since the variations are inconsistent, maintaining a manual file and creating a process to review seems to provide better control.
{% enddocs %}

{% docs seed_companies__use_counter_account %} 
This is a manually managed file listing companies that explicitly say to use the counter account, which is company_id = 1000.
{% enddocs %}

{% docs seed_companies__vip %} 
This is a manually managed file listing companies that are identified as vip companies. These contain both companies that were once vip and are no longer vip as well as current vip, via `is_current_vip` flag in the file.
{% enddocs %}

{% docs seed_companies__duplicate %} 
This is a manually managed file listing companies that have 'duplicate' in their name but are not mapped to a different 
company.
{% enddocs %}

{% docs seed_companies__flag_exclusions %} 
Companies are flagged by their name through a Monte Carlo alert.
This file contains companies that should be excluded from the flagging and are validated to be legitimate businesses that should not be flagged.
This provides the company id, company name, and reason it would get flagged:
  - "test account" - has 'test' or 'demo' in the name
  - "employee" - has 'employee' in the name
  - "do not" - has 'do not' in he name
  - "do_not_rent should be true" - Companies where the DNR flag should be true
  - "spam" - has foreign characters or spam patterns
  - "use_account" - has 'use' and a numeric value
  - "merge" - has 'merge' in the name
  - "internal equipmentshare" - has 'equipmentshare' or 'es' (as a standalone word) in the name
{% enddocs %}