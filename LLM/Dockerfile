FROM nvcr.io/nvidia/pytorch:23.06-py3

RUN pip3 install --upgrade pip && pip3 install accelerate==0.26.1 fschat==0.2.34 transformers==4.33.3 huggingface_hub==0.20.2

COPY entrypoint.sh /entrypoint.sh
COPY download_model.py /download_model.py
RUN chmod +x /entrypoint.sh

ENV HUGGING_FACE_MODEL=meta-llama/Llama-2-7b-chat-hf

ENTRYPOINT ["/entrypoint.sh"]