# The Snowflake Native App version!

This (sub)repo will give you the setup scripts and code required to run
this demo as a Snowflake Native App.

Please see the `README.md` in the parent directory. You will need the same
prerequisites. You can test the Snowflake Native App in a single account
(the way we enable Providers to build and test in the same account) but to
show the Consumer experience you will need 2 Snowflake accounts.

## Setup for Demo
There are 2 parts to set up, the Provider and the Consumer.

### Provider Setup
For the Provider, we need to set up only a few things:
* A stage to hold the files for the Native App
* An APPLICATION PACKAGE that defines the Native App

As `ACCOUNTADMIN` run the commands in `provider_setup.sql`.

To enable the setup, we will use some templated files. As with the 
main demo, there is a script to generate the files from the templated
files. You will need 2 things as inputs:
* The full name of the image repository. You can get this by running `SHOW IMAGE REPOSITORIES IN SCHEMA`
  for the `CODE_SCHEMA` in the APPLICATION PACKAGE, and getting the `repository_url`.
* Your HuggingFace token.

To create the files, run:

```
bash ./config_napp.sh
```

This created a `Makefile` with the necessary repository filled in. Feel free to look
at the Makefile, but you can also just run:

```
make all
```

This will create the 3 container images (just like the main demo) and push them to
the IMAGE REPOSITORY in the APPLICATION PACKAGE.

Next, you need to upload the following files into `

To create the VERSION for the APPLICATION PACKAGE, run the following commands
(they are also in `provider_version.sql`):

```
-- for the first version of a VERSION
USE ROLE ACCOUNTADMIN;
ALTER APPLICATION PACKAGE llama2_pkg ADD VERSION v1 USING @llama1.napp.llama2_stage;
```

If you need to iterate, you can create a new PATCH for the version by running this
instead:

```
-- for subsequent updates to VERSION
USE ROLE ACCOUNTADMIN;
ALTER APPLICATION PACKAGE llama2_pkg ADD PATCH FOR VERSION v1 USING @llama1.napp.llama2_stage;
```

You Native App is now ready on the Provider Side. You can make the Native App available
for installation in other Snowflake Accounts by setting a default PATCH and Sharing the App
in the Snowsight UI.

Navigate to the "Apps" tab and select "Packages" at the top. Now click on your App Package 
(`LLAMA2_PKG`). From here you can click on "Set release default" and choose the latest patch
(the largest number) for version `v1`. 

Next, click "Share app package". This will take you to the Provider Studio. Give the listing
a title, choose "Only Specified Consumers", and click "Next". For "What's in the listing?", 
select the App Package (`LLAMA2_PKG`). Add a brief description. Lastly, add the Consumer account
identifier to the "Add consumer accounts". Then click "Publish".

### Testing on the Provider Side

#### Setup for Testing on the Provider Side
We can test our Native App on the Provider by mimicking what it would look like on the 
Consumer side (a benefit/feature of the Snowflake Native App Framework).

To do this, run the commands in `consumer_setup.sql`. This will create the role, data, 
virtual warehouse, and COMPUTE POOL necessary for the Native App. The ROLE you will use
for this is `NAC`.

#### Testing on the Provider Side
To install the Native App we need to install it, and also give it some privileges:
* Usage on a COMPUTE POOL
* Usage for a Virtual Warehouse for the Streamlit app to issue queries
* Access to the transcript data

Run the commands in `provider_test.sql`. After running `start_app()`, you will need
to be patient. The model (which is pretty big) needs to be downloaded before the LLM
is ready to be used. We do save the model in a STAGE inside the Native App, so if you
`stop_app()` and then `start_app()` again, it will be faster this second time.

There is a Stored Procedure in the Native App that will show when the LLM is ready.
You will need to call it until it returns that the LLM is ready (it doesn't loop and
wait until it's ready; it just reports if it is ready or not).

```
CALL llama2_app.app_public.llm_ready();
```

Once the app has started, you can do 2 things:
* Visit the Streamlit by navigating to its URL. This is returned from the `start_app()`
  call, and is also available by calling `app_url()`.
* Use the `llama2_app.app_public.llm()` UDF in a SQL statement.

##### Cleanup
To clean up the Native App, you can just `DROP` it:

```
DROP APPLICATION llama2_app;
```

You can also drop the DATABASE for the data (`LLAMA2`), the COMPUTE POOL (`GPU_3`),
the WAREHOUSE (`WH_NAC`), and the ROLE (`NAC`);

### Using the Native App on the Consumer Side

#### Setup for Testing on the Provider Side
We're ready to import our Native App in the Consumer account.

To do the setup, run the commands in `consumer_setup.sql`. This will create the role, data, 
virtual warehouse, and COMPUTE POOL necessary for the Native App. The ROLE you will use
for this is `NAC`.

#### Using the Native App on the Consumer
To get the Native app, navigate to the "Apps" sidebar. You should see the app at the top under
"Recently Shared with You". Click the "Get" button. Select a Warehouse to use for installation.
Under "Application name", choose the name `LLAMA2_APP` (You _can_ choose a different name, but
the scripts use `LLAMA2_APP`). Click "Get".

Once the App has been installed, we need to give it some privileges:
* Usage on a COMPUTE POOL
* Usage for a Virtual Warehouse for the Streamlit app to issue queries
* Access to the transcript data

Run the commands in `consumer.sql`. After running `start_app()`, you will need
to be patient. The model (which is pretty big) needs to be downloaded before the LLM
is ready to be used. We do save the model in a STAGE inside the Native App, so if you
`stop_app()` and then `start_app()` again, it will be faster this second time.

There is a Stored Procedure in the Native App that will show when the LLM is ready.
You will need to call it until it returns that the LLM is ready (it doesn't loop and
wait until it's ready; it just reports if it is ready or not).

```
CALL llama2_app.app_public.llm_ready();
```

Once the app has started, you can do 2 things:
* Visit the Streamlit by navigating to its URL. This is returned from the `start_app()`
  call, and is also available by calling `app_url()`.
* Use the `llama2_app.app_public.llm()` UDF in a SQL statement.

##### Cleanup
To clean up the Native App, you can just uninstall it from the "Apps" tab.

You can also drop the DATABASE for the data (`LLAMA2`), the COMPUTE POOL (`GPU_3`),
the WAREHOUSE (`WH_NAC`), and the ROLE (`NAC`);


#### Debugging
I added some debugging Stored Procedures to allow the Consumer to see the status
and logs for the containers and services. These procedures are granted to the `app_admin`
role and are in the `app_public` schema:
* `GET_SERVICE_STATUS()` which takes the same arguments and returns the same information as `SYSTEM$GET_SERVICE_STATUS()`
* `GET_SERVICE_LOGS()` which takes the same arguments and returns the same information as `SYSTEM$GET_SERVICE_LOGS()`
* `LIST_LOGS()` which takes no arguments and lists the log files for the `llama_2` service
* `TAIL_LOG()` which takes 2 arguments: the log file name and the number of lines. It returns the last N lines of that log file.

The permissions to debug are managed on the Provider in the `LLAMA2_PKG.SHARED_DATA.FEATURE_FLAGS` table. 
It has a very simple schema:
* `acct` - the Snowflake account to enable. This should be set to the value of `SELECT current_account()` in that account.
* `flags` - a VARIANT object. For debugging, the object should have a field named `debug` which is an 
  array of strings. These strings enable the corresponding stored procedure:
  * `GET_SERVICE_STATUS`
  * `GET_SERVICE_LOGS`
  * `LIST_LOGS`
  * `TAIL_LOG`

An example of how to enable logging for a particular account (for example, account `ABC12345`) to give
them all the debugging permissions would be

```
INSERT INTO llama2_pkg.shared_data.feature_flags 
  SELECT parse_json('{"debug": ["GET_SERVICE_STATUS", "GET_SERVICE_LOGS", "LIST_LOGS", "TAIL_LOG"]}') AS flags, 
         'ABC12345' AS acct;
```

To enable on the Provider account for use while developing on the Provider side, you could run

```
INSERT INTO llama2_pkg.shared_data.feature_flags 
  SELECT parse_json('{"debug": ["GET_SERVICE_STATUS", "GET_SERVICE_LOGS", "LIST_LOGS", "TAIL_LOG"]}') AS flags,
         current_account() AS acct;
```
