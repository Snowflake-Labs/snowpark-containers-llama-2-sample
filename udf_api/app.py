from flask import Flask, request, Response, jsonify
import logging
from openai import OpenAI
import os

client = OpenAI(
    base_url=os.getenv("OPENAI_API_BASE"),
    api_key="EMPTY",
)
import re
from dotenv import load_dotenv

load_dotenv()

model = os.getenv("MODEL")

app = Flask(__name__)
app.logger.setLevel(logging.ERROR)


def extract_json_from_string(s):
    logging.info(f"Extracting JSON from string: {s}")
    # Use a regular expression to find a JSON-like string
    matches = re.findall(r"\{[^{}]*\}", s)

    if matches:
        # Return the first match (assuming there's only one JSON object embedded)
        return matches[0]

    # Return the original string if no JSON object is found
    return s


@app.route("/", methods=["POST"])
def udf():
    try:
        request_data: dict = request.get_json(force=True)  # type: ignore
        return_data = []

        for index, col1 in request_data["data"]:
            completion = client.chat.completions.create(
                model=model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a bot to help extract data and should give professional responses",
                    },
                    {"role": "user", "content": col1},
                ],
            )
            return_data.append(
                [index, extract_json_from_string(completion.choices[0].message.content)]
            )

        return jsonify({"data": return_data})
    except Exception as e:
        app.logger.exception(e)
        return jsonify(str(e)), 500
