# i am using the open ai library to make the request to the user
import os 
# pyrefly: ignore[missing-import]
from openai import OpenAI
from dotenv import load_dotenv,find_dotenv

#it automatically find and load all the env variable keys

load_dotenv(find_dotenv())

# creating the gemini client 
client = OpenAI(
         api_key=os.getenv("GEMINI_API_KEY"),
         base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
         )

# checking all the available models
models = client.models.list()

for model in models.data:
    print(model.id)
    
#making my first request

response = client.chat.completions.create(
    model="gemini-3.1-flash-lite",
    messages=[
        {"role":"user", "content":"Hello, how are you?"}
    ],
    max_tokens=50
)

print(response.choices[0].message.content)

print("\n")



