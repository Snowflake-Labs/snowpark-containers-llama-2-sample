USE ROLE ACCOUNTADMIN;

-- Build Docker image and push to repo
-- Upload files to Stage

ALTER APPLICATION PACKAGE llama2_pkg ADD VERSION v1 USING @llama2.napp.llama2_stage;

-- for subsequent updates to version
ALTER APPLICATION PACKAGE llama2_pkg ADD PATCH FOR VERSION v1 USING @llama2.napp.llama2_stage;
