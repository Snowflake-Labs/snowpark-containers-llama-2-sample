-- MUST BE RUN BY ACCOUNTADMIN to allow browsing to containers via HTTPS
CREATE SECURITY INTEGRATION snowservices_ingress_oauth
  TYPE=oauth
  OAUTH_CLIENT=snowservices_ingress
  ENABLED=true;

-- Stage to store LLM models
CREATE STAGE IF NOT EXISTS models
 ENCRYPTION = (TYPE='SNOWFLAKE_SSE');

-- Stage to store yaml specs
CREATE STAGE IF NOT EXISTS specs
 ENCRYPTION = (TYPE='SNOWFLAKE_SSE');

-- Image registry
CREATE OR REPLACE IMAGE REPOSITORY images;

-- Compute pool to run containers
CREATE COMPUTE POOL gpu_3
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = gpu_3;
