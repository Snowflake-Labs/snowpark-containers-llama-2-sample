This is a small utility I built while preparing the demo that starts up, checks the mounted stage at /models for the HuggingFace model defined. If it exists (or partially exists), it copies it and makes sure it is up-to-date. If it doesn't exist, it will git lfs clone it and then copy it to the mounted stage.

To use you can update the `huggingface.yaml` file with your preferred huggingface model / username / token, upload it to @specs, and then run it as a job:

```
EXECUTE SERVICE 
  -- not a bad idea to create a new STANDARD pool for this
  -- because it does not need GPUs
  IN COMPUTE POOL GPU_3
  FROM @specs
  SPEC='huggingface.yaml';
```

Be sure to copy the Query ID that pops out and then you can query logs to check the status as it downloads:

```
snow snowpark jobs status $JOB_ID --connection <connection_name>
```