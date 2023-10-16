import os
import openai
import streamlit as st
from snowflake.snowpark import Session
from utils import create_session_object

table = os.getenv('REFERENCE.CUSTOMER_SUPPORT_TRANSCRIPTS') or "customer_support_transcripts"
st.sidebar.json(dict(os.environ))
st.sidebar.json({
        "table": table,
        "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE") or None
    })

session:Session = create_session_object()
st.sidebar.json({
    "user": session._conn._conn.user,
    "role": session.get_current_role(),
    "conn_role": session._conn._conn.role,
    "warehouse": session.get_current_warehouse(),
    "conn_warehouse": session._conn._conn.warehouse
})

openai.api_key = "NotNeeded"
openai.api_base = os.getenv("OPENAI_API_BASE")

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

st.title("Transcript Analyzer")

st.subheader("Trial 1")

@st.cache_data
def load_data():
    #df = session.table(table)
    df = session.sql("SELECT * FROM Reference('CUSTOMER_SUPPORT_TRANSCRIPTS')")
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
            for response in openai.ChatCompletion.create(
                model=st.session_state["model"],
                messages=[
                    {"role": m["role"], "content": m["content"]}
                    for m in st.session_state.messages
                ],
                stream=True,
            ):
                full_response += response.choices[0].delta.get("content", "")
                message_placeholder.markdown(full_response + "▌")
            message_placeholder.markdown(full_response)
        st.session_state.messages.append(
            {"role": "assistant", "content": full_response}
        )

st.markdown("#")
st.markdown("#")

#st.dataframe(df)
