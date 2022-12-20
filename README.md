# OpenAI API


Basic API handling for openAI.

Uses the specification from: [https://beta.openai.com/docs/api-reference/introduction](https://beta.openai.com/docs/api-reference/introduction)



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

echo resp["choices"][0]["text"]

# Nim-lang is the best programming language because it is a powerful, statically typed, compiled language that is designed to be fast, efficient, and expressive. It has a simple syntax that is easy to learn and understand, and it is
```

## Custom request

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
proc aiGetAsync*(apiKey, body: string): Future[JsonNode] {.async.} =
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
proc aiGetSync*(apiKey, body: string): JsonNode =
```

API: Sync with one-time client


____

## aiCreateRequest*

```nim
proc aiCreateRequest*(
    apiKey: string,
    prompt = "What is nim-lang",
    model = "text-davinci-003",
    temperature = 0,
    maxTokens = 30,
    top_p = 1,
    n = 1,
    logprobs = "",
    stop = "",
    presence_penalty = 0,
    frequency_penalty = 0,
    best_of = 1,
    logit_bias = "",
    user = ""
): string =
```

Create request body


____

## aiPrompt*

```nim
proc aiPrompt*(apiKey, prompt: string, maxTokens = 30): JsonNode =
```

Basic prompt


____

