FROM nvcr.io/nvidia/pytorch:23.06-py3

RUN pip3 install --upgrade pip && pip3 install accelerate fschat[model_worker] huggingface_hub

COPY entrypoint.sh /entrypoint.sh
COPY download_model.py /download_model.py
RUN chmod +x /entrypoint.sh

ENV HUGGING_FACE_MODEL=meta-llama/Llama-2-7b-chat-hf

ENTRYPOINT ["/entrypoint.sh"]
