#now practising the sampling parameters 
# it controls how the AI model will select the next token based on the list of predicted tokens
# core sampling parameters include 
# 1. Temperature
# 2. Top-p
# 3. Top-k
# 4. Max tokens
# 5. Stop sequences
# 6. Presence penalty
# 7. Frequency penalty

import os 
from openai import OpenAI
from dotenv import load_dotenv,find_dotenv



load_dotenv(find_dotenv())

client = OpenAI(
    api_key=os.getenv("GEMINI_API_KEY"),
    base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
)


response = client.chat.completions.create(
    model="gemini-2.5-flash",
    messages=[
        {"role": "user", "content": "write the note on all the loops type in python"}
    ],
    max_tokens=100,
    temperature=0.2,
    top_p=0.9,
    stop="\n",
    stream=True,
)