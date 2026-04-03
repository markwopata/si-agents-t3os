select
    md5(dm.disc_code || '-' || dm.email_address) as pk_disc_master_id,
    dm.disc_code,
    dm.email_address,
    dm.disc_sent_date::date as disc_sent_date,
    dm.completed_date::date as completed_date,
    dm.environment_style,
    dm.basic_style,
    dm.blend,
    dm.main_strength,
    dm.applicant,
    dm.status,
    dm.updated_date::date as updated_date,
    'http://www.discoveryreport.com/v/' || dm.disc_code as url_disc
from {{ source('analytics_public', 'disc_master') }} as dm
