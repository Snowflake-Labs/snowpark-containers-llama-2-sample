-- FOLLOW THE consumer_setup.sql TO SET UP THE TEST ON THE PROVIDER
USE ROLE nac;
USE WAREHOUSE wh_nac;

DROP APPLICATION IF EXISTS llama2_app;
CREATE APPLICATION llama2_app FROM APPLICATION PACKAGE llama2_pkg USING VERSION v1;
GRANT USAGE ON COMPUTE POOL gpu_3 TO APPLICATION llama2_app;
GRANT USAGE ON WAREHOUSE wh_nac TO APPLICATION llama2_app;
GRANT USAGE ON DATABASE llama2_consumer TO APPLICATION llama2_app;
GRANT USAGE ON SCHEMA llama2_consumer.data TO APPLICATION llama2_app;
GRANT SELECT ON TABLE llama2_consumer.data.customer_support_transcripts TO APPLICATION llama2_app;

CALL llama2_app.app_public.start_app('GPU_3','WH_NAC', 'LLAMA2_CONSUMER.DATA.CUSTOMER_SUPPORT_TRANSCRIPTS');
CALL llama2_app.app_public.app_url();
-- Please wait a few minutes for the LLM to download the model and set up.
--   This is slow on first run, but we save the model for subsequent starts of the app.
CALL llama2_app.app_public.ready();

SELECT 
    transcript, 
    llama2_app.app_public.llm('Given the following transcript, return a valid JSON object with the following structure: { "call_summary": "", "root_cause": "", "resolution": "", "ending_customer_sentiment": "", "ending_satisfaction_scale_1_10": ""}' || transcript) AS llm 
FROM llama2_consumer.data.customer_support_transcripts
LIMIT 1;

