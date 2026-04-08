DO $$
DECLARE
  table_name text;
BEGIN
  FOREACH table_name IN ARRAY ARRAY[
    '__app_migrations',
    'initiatives',
    'initiative_people',
    'initiative_links',
    'initiative_period_snapshots',
    'knowledge_documents',
    'initiative_annotations',
    'initiative_run_configs',
    'service_tokens',
    'user_api_tokens',
    'audit_events',
    'agent_query_logs',
    'legacy_contact_migration_runs',
    'source_import_batches',
    'source_import_rows',
    'slack_installations',
    'slack_workspace_sync_runs',
    'slack_workspace_channels',
    'slack_workspace_sync_issues',
    'slack_workspace_message_events',
    'slack_workspace_file_events',
    'google_installations',
    'pilot_batches',
    'portfolio_refresh_runs',
    'slack_sync_runs',
    'slack_message_events',
    'slack_reply_events',
    'slack_file_events',
    'google_sync_runs',
    'google_file_snapshots',
    'integration_sync_issues',
    'document_content_extracts',
    'google_revision_events',
    'tracker_parse_runs',
    'tracker_summary_fields',
    'tracker_row_items',
    'agent_runs',
    'kpi_research_runs',
    'kpi_findings',
    'agent_observations',
    'agent_observation_reviews',
    'agent_evidence_refs',
    'initiative_status_history'
  ]
  LOOP
    IF to_regclass(format('public.%I', table_name)) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', table_name);
    END IF;
  END LOOP;
END $$;
