from openai.types.live import client_delegation
import os
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()



client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.getenv("OPENROUTER_MODELS")
)

def available_models():
    models_list= client.models.list()
    for model in models_list:
        if model.id.endswith("free"):
            
            return model.id 

# this is one of the good way , now its time to make it production standard

def chat_models(prompt):
  try:  
    response = client.chat.completions.create(
        model=available_models(),
        temperature=0.1,
        max_tokens=1000,
        messages=[
            {
                "role": "system",
                "content": "Provide answers to the point. For mathematics and programming questions, provide precise code snippets."
            },
            {
                "role": "user",
                "content": prompt
            }
        ],
        stream=True,
        timeout=30
     )       

    for chunk in response:
        content = chunk.choices[0].delta.content
        if content:
            print(content, end="")
  except Exception as e:
        print(f"An error occurred: {e}")
            
print(chat_models("Explain programming fundamentals in assembly."))