# LLM APIs

LLM APIs are the application programmking interfaces that allows the client  to interact with the large language models.

## API keys and environmental variables

API keys are the secret codes that we send to targeted application and server uses it  and based on that server knows about our identity it responds

here are the best tricks and safety rules to use the LLM APIs:

### Safety Rules:

1. API keys should be kept secret
2. API keys should not be shared with anyone
3. API keys should not be committed to version control
4. API keys should be stored in environment variables


## Best Practices

1. never write your api key as the variable 

`const apikey= "";`  ❌ WRONG

`const apikey= process.env.API_KEY;`  ✅ RIGHT

```python
import os

api_key = os.getenv("OPENAI_API_KEY")
```

## What are environment variables ?

Environment variables are the variables that are stored in the environment where the application is running


# HTTP Requests and JSON
  the llm api communicates through the hyper text transfer protocol http

```
GET     Get information
POST    Send information
PUT     Update information
DELETE  Delete information 
```
   

# 3. Authentication

Authentication proves who you are.

Usually the key goes into an HTTP header:

Authorization: Bearer YOUR_API_KEY

Without valid authentication, the API normally rejects your request.

# 4. Request and response structure

## Request:

You -> API
     model
     messages
     parameters

## Response:

API -> You
     generated content
     model information
     usage information

You need to learn how to inspect both structures because different providers organize responses differently.

# 5. Models and providers

A provider hosts or serves models.

Examples:
```
OpenAI       -> various OpenAI models
Google       -> Gemini models
Anthropic    -> Claude models
OpenRouter   -> access to models from multiple providers
Ollama       -> local models
```
A model determines the capabilities, quality, speed, context window, and often cost.

# 6. Temperature and max tokens

Temperature controls randomness.

0.0 -> predictable
0.5 -> balanced
1.0 -> more creative

For factual or structured tasks, lower temperature is usually preferable.

Max tokens limits how much the model can generate.

max_tokens = 100

means approximately that much output is allowed.

Your first goal today is to understand this complete flow:
 ```
Python
  ↓
HTTP request
  ↓
Authentication
  ↓
Provider
  ↓
Model
  ↓
LLM processing
  ↓
JSON response
  ↓ 
Python

Then we should implement each part manually with Python before using an SDK. ```

# 7. Python SDK 

An SDK (Software Development Kit) is a collection of tools, libraries, and code examples that help developers build applications for a specific platform, system, or service.

For LLM APIs, the SDK is a Python library that handles:
- HTTP requests
- Authentication
- JSON parsing
- Model selection
- Parameter configuration

This allows you to use the LLM API in your Python code without manually writing HTTP requests.





## 1.Client Initialization 

  The client initialization involves setting up the connection between your application and the LLM API.

  ``` 
  import os
  from openai import OpenAI

  client= OpenAI(
    base_url="----",
    api_key=process.env.OPENROUTER_API_KEY
  )


  ## 2.Chat and Response API

 here is the code snippet of which we can chat with the ai  models

   ```
response=client.chat.completions.create(
  model="openai/gpt-4.1-mini",
  temperature=0.7,
  max_tokens=100,
  messages=[
    {"role":"system","content":"you are a helpful assistant"},
    {"role":"user","content":"Explain how LLMs work in simple terms"}
  ]
)

print(response.choices[0].message.content)
```

## 3. Message structure

For chat style APIs, messages contain a role and content.
```
messages = [
    {"role": "system", "content": "You are a helpful teacher."},
    {"role": "user", "content": "Explain recursion."}
]
```
Each message tells the model who is speaking and what they said.

## 4. System, user, assistant
system     = instructions for model behavior
user       = user's request
assistant  = model's previous response

Example conversation:
```
messages = [
    {"role": "system", "content": "Answer simply."},
    {"role": "user", "content": "What is Python?"},
    {"role": "assistant", "content": "Python is a programming language."},
    {"role": "user", "content": "Why is it popular?"}
]
```
This is how multi-turn conversations work.

## 5. Streaming

Normally you wait for the complete response.

Streaming sends the response piece by piece.
```
stream = client.responses.create(
    model="gpt-5",
    input="Explain AI engineering.",
    stream=True
)

for event in stream:
    print(event)
```

This is important for chat applications because users see text appearing immediately.

## 6. Error handling

Never assume an API call succeeds.
```
try:
    response = client.responses.create(
        model="gpt-5",
        input="Hello"
    )
    print(response.output_text)

except Exception as e:
    print(f"API error: {e}")
```
In production you later learn specific handling for authentication errors, rate limits, timeouts, invalid requests, and provider failures.
    
## 3. Core LLM API capabilities

### 1. Text generation

The basic operation. You send instructions and receive generated text.

```python
response = client.responses.create(
    model="gpt-5",
    input="Explain recursion simply."
)

print(response.output_text)
```

Master prompts, parameters, response parsing, and streaming.

### 2. Multi turn conversations

The model does not automatically remember previous API calls. You provide conversation history.

```python
messages = [
    {"role": "user", "content": "I am learning Python."},
    {"role": "assistant", "content": "Great. What are you learning?"},
    {"role": "user", "content": "Functions."}
]
```

Understand conversation state and context limits.

### 3. Structured JSON output

Instead of unreliable text, make the model return a predictable structure.

```json
{
  "name": "Siraj",
  "score": 95
}
```

Learn JSON Schema, validation, and handling malformed responses.

### 4. Function or tool calling

The LLM decides when your application should execute a function.

```text
User
 ↓
LLM
 ↓
Tool call: get_weather()
 ↓
Your Python function
 ↓
Result returned to LLM
 ↓
Final answer
```

This is fundamental for agents.

### 5. Vision APIs

Send an image together with instructions.

```text
Image + prompt
      ↓
     LLM
      ↓
Description / analysis / extraction
```

Learn image URLs, base64 images, document images, and vision limitations.

### 6. Token usage

Tokens are pieces of text processed by the model.

You need to understand:

```text
Input tokens
Output tokens
Total tokens
Context window
```

Token usage affects cost, latency, and context management.

### 7. Model selection

Do not always use the most powerful model.

Choose based on:

```text
Quality
Cost
Speed
Context length
Reasoning ability
Tool support
Vision support
Availability
```

For AI engineering, the goal is not simply calling an LLM. It is choosing and controlling the right model for each task.
    