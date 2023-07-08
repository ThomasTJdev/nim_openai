# OpenAI API


Basic API handling for openAI.

Uses the specification from: [https://beta.openai.com/docs/api-reference/introduction](https://beta.openai.com/docs/api-reference/introduction)


## Changelog

### v1.0.0
After GTP4 the API has breaking changes. This package still supports the legacy
calls, but the calling proc has changed.

**Endpoint**
Default openAI endpoint changed to support GPT4. All call-procs now includes an optional `openAIendpoint` parameter.

```nim
const
  urlCompletionLegacy = "https://api.openai.com/v1/completions"
  urlCompletion = "https://api.openai.com/v1/chat/completions"
```

```nim
proc aiPrompt*(apiKey, prompt: string, maxTokens = 30, openAIendpoint = urlCompletion): JsonNode =
```

**Prompt options**
The main `aiCreateRequest` which formats the API-call has breaking changes. If
you still use < GTP4, you need to specify the `openAIendpoint = "legacy-call-url"`.

If you are using >= GTP4 you can rely on the default settings.




## Authorization

You need an API key to use the API. The API key is used in the headers of the request.

```nim
let headers = aiHeaders(apiKey)
# Authorization: Bearer sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Environment variables

OpenAI is apparently in favor of saving keys to environmental variables.

If that's also your cup of tea, you can use the following:

```bash
# On linux:
export openAIKey="sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

```nim
import std/os
echo getEnv("openAIKey")
# sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## Results

All results are returned as a `JsonNode` object. That requires you to import
nim's standard json library.

```nim
import std/json
```


## Basic request

```nim
import
  std/json,
  openai

let resp = aiPrompt(apiKey, "Why is Nim-lang the best programming language?", maxTokens = 50)

echo resp["choices"][0]["message"]["content"]

# Legacy:
# echo resp["choices"][0]["text"]

# Nim-lang is the best programming language because it is a powerful, statically typed, compiled language that is designed to be fast, efficient, and expressive. It has a simple syntax that is easy to learn and understand, and it is
```

## Custom request

### Current

```nim
import
  std/json,
  openai

let
  envKey = getEnv("openAIKey")
  question = "Why is Nim-lang the best programming language?"
  max_tokens = 100
  n = 3       # number of choices to return

let req = aiCreateRequest(prompt = question, max_tokens = max_tokens, n = n)
check req == """{"model":"gpt-4","messages":[{"role":"system","content":"Why is Nim-lang the best programming language?"}],"temperature":0.0,"top_p":1,"n":3,"max_tokens":100,"presence_penalty":0,"frequency_penalty":0}"""

let resp = aiGetSync(envKey, req)

check resp["choices"].len() == 3

echo resp["choices"][1]["message"]["content"]

# Whether a language is \"the best\" is subjective and depends largely on the task at hand, personal preference, or specific project requirements. However, Nim-lang possesses some qualities that can make it stand out for certain situations:\n\n1. Efficiency: Nim compiles to C, C++, and JavaScript, offering efficient performance close to what you would get from these languages.\n\n2. Expressiveness: Nim allows programmers to write high-level code that is both human-understandable and machine-optimized. This balances readability
```

### Legacy

```nim
import
  std/json,
  openai

let
  envKey = getEnv("openAIKey")
  question = "Why is Nim-lang the best programming language?"
  max_tokens = 100
  n = 3       # number of choices to return
  best_of = 5 # number of completion (must be higher than n)

let req = aiCreateRequest(envKey, prompt = question, max_tokens = max_tokens, n = n, best_of = best_of)
check req == """{"model":"text-davinci-003","prompt":"Why is Nim-lang the best programming language?","temperature":0,"max_tokens":100,"top_p":1,"n":3,"presence_penalty":0,"frequency_penalty":0,"best_of":5}"""

let resp = aiGetSync(envKey, req)
check resp["choices"].len() == 3

echo resp["choices"][1]["text"]

# Nim-lang is the best programming language because it is a powerful, statically typed, compiled language that is designed to be fast, efficient, and expressive. It has a simple syntax, a powerful macro system, and a modern type system. Nim-lang also has a great community of developers who are constantly working to improve the language and make it even better. Additionally, Nim-lang is open source and free to use, making it an attractive option for developers.
```


# Public procedures

## aiHeaders

```nim
proc aiHeaders*(apiKey: string): HttpHeaders =
```

Authorization: Bearer


____

## aiGetAsync*

```nim
proc aiGetAsync*(client: AsyncHttpClient, url: string, headers: HttpHeaders, body: string): Future[JsonNode] {.async.} =
```

API: Async with custom client


____

## aiGetAsync*

```nim
proc aiGetAsync*(apiKey, body: string, openAIendpoint = urlCompletion): Future[JsonNode] {.async.} =
```

API: Async with one-time client


____

## aiGetSync*

```nim
proc aiGetSync*(client: HttpClient, url: string, headers: HttpHeaders, body: string): JsonNode =
```

API: Sync with custom client


____

## aiGetSync*

```nim
proc aiGetSync*(apiKey, body: string, openAIendpoint = urlCompletion): JsonNode =
```

API: Sync with one-time client


____

## aiCreateRequest*

```nim
proc aiCreateRequestLegacy*(
    prompt = "What is nim-lang",
    model = "gpt-4",
    role = "system",
    temperature = 0.0,
    maxTokens = 30,
    top_p = 1,
    n = 1,
    stop = "",
    presence_penalty = 0,
    frequency_penalty = 0,
    user = ""
): string =
```

Create request body


____

## aiPrompt*

```nim
proc aiPrompt*(apiKey, prompt: string, maxTokens = 30, openAIendpoint = urlCompletion): JsonNode =
```

Basic prompt


____

