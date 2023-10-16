USE ROLE ACCOUNTADMIN;
CREATE DATABASE IF NOT EXISTS llama2;
CREATE SCHEMA IF NOT EXISTS llama2.napp;
CREATE STAGE IF NOT EXISTS llama2.napp.llama2_stage;

DROP APPLICATION PACKAGE IF EXISTS llama2_pkg;
CREATE APPLICATION PACKAGE llama2_pkg;
USE DATABASE llama2_pkg;
CREATE SCHEMA shared_data;
USE SCHEMA shared_data;
CREATE TABLE feature_flags(flags VARIANT, acct VARCHAR);
CREATE SECURE VIEW feature_flags_vw AS SELECT * FROM feature_flags WHERE acct = current_account();
GRANT USAGE ON SCHEMA shared_data TO SHARE IN APPLICATION PACKAGE llama2_pkg;
GRANT SELECT ON VIEW feature_flags_vw TO SHARE IN APPLICATION PACKAGE llama2_pkg;
INSERT INTO llama2_pkg.shared_data.feature_flags SELECT parse_json('{"debug": ["GET_SERVICE_STATUS", "GET_SERVICE_LOGS", "LIST_LOGS", "TAIL_LOG"]}') AS flags, current_account() AS acct;
CREATE SCHEMA code_schema;
USE SCHEMA code_schema;
CREATE IMAGE REPOSITORY demo_repo;
GRANT USAGE ON SCHEMA code_schema TO SHARE IN APPLICATION PACKAGE llama2_pkg;
GRANT READ ON IMAGE REPOSITORY demo_repo TO SHARE IN APPLICATION PACKAGE llama2_pkg;
SHOW IMAGE REPOSITORIES IN SCHEMA;
-- Build Docker image and push to repo
-- Upload files to Stage

