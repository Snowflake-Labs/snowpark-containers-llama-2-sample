import os
from snowflake.snowpark import Session
from dotenv import load_dotenv

load_dotenv()
if os.path.exists("/snowflake_config/configs.env"):
    load_dotenv("/snowflake_config/configs.env")

def create_session_object():
    if not os.path.exists("/snowflake/session/token"):
        connection_parameters = {
            "account": os.getenv("SNOWFLAKE_ACCOUNT"),
            "user": os.getenv("SNOWFLAKE_USER"),
            "password": os.getenv("SNOWFLAKE_PASSWORD"),
            "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE"),
            "database": os.getenv("SNOWFLAKE_DATABASE"),
            "schema": os.getenv("SNOWFLAKE_SCHEMA"),
            "role": os.getenv("SNOWFLAKE_ROLE"),
        }

        return Session.builder.configs(connection_parameters).create()
    else:
        with open("/snowflake/session/token", "r") as f:
            token = f.read()

        connection_parameters = {
            "account": os.getenv("SNOWFLAKE_ACCOUNT"),
            "host": os.getenv("SNOWFLAKE_HOST"),
            "authenticator": "oauth",
            "token": token,
            "database": os.getenv("SNOWFLAKE_DATABASE"),
            "schema": os.getenv("SNOWFLAKE_SCHEMA"),
        }
        if os.getenv("SNOWFLAKE_WAREHOUSE"):
            connection_parameters["warehouse"] = os.getenv("SNOWFLAKE_WAREHOUSE")
        return Session.builder.configs(connection_parameters).create()
