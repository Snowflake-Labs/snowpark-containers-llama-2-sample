import os
from openai import OpenAI

client = OpenAI(
    base_url=os.getenv("OPENAI_API_BASE"),
    api_key="EMPTY",
)
import streamlit as st
from snowflake.snowpark import Session
from utils import create_session_object

# Set a default model
if "model" not in st.session_state:
    st.session_state["model"] = os.getenv("MODEL")

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# streamlit text input in the sidebar that has default input text of "my text" set to variable prompt
prompt_intro = st.sidebar.text_input(
    "Prompt Intro",
    "Summarize the following transcript in a few sentences. Capture relevant business context ### ",
)

session: Session
st.title("Transcript Analyzer")


@st.cache_data
def load_data():
    session = create_session_object()
    df = session.table("customer_support_transcripts")
    return df.to_pandas()


df = load_data()
call_selector = st.selectbox("Select a call", df["CALL_ID"].unique())
if call_selector:
    st.subheader(f"Call ID: {call_selector}")
    st.write("**Transcript**")
    transcript = df[df["CALL_ID"] == call_selector]["TRANSCRIPT"].values[0]
    st.write(transcript)

    if st.button("Extract Information"):
        for message in st.session_state.messages:
            with st.chat_message(message["role"]):
                st.markdown(message["content"])
        st.session_state.messages.append(
            {
                "role": "user",
                "content": prompt_intro + transcript,
            }
        )
        with st.chat_message("assistant"):
            message_placeholder = st.empty()
            full_response = ""
            for chunk in client.chat.completions.create(
                model=st.session_state["model"],
                messages=[
                    {"role": m["role"], "content": m["content"]}
                    for m in st.session_state.messages
                ],
                stream=True,
            ):
                if chunk.choices[0].delta.content is not None:
                    full_response += chunk.choices[0].delta.get("content", "")
                message_placeholder.markdown(full_response + "▌")
            message_placeholder.markdown(full_response)
        st.session_state.messages.append(
            {"role": "assistant", "content": full_response}
        )

st.markdown("#")
st.markdown("#")

st.dataframe(df)
