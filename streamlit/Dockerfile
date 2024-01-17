FROM python:3.10

WORKDIR /app
ADD ./requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt

ADD ./ /app

EXPOSE 8501

CMD ["streamlit", "run", "LLM_Chat.py"]