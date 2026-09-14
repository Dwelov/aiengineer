import os 
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.environ.get("OPENROUTER_MODELS"),
)

# now i an writing a function to list all the free models of the openrouter
models_list = client.models.list()

for model in models_list.data:
    if model.pricing and model.pricing.get("prompt") == "0":
        print(model.id)

response = client.chat.completions.create(
    model="nvidia/nemotron-3-ultra-550b-a55b:free",
    messages=[
        {
            "role": "user",
            "content": "Hello, how can you assist me today?"
        }
    ]
)

print(response.choices[0].message.content)