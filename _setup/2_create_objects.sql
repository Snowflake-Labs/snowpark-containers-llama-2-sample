-- MUST BE RUN BY ACCOUNTADMIN to allow connecting to huggingface to download the model
CREATE OR REPLACE NETWORK RULE hf_network_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('huggingface.co', 'cdn-lfs.huggingface.co');

CREATE EXTERNAL ACCESS INTEGRATION hf_access_integration
  ALLOWED_NETWORK_RULES = (hf_network_rule)
  ENABLED = true;

GRANT USAGE ON INTEGRATION hf_access_integration TO ROLE <your_role>;
GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE <your_role>;

-- MUST BE RUN BY ACCOUNTADMIN to allow browsing to containers via HTTPS
CREATE SECURITY INTEGRATION snowservices_ingress_oauth
  TYPE=oauth
  OAUTH_CLIENT=snowservices_ingress
  ENABLED=true;

-- Stage to store LLM models
CREATE STAGE IF NOT EXISTS models
 DIRECTORY = (ENABLE = TRUE)
 ENCRYPTION = (TYPE='SNOWFLAKE_SSE');

-- Stage to store yaml specs
CREATE STAGE IF NOT EXISTS specs
 DIRECTORY = (ENABLE = TRUE)
 ENCRYPTION = (TYPE='SNOWFLAKE_SSE');

-- Image registry
CREATE OR REPLACE IMAGE REPOSITORY images;

-- Compute pool to run containers
CREATE COMPUTE POOL GPU_NV_S
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = GPU_NV_S;
