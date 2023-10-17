CREATE APPLICATION ROLE app_admin;
CREATE APPLICATION ROLE app_user;
CREATE SCHEMA IF NOT EXISTS app_public;
CREATE SCHEMA IF NOT EXISTS app_internal;
GRANT USAGE ON SCHEMA app_public TO APPLICATION ROLE app_admin;
GRANT USAGE ON SCHEMA app_public TO APPLICATION ROLE app_user;
CREATE STAGE IF NOT EXISTS app_public.models DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE='SNOWFLAKE_SSE');
CREATE STAGE IF NOT EXISTS app_internal.config DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE='SNOWFLAKE_SSE');
CREATE OR ALTER VERSIONED SCHEMA v1;
GRANT USAGE ON SCHEMA v1 TO APPLICATION ROLE app_admin;

CREATE OR REPLACE SECURE VIEW app_internal.feature_flags AS
    SELECT * FROM shared_data.feature_flags_vw;
CREATE OR REPLACE FUNCTION app_internal.debug_flag(flag VARCHAR)
    RETURNS BOOLEAN
AS $$
    SELECT array_contains(flag::VARIANT, flags:debug::ARRAY) FROM app_internal.feature_flags
$$;

CREATE OR REPLACE PROCEDURE app_internal.set_config(key VARCHAR, val VARCHAR)
    RETURNS STRING
    LANGUAGE python
    RUNTIME_VERSION = 3.8
    HANDLER = 'handler'
    PACKAGES = ('snowflake-snowpark-python', 'python-dotenv')
AS $$
import dotenv
import io
import json
import functools
stage_name = 'config'
file_name = 'configs.env'

def handler(session, key, val):
    configs = {}
    try:
        fd = io.StringIO(session.file.get_stream(f"@{stage_name}/{file_name}").read().decode('utf-8'))
        configs = dotenv.dotenv_values(stream=fd)
    except:
        pass
    configs[key] = val
    resstr = functools.reduce(lambda a,b: a + f"{b[0]} = {b[1]}\n", configs.items(), "")
    res = io.BytesIO(bytes(resstr, 'utf-8'))
    session.file.put_stream(res, f"@{stage_name}/{file_name}", auto_compress=False, overwrite=True)
    return json.dumps(configs)
$$
;

CREATE OR REPLACE PROCEDURE app_internal.unset_config(key VARCHAR)
    RETURNS STRING
    LANGUAGE python
    RUNTIME_VERSION = 3.8
    HANDLER = 'handler'
    PACKAGES = ('snowflake-snowpark-python', 'python-dotenv')
    AS 
$$
import json
import io
import dotenv
import functools
stage_name = 'config'
file_name = 'configs.env'

def handler(session, key):
    configs = {}
    try:
        fd = io.StringIO(session.file.get_stream(f"@{stage_name}/{file_name}").read().decode('utf-8'))
        configs = dotenv.dotenv_values(stream=fd)
    except:
        pass
    configs.pop(key, None)
    resstr = functools.reduce(lambda a,b: a + f"{b[0]} = {b[1]}\n", configs.items(), "")
    res = io.BytesIO(bytes(resstr, 'utf-8'))
    session.file.put_stream(res, f"@{stage_name}/{file_name}", auto_compress=False, overwrite=True)
    return json.dumps(configs)
$$
;

CREATE OR REPLACE PROCEDURE app_internal.show_config()
    RETURNS STRING
    LANGUAGE python
    RUNTIME_VERSION = 3.8
    HANDLER = 'handler'
    PACKAGES = ('snowflake-snowpark-python', 'python-dotenv')
    AS 
$$
import json
import dotenv
import io
stage_name = 'config'
file_name = 'configs.env'

def handler(session):
    try:
        fd = io.StringIO(session.file.get_stream(f"@{stage_name}/{file_name}").read().decode('utf-8'))
        configs = dict(dotenv.dotenv_values(stream=fd))
        return json.dumps(configs)
    except:
        return None
$$
;

CREATE PROCEDURE v1.register_single_callback(ref_name STRING, operation STRING, ref_or_alias STRING)
 RETURNS STRING
 LANGUAGE SQL
 AS $$
      BEGIN
      CASE (operation)
         WHEN 'ADD' THEN
            SELECT system$set_reference(:ref_name, :ref_or_alias);
            IF (ref_name = 'STREAMLIT_WAREHOUSE') THEN
                CALL app_internal.set_config('SNOWFLAKE_WAREHOUSE', :ref_or_alias);
            END IF;
            IF (ref_name = 'CUSTOMER_SUPPORT_TRANSCRIPTS') THEN
                CALL app_internal.set_config('REFERENCE.CUSTOMER_SUPPORT_TRANSCRIPTS', :ref_or_alias);
            END IF;
         WHEN 'REMOVE' THEN
            SELECT system$remove_reference(:ref_name);
            IF (ref_name = 'STREAMLIT_WAREHOUSE') THEN
                CALL app_internal.unset_config('SNOWFLAKE_WAREHOUSE');
            END IF;
            IF (ref_name = 'CUSTOMER_SUPPORT_TRANSCRIPTS') THEN
                CALL app_internal.unset_config('REFERENCE.CUSTOMER_SUPPORT_TRANSCRIPTS');
            END IF;
         WHEN 'CLEAR' THEN
            SELECT system$remove_reference(:ref_name);
            IF (ref_name = 'STREAMLIT_WAREHOUSE') THEN
                CALL app_internal.unset_config('SNOWFLAKE_WAREHOUSE');
            END IF;
            IF (ref_name = 'CUSTOMER_SUPPORT_TRANSCRIPTS') THEN
                CALL app_internal.unset_config('REFERENCE.CUSTOMER_SUPPORT_TRANSCRIPTS');
            END IF;
         ELSE
            RETURN 'Unknown operation: ' || operation;
      END CASE;
      RETURN 'Operation ' || operation || ' succeeds.';
      END;
   $$;
GRANT USAGE ON PROCEDURE v1.register_single_callback( STRING,  STRING,  STRING) TO APPLICATION ROLE app_admin;

CREATE OR REPLACE PROCEDURE app_public.start_app(pool_name VARCHAR)
    RETURNS string
    LANGUAGE sql
    AS $$
DECLARE
    ingress_url VARCHAR;
BEGIN
    EXECUTE IMMEDIATE 
        'CREATE SERVICE IF NOT EXISTS app_public.llama_2'
        ||  ' IN COMPUTE POOL ' || pool_name
        ||  ' SPEC=llm.yaml';
    GRANT USAGE ON SERVICE app_public.llama_2 TO APPLICATION ROLE app_user;

    CREATE FUNCTION app_public.llm(prompt TEXT)
        RETURNS TEXT
        SERVICE = app_public.llama_2
        ENDPOINT = chat
    ;
    GRANT USAGE ON FUNCTION app_public.llm(TEXT) TO APPLICATION ROLE app_user;

    EXECUTE IMMEDIATE 
        'CREATE SERVICE IF NOT EXISTS app_public.streamlit'
        ||  ' IN COMPUTE POOL ' || pool_name
        ||  ' SPEC=streamlit.yaml';
    GRANT USAGE ON SERVICE app_public.streamlit TO APPLICATION ROLE app_user;

    SHOW ENDPOINTS IN SERVICE app_public.streamlit;
    SELECT "ingress_url" INTO :ingress_url FROM TABLE (RESULT_SCAN (LAST_QUERY_ID())) LIMIT 1;
    RETURN ingress_url;
END
$$;

CREATE OR REPLACE PROCEDURE app_public.start_app(pool_name VARCHAR, streamlit_warehouse VARCHAR, customer_table VARCHAR)
    RETURNS string
    LANGUAGE sql
    AS $$
DECLARE
    ingress_url VARCHAR;
BEGIN
    CALL app_internal.set_config('SNOWFLAKE_WAREHOUSE', :streamlit_warehouse);
    CALL app_internal.set_config('REFERENCE.CUSTOMER_SUPPORT_TRANSCRIPTS', :customer_table);

    CALL app_public.start_app(:pool_name) INTO :ingress_url;
    RETURN ingress_url;
END
$$;
GRANT USAGE ON PROCEDURE app_public.start_app(VARCHAR,VARCHAR,VARCHAR) TO APPLICATION ROLE app_admin;

CREATE OR REPLACE PROCEDURE app_public.stop_app()
    RETURNS string
    LANGUAGE sql
    AS
$$
BEGIN
    DROP FUNCTION IF EXISTS app_public.llm(TEXT);
    DROP SERVICE IF EXISTS app_public.llama_2;
    DROP SERVICE IF EXISTS app_public.streamlit;
END
$$;
GRANT USAGE ON PROCEDURE app_public.stop_app() TO APPLICATION ROLE app_admin;

CREATE OR REPLACE PROCEDURE app_public.app_url()
    RETURNS string
    LANGUAGE sql
    AS
$$
DECLARE
    ingress_url VARCHAR;
BEGIN
    SHOW ENDPOINTS IN SERVICE app_public.streamlit;
    SELECT "ingress_url" INTO :ingress_url FROM TABLE (RESULT_SCAN (LAST_QUERY_ID())) LIMIT 1;
    RETURN ingress_url;
END
$$;
GRANT USAGE ON PROCEDURE app_public.app_url() TO APPLICATION ROLE app_admin;
GRANT USAGE ON PROCEDURE app_public.app_url() TO APPLICATION ROLE app_user;

CREATE OR REPLACE PROCEDURE app_public.llm_ready()
    RETURNS STRING
    LANGUAGE python
    RUNTIME_VERSION = 3.8
    HANDLER = 'handler'
    PACKAGES = ('snowflake-snowpark-python')
AS $$
def handler(session):
    try:
        df = session.sql("SELECT app_public.llm('Are you ready?') AS llm").collect()
        return 'READY!'
    except:
        return 'Not quite ready yet'
$$;
GRANT USAGE ON PROCEDURE app_public.llm_ready() TO APPLICATION ROLE app_admin;
GRANT USAGE ON PROCEDURE app_public.llm_ready() TO APPLICATION ROLE app_user;


CREATE OR REPLACE PROCEDURE app_public.get_service_status(service VARCHAR, num_lines INT)
    RETURNS VARCHAR
    LANGUAGE SQL
AS $$
DECLARE
    res VARCHAR;
    okay BOOLEAN;
BEGIN
    SELECT app_internal.debug_flag('GET_SERVICE_STATUS') INTO :okay;
    IF (:okay) THEN
        SELECT SYSTEM$GET_SERVICE_status(:service, :num_lines) INTO res;
        RETURN res;
    ELSE
        RETURN 'Not authorized.';
    END IF;
END;
$$;
GRANT USAGE ON PROCEDURE app_public.get_service_status(VARCHAR, INT) TO APPLICATION ROLE app_admin;

CREATE OR REPLACE PROCEDURE app_public.get_service_logs(service VARCHAR, instance INT, container VARCHAR, num_lines INT)
    RETURNS VARCHAR
    LANGUAGE SQL
AS $$
DECLARE
    res VARCHAR;
    okay BOOLEAN;
BEGIN
    SELECT app_internal.debug_flag('GET_SERVICE_LOGS') INTO :okay;
    IF (:okay) THEN
        SELECT SYSTEM$GET_SERVICE_LOGS(:service, :instance, :container, :num_lines) INTO res;
        RETURN res;
    ELSE
        RETURN 'Not authorized.';
    END IF;
END;
$$;
GRANT USAGE ON PROCEDURE app_public.get_service_logs(VARCHAR, INT, VARCHAR, INT) TO APPLICATION ROLE app_admin;

CREATE PROCEDURE app_public.tail_log(logfile VARCHAR, num_lines INT)
    RETURNS VARCHAR
    LANGUAGE python
    RUNTIME_VERSION = 3.8
    HANDLER = 'handler'
    PACKAGES = ('snowflake-snowpark-python')
AS $$
def handler(session, logfile, num_lines):
    okay = session.sql("SELECT app_internal.debug_flag('TAIL_LOG')").collect()[0][0]
    if not okay:
        raise Exception("Not authorized.")

    lines = [x.decode('utf-8') for x in session.file.get_stream(f"@app_public.models/logs/{logfile}").readlines()]
    return "\n".join(lines[-1*num_lines:])
$$;
GRANT USAGE ON PROCEDURE app_public.tail_log(VARCHAR, INT) TO APPLICATION ROLE app_admin;

CREATE OR REPLACE PROCEDURE app_public.list_logs()
    RETURNS TABLE()
    LANGUAGE python
    RUNTIME_VERSION = 3.8
    HANDLER = 'handler'
    PACKAGES = ('snowflake-snowpark-python')
AS $$
import snowflake.snowpark.functions as f
import pandas as pd
def handler(session):
    okay = session.sql("SELECT app_internal.debug_flag('LIST_LOGS')").collect()[0][0]
    if not okay:
        raise Exception("Not authorized.")

    df = pd.DataFrame(session.sql("LIST @app_public.models/logs").collect())
    if df.shape[0] < 1:
        return session.sql("SELECT 'name' AS name, 0::INT AS size, 'md5' AS md5, 'last_modified' AS last_modified WHERE 1 = 0")
    vals = ", ".join("('" + df['name'].str.replace("models/logs/") + "', " + df['size'].astype('str') + ", '" + df['md5'] + "', '" + df['last_modified'] + "')")
    return session.sql(f"SELECT $1 AS name, $2::INT AS size, $3 AS md5, $4 AS last_modified FROM VALUES {vals}")
$$;
GRANT USAGE ON PROCEDURE app_public.list_logs() TO APPLICATION ROLE app_admin;

