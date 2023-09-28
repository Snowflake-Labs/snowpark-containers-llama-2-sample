import os
from huggingface_hub import snapshot_download

hf_token = os.getenv('HF_TOKEN')
hf_model = os.getenv('HF_MODEL')
hf_org = os.getenv('HF_ORG')
target_dir = os.getenv('TARGET_DIR')

if not os.path.exists(target_dir):
    os.makedirs(target_dir)

snapshot_download(repo_id=f"{hf_org}/{hf_model}", token=hf_token, local_dir_use_symlinks=False, local_dir=target_dir)
