# Llama 2 and Snowpark Container Services Demo

> To see Jeff Hollan demo this as part of the Snowflake Demo Challenge, check out [the recording](https://www.youtube.com/watch?v=FbZqfoUwKns).

This repo will give you the setup scripts and code required to run the Snowpark Container Services demo of building an LLM powered function in Snowflake to pull out information on chat transcripts stored in Snowflake.

## Pre-requisites
- Docker Desktop (or some way to build containers)
- [VS Code](https://code.visualstudio.com/) (recommended)
- Access to Snowpark Container Services Preview - details on region availability can be found [here](https://github.com/Snowflake-Labs/spcs-updates).
- [Snowflake CLI](https://github.com/Snowflake-Labs/snowcli) (optional but recommended)
- A [HuggingFace](https://huggingface.co/) account
- Completed [Llama 2 request form](https://ai.meta.com/resources/models-and-libraries/llama-downloads/). **Your Hugging Face account email address MUST match the email you provide on the Meta website, or your request will not be approved.**
- After approval, submit the form in [HuggingFace](https://huggingface.co/meta-llama/Llama-2-7b-chat-hf) to unlock access to the model.

## Setup for Demo

The following will get your account setup to run the demo.

### Make sure you have access to Llama 2

Be sure to complete the steps in the Pre-Reqs section to request access for Llama 2 from Meta, as well as enabling access in the Llama-2 HuggingFace repo.

### Clone this sample

`git clone https://github.com/Snowflake-Labs/snowpark-containers-llama-2-sample`

### Load transcript data

Browse to [_setup/1_load_data.sql](./_setup/1_load_data.sql) and run the SQL to create the table and load the data. You can do this via the VS Code extension or copy/paste into Snowflake.

### Create required objects

Browse to [_setup/2_create_objects.sql](./_setup/2_create_objects.sql) and run the SQL to create the required objects. You can do this via the VS Code extension or copy/paste into Snowflake.  The SECURITY INTEGRATION **MUST** be run by an ACCOUNTADMIN for the account (if already run for the account this can be skipped).

This will create:
1. SECURITY INTEGRATION to allow Oauth to containers (if not already enabled for the account)
2. A stage to store the LLM that is downloaded. This will allow us to cache the LLM for faster startup in future runs.
3. A stage to upload and store the YAML specs for the containers.
4. A container image registry to push our docker images
5. A compute pool to run the containers (by default using GPU_NV_S, you could use GPU_NV_M).  If using Llama_13b you'll need GPU_NV_M at least, and if using Llama_70b you'll need GPU_NV_L at least. I wouldn't recommend the larger models due to cost / capacity and much longer startup times (Llama_70b takes 25 min to load after model download).

### Login to the Snowflake Image Registry

Get the registry URL for the created registry by running `SHOW IMAGE REPOSITORIES` in the schema where you ran the above setup scripts. Copy the `repository_url` value. You can run this from the Snowflake CLI with `snow sql -q 'SHOW IMAGE REPOSITORIES' -c <connection_name> --format json`

#### If you have a plain-text password
Login with the docker client to your registry: `docker login <repository_url> -u <username>` and fill in your password when prompted.

#### If you have a non-plain-text password
Use the [Snowflake CLI](https://docs.snowflake.com/LIMITEDACCESS/snowcli/registry/overview) to generate a token to login. This will expire after some period of time so you may need to re-run this command if you get an error about an expired token. If you haven't used the Snowflake CLI you may need to run `snow connection add` first to create a connection.

`snow registry token -c <connection_name> --format json | docker login <repository_url> -u 0sessiontoken --password-stdin`

### Build the container images

There are 3 containers used in the demo.
1. LLM container - this will host and run the LLM directly
2. UDF API container - this is a small wrapper that will run as a "sidecar" to the LLM container in the same service to allow calling as a Snowflake UDF
3. Streamlit container - a container to demo calling the LLM from Streamlit in a chat app (using the OpenAI API format)

⚠️ BE SURE TO BUILD THESE FOR `linux/amd64`⚠️
If you are using a Mac M1 or M2 device, by default your docker client may build ARM based images. Our compute pools today are x86. You will need to make sure you are using Docker emulation so that you can build and emulate x86 images. You can do this by running `docker build --platform linux/amd64 -t <image_name> .` for each of the images.

#### Get the repository URL

Run:
`SHOW IMAGE REPOSITORIES IN SCHEMA;` and get the repository_url value so you can replace it in the `<repository_url>` values below. 

#### LLM Container
Browse to [LLM/](./LLM) locally in a terminal session, and run:
`docker build -t llm .`
Be sure to see the warning above if using Mac M1 or M2 device to modify this using the `--platform` flag.

Once the docker container is built, we need to tag it to map to your registry. You can do this by running: 

`docker tag llm <repository_url>/llm` 
 
(replacing the `<repository_url>` placeholder with your repository_url)

And push the image to your image registry (we push now so that is cached and shortens upload time later).
`docker push <repository_url>/llm`

#### UDF API Container
Browse to [UDF_API/](./UDF_API) locally in a terminal session, and run:
`docker build -t udf-flask .`

Once the docker container is built, we need to tag it to map to your registry. You can do this by running:

`docker tag udf-flask <repository_url>/udf-flask`

(replacing the `<repository_url>` placeholder with your repository_url)

And push the image to your image registry.
`docker push <repository_url>/udf-flask`

#### Streamlit Container
Browse to [Streamlit/](./Streamlit) locally in a terminal session, and run:
`docker build -t streamlit .`

Once the docker container is built, we need to tag it to map to your registry. You can do this by running:

`docker tag streamlit <repository_url>/streamlit`

(replacing the `<repository_url>` placeholder with your repository_url)

And push the image to your image registry.
`docker push <repository_url>/streamlit`

### Update the YAML files with your specific values

I created a simple script to make this easy. Before running you'll need to know:
1. Your repository_url
2. A warehouse for the Streamlit app to use for queries
3. Your HuggingFace username (NOT your email, but the username in profile)
4. A HuggingFace read token (you can get this from your HuggingFace account page)

> NOTE: A few users have reported that this script does not replace the values in the `llm.yaml` and `streamlit.yaml` as expected. it uses a bash command called `sed` to do the replacement. It's worth checking the yaml files after completion to make sure values like `<<repository_url>>` are replaced. If not, you can replicate the script by just replacing this strings manually.


```
bash ./config_project.sh
```

### Upload your YAML files to Snowflake

I use the Snowflake CLI for this operation, you could also just upload the files through Snowsight into the stage, or use SnowSQL.

```
# create a connection to your account in the CLI if you haven't already
# remember the name or use the recommended default "dev"
# and set to the database / schema used for setup scripts
snow connection add

# upload the YAML files
# replace <connection_name> with the name of connection above
# NOTE: depending on your version of Snowflake CLI, this may be `snow object stage` instead of `snow stage`.
snow stage put ./streamlit/streamlit.yaml specs -c <connection_name> --overwrite
snow stage put ./LLM/llm.yaml specs -c <connection_name> --overwrite
```

### Deploy the Streamlit container
```
create service streamlit
in compute pool GPU_NV_S
from @specs
spec='streamlit.yaml';
```

**Wait for about 30 seconds** for the URL to fully propogate via DNS, and then get the URL:

```
show services in schema;
```

Find the `public_endpoints` column and copy the URL in the "streamlit" value (e.g. `d6zzoi75-sfengineering-servicesnow.snowflakecomputing.app`). This is URL you can use to browse to the Streamlit app in the demo.

The Streamlit app won't work until the LLM is running, which is detailed in the "[Create the Service](#create-the-service)" section below.

🚨 IMPORTANT: Your services will only be able to fully startup and run once the Compute Pool created is in the `ACTIVE` state. You can view the startup state of your compute pools by running `show compute pools`. This can take a long time depending on the region and compute pool instance type.

## Running the demo

### Show the customer support transcripts to setup the scenario
We're going to be pulling out relevant business information from customer support transcripts. Show the data in the `CUSTOMER_SUPPORT_TRANSCRIPTS` table.

```
select *
from customer_support_transcripts;
```

### Create the service
In Snowflake:

```
create service llama_2
in compute pool GPU_NV_S
from @specs
spec='llm.yaml';
```

### Make sure an LLM is started
If you have a second already-running LLM you can skip this part. If you are waiting for the LLM to start in real time, you will need to wait for the LLM to finish starting up. The easiest way to do this for me is the Snowflake CLI. Run the following Snowflake CLI command to tail the logs of the LLM service:

Snowflake CLI
```
snow snowpark services logs llama_2 --container_name llm-container --environment <environment_name>
```

SQL
```
call system$get_service_logs('llama_2', '0', 'llm-container', '100');
```

The service is fully started when you see the line: **llama_2/0 fastchat.serve.openai_api_server is ready**

You can use `watch` or continue to run the above command if you're waiting for other parts to complete (e.g. model download, model checkpoint shard loading, etc.)

### Show how you can call in Streamlit

Open to the Streamlit app you deployed (in main schema or in "already-running-LLM schema") as the last part of the setup portion. If the LLM is running you should be able to send messages and get responses. If the LLM is not running / has an error, you'll see the Streamlit app returning an error of `APIConnectionError: Error communicating with OpenAI: HTTPConnectionPool(host=llama_2, port=8000)`. As an FYI, the reason you see "OpenAI" in this error message is the demo is using the [OpenAI API **format**](https://github.com/lm-sys/FastChat/blob/main/docs/openai_api.md) to communicate with Llama_2. It's not calling the OpenAI service or APIs at all.

### Create a SQL function

```
create function llm(prompt text)
returns text
service=llama_2
endpoint=chat;
```

### Pull out information from the transcripts

```
select transcript, llm('Given the following transcript, return a JSON object with the following structure: { "call_summary": "", "root_cause": "", "resolution": "", "ending_customer_sentiment": ""}' || transcript)
from shared_db.public.customer_support_transcripts
limit 1;
```

Show how it works with 1. Then remove `limit 1` and re-run. This will now run through all rows. NOTE: this takes a while to run through all 20 rows, so usually wrap up the demo before waiting.

### Celebrate

Party, celebrate, and pass any feedback to jeff.hollan@snowflake.com

---

### Troubleshooting
If you're hitting issues with any of the above, here's a few pointers:

#### I'm getting an error calling my LLM from Streamlit or UDF
1. Check the logs:
```
-- the llm container that hosts the LLM and exposes an OpenAI compatible endpoint
call system$get_service_logs('llama_2', '0', 'llm-container', '100');
-- the udf converter that accepts a Snowflake UDF request and calls the LLM - runs in the llama_2 service
call system$get_service_logs('llama_2', '0', 'udf', '100');
-- the streamlit app
call system$get_service_logs('streamlit', '0', 'streamlit', '100');
```

2. Be sure to check your `.yaml` files you uploaded for service definition.

#### I'm getting a weird error in logs about exec format error
This almost always means it's trying to run an ARM based computer on x86 infra. Re-build, re-tag, and re-push your container images but be sure to include the `--platform linux/amd64` flag in the docker build.


