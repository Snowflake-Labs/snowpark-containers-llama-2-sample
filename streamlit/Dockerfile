FROM python:3.10

WORKDIR /app
ADD ./requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt
# add after installing requirements
# added below before install as pip freeze in container showed 1.3.0
RUN pip uninstall oscrypto -y
RUN pip install oscrypto@git+https://github.com/wbond/oscrypto.git@d5f3437ed24257895ae1edd9e503cfb352e635a8
ADD ./ /app

EXPOSE 8501

ENV STREAMLIT_GLOBAL_DISABLE_WATCHDOG_WARNING=1
CMD ["streamlit", "run", "LLM_Chat.py"]
