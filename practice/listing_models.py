#I will list all the models of the openrouter here 

import os
from openai import OpenAI 
from dotenv import load_dotenv


load_dotenv()


client = OpenAI(base_url="https://openrouter.ai/api/v1", 
api_key=os.getenv("OPENROUTER_MODELS"))

available_models=client.models.list()

for model in available_models:
    print(model.id)


print("\n\n\n")
print(f"free models")
#now listing all the free models 
for model in available_models:              
  if model.id.endswith(":free"):
    print(model.id)     
   

   