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

Correct. **Providing context to the model is one of the most important LLM API skills.** It should be explicitly included in your roadmap.

### Context means information you send with the request.

```text
System instructions
        +
Conversation history
        +
User request
        +
Retrieved documents
        +
Tool results
        ↓
      LLM
```

For example:

```python
response = client.responses.create(
    model="gpt-5",
    instructions="You are a Python tutor.",
    input="""
    Previous context:
    The student is learning functions.

    Current question:
    Explain callbacks using a simple example.
    """
)
```

For chat APIs, context commonly comes through `messages`:

```python
messages = [
    {"role": "system", "content": "You are a Python tutor."},
    {"role": "user", "content": "I am learning functions."},
    {"role": "assistant", "content": "Functions allow reusable code."},
    {"role": "user", "content": "Explain callbacks."}
]
```

You need to master **context management** too.

* Conversation history.
* System instructions.
* User context.
* Retrieved RAG documents.
* Tool outputs.
* Context window limits.
* Token budgeting.
* Truncation.
* Summarization.
* Relevant context selection.
* Preventing unnecessary context.

This is actually the foundation for **RAG, agents, memory, and production LLM applications**.

## Production LLM API concepts

These are what separate a simple LLM script from a reliable AI application.

### 1. Timeouts

A timeout prevents your application from waiting forever.

```python
response = client.responses.create(
    model="gpt-5",
    input="Explain RAG.",
    timeout=30
)
```

If the provider takes longer than 30 seconds, your application stops waiting.

Why important.

```text
Your app -> LLM
              ↓
         provider hangs
              ↓
Without timeout -> request stays stuck
With timeout    -> request fails safely
```

You must understand connection timeout, read timeout, total timeout, and choosing reasonable values.

---

### 2. Retries

Sometimes an API fails temporarily.

Examples.

```text
Network failure
Temporary server error
Rate limit
Provider overload
```

Instead of immediately failing, retry.

```python
for attempt in range(3):
    try:
        response = client.responses.create(...)
        break
    except Exception:
        if attempt == 2:
            raise
```

Production systems usually use **exponential backoff**.

```text
Attempt 1 -> immediately
Attempt 2 -> wait 1 second
Attempt 3 -> wait 2 seconds
Attempt 4 -> wait 4 seconds
```

Do not blindly retry every error. Authentication or invalid requests usually will not be fixed by retrying.

---

### 3. Rate limits

Providers limit how frequently you can call their APIs.

For example.

```text
100 requests/minute
1,000,000 tokens/minute
```

Your application may suddenly receive a rate limit error.

You therefore need.

```text
Detect rate limit
      ↓
Wait
      ↓
Retry with backoff
      ↓
Continue
```

Also learn request per minute, token per minute, concurrency limits, and handling `429` responses.

---

### 4. Fallback models

Never assume your primary model will always be available.

```text
Primary model
     ↓ failure
Fallback model
     ↓ failure
Second fallback
     ↓
Error response
```

Example.

```python
models = ["powerful-model", "cheap-model"]

for model in models:
    try:
        response = client.responses.create(
            model=model,
            input="Explain embeddings."
        )
        break
    except Exception:
        continue
```

Real systems choose fallbacks based on failure type, capability, cost, and latency.

---

### 5. Logging

Your AI application should record what happened.

Useful information.

```text
Request ID
Model
Timestamp
Latency
Success/failure
Input tokens
Output tokens
Error type
Tool calls
User request category
```

Example.

```python
import logging

logging.basicConfig(level=logging.INFO)

logging.info("Calling model")
logging.info("Model response received")
```

Never log API keys or sensitive user information.

---

### 6. Cost tracking

Every LLM request can consume money.

Track.

```text
Input tokens
Output tokens
Model price
Total request cost
Daily cost
Monthly cost
Cost per user
Cost per feature
```

Conceptually.

```text
Request
   ↓
Token usage
   ↓
Price calculation
   ↓
Cost record
   ↓
Database / dashboard
```

This lets you discover that one expensive feature is consuming most of your budget.

---

### 7. Async API calls

Normal code waits for one request to finish.

```python
response = client.responses.create(...)
```

Async code allows other work while waiting.

```python
response = await client.responses.create(...)
```

This matters when your application handles many users.

```text
User A -> waiting for LLM
User B -> waiting for LLM
User C -> waiting for LLM

Async server
     ↓
handles all efficiently
```

With FastAPI, async becomes especially important.

### The production flow you should master

```text
User request
     ↓
Validation
     ↓
LLM API call
     ↓
Timeout protection
     ↓
Retry with backoff
     ↓
Rate limit handling
     ↓
Fallback model
     ↓
Response validation
     ↓
Logging
     ↓
Cost tracking
     ↓
Response to user
```

Mastering this flow means you are no longer just learning how to call an LLM. You are learning how to **operate an LLM service reliably in production**.

**5. OpenRouter**

Since you are already using OpenRouter, master:

- [x] Listing models.
- [x] Filtering free models.
- [x] Calling different models through one interface.
- [x] Reading pricing and context limits.
- [x] Handling provider and model errors.