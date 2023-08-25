FROM nvcr.io/nvidia/pytorch:23.06-py3

RUN pip3 install --upgrade pip && pip3 install accelerate fschat
RUN apt-get update && \
    apt-get install -y git curl rsync && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install git-lfs && \
    git lfs install

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV HUGGING_FACE_MODEL=meta-llama/Llama-2-7b-chat-hf

ENTRYPOINT ["/entrypoint.sh"]
