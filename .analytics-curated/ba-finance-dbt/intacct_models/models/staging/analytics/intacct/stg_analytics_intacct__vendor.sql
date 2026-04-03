with source as (
    select * from {{ source('analytics_intacct', 'vendor') }}
),

renamed as (
    select
        -- ids 
        recordno as pk_vendor_id,
        vendorid as vendor_id,
        parent_vendor,
        termskey as fk_terms_id,
        createdby as fk_created_by_user_id,
        modifiedby as fk_updated_by_user_id,
        vendor_redirect,
        displaycontactkey as display_contact_key,
        paytokey as pay_to_key,
        returntokey as return_to_key,
        ft_fleet_track_id,
        paymethodrec as pay_method_record_no,
        taxid as tax_id,
        vendor_portal_id,

        -- strings
        name as vendor_name,
        company_name_dba,
        vendtype as vendor_type,
        termname as vendor_term,
        status as vendor_status,
        vendor_category,
        company_legal_name,
        name1099 as name_1099,
        comments,
        form1099type as form_1099_type,
        form1099box as form_1099_box,
        billingtype as billing_type,
        achbankroutingnumber as ach_routing_number,
        achaccountnumber as ach_account_number,
        achaccounttype as ach_account_type,
        achremittancetype as ach_remittance_type,
        filepaymentservice as file_payment_service,
        megaentityname as mega_entity_name,
        ud_foreign_tin as foreign_tax_id,
        ud_vendor_esemailnotify,
        diversity_classification,
        alt_pay_method,
        coi_url,
        external_sync_override,
        epay_interest,
        organization_type,
        ft_book_of_business,
        ft_category,
        ft_core_designation,
        ft_financing_designation,
        prenote_account,
        prenote_routing,
        commodity,
        non_inventory,
        approved_entities,
        new_vendor_category,
        vendor_sub_category,

        -- booleans
        case
            when reporting_category = 'Related Party' then TRUE
            else FALSE
        end as is_related_party,
        displaytermdiscount as display_term_discount,
        onetime as one_time,
        isowner as is_owner,
        onhold as on_hold,
        donotcutcheck as do_not_cut_check,
        achenabled as ach_enabled,
        wireenabled as wire_enabled,
        checkenabled as check_enabled,
        paymentnotify as payment_notify,
        displocacctnocheck as disp_loc_acct_no_check,
        mergepaymentreq as merge_payment_req,
        isindividual as is_individual,
        requires_coi,
        prevent_new_poe_in_sage,
        excl_from_ext,

        -- timestamps
        whencreated as date_created,
        whenmodified as date_updated,
        _es_update_timestamp,
        ddsreadtime as dds_read_timestamp,

        -- dates
        earliest_coi_expiration_date,
        msa_valid_through,

        -- numerics
        creditlimit as credit_limit,
        totaldue as total_due,
        alt_pay_due_date_deduction

    from source
)

select * from renamed