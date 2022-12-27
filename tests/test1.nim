# Copyright Thomas T. Jarløv (TTJ) - ttj@ttj.dk


import
  std/json,
  std/os,
  std/unittest

import
  src/openai



test "environment variables":
  let aiKey = getEnv("openAIKey", "missing key")
  check aiKey != "missing key"



test "wrong apikey":
  let
    aiKey = "missing key"
    resp  = aiPrompt(aiKey, "Why is Nim-lang the best programming language?", 50)

  check resp.hasKey("error") == true
  check resp["error"]["code"].getStr() == "invalid_api_key"
  check resp == """{"error":{"message":"Incorrect API key provided: missing key. You can find your API key at https://beta.openai.com.","type":"invalid_request_error","param":null,"code":"invalid_api_key"}}"""



test "basic call":
  let
    envKey = getEnv("openAIKey")
    resp = aiPrompt(envKey, "Why is Nim-lang the best programming language?", maxTokens = 50)

  check resp.hasKey("error") == false

  check resp.hasKey("id") == true
  check resp.hasKey("object") == true
  check resp.hasKey("created") == true
  check resp.hasKey("model") == true
  check resp["model"].getStr() == "text-davinci-003"
  check resp["usage"]["prompt_tokens"].getInt() == 10
  check resp["usage"]["completion_tokens"].getInt() == 50
  check resp["usage"]["total_tokens"].getInt() == 60

  # {
  #   "id": "cmpl-xxx",
  #   "object": "text_completion",
  #   "created": xxx,
  #   "model": "text-davinci-003",
  #   "choices": [{
  #     "text": "?\n\nNim-lang is the best programming language because it is a powerful, statically typed, compiled language that is designed to be fast, efficient, and expressive. It has a simple syntax that is easy to learn and understand, and it is",
  #     "index": 0,
  #     "logprobs": null,
  #     "finish_reason": "length"
  #   }],
  #   "usage": {
  #     "prompt_tokens": 10,
  #     "completion_tokens": 50,
  #     "total_tokens": 60
  #   }
  # }



test "custom call":
  let
    envKey = getEnv("openAIKey")
    question = "Why is Nim-lang the best programming language?"
    max_tokens = 100

  let req = aiCreateRequest(prompt = question, max_tokens = max_tokens)
  check req == """{"model":"text-davinci-003","prompt":"Why is Nim-lang the best programming language?","temperature":0,"max_tokens":100,"top_p":1,"n":1,"presence_penalty":0,"frequency_penalty":0,"best_of":1}"""

  let resp = aiGetSync(envKey, req)

  check resp.hasKey("error") == false
  check resp.hasKey("object") == true
  check resp["object"].getStr() == "text_completion"

  # {
  #   "id": "cmpl-xxx",
  #   "object": "text_completion",
  #   "created": xxx,
  #   "model": "text-davinci-003",
  #   "choices": [{
  #     "text": "\n\nNim-lang is the best programming language because it is a powerful, statically typed, compiled language that is designed to be fast, efficient, and expressive. It has a simple syntax, a powerful macro system, and a modern type system. Nim-lang also has a great community of developers who are constantly working to improve the language and make it even better. Additionally, Nim-lang is open source and free to use, making it an attractive option for developers.",
  #     "index": 0,
  #     "logprobs": null,
  #     "finish_reason": "stop"
  #   }],
  #   "usage": {
  #     "prompt_tokens": 10,
  #     "completion_tokens": 96,
  #     "total_tokens": 106
  #   }
  # }




test "custom call with multiple choices":
  let
    envKey = getEnv("openAIKey")
    question = "Why is Nim-lang the best programming language?"
    max_tokens = 100
    n = 3       # number of choices to return
    best_of = 5 # number of completion (must be higher than n)

  let req = aiCreateRequest(prompt = question, max_tokens = max_tokens, n = n, best_of = best_of)
  check req == """{"model":"text-davinci-003","prompt":"Why is Nim-lang the best programming language?","temperature":0,"max_tokens":100,"top_p":1,"n":3,"presence_penalty":0,"frequency_penalty":0,"best_of":5}"""

  let resp = aiGetSync(envKey, req)
  check resp["choices"].len() == 3

  # {
  #   "id": "cmpl-xxx",
  #   "object": "text_completion",
  #   "created": xxx,
  #   "model": "text-davinci-003",
  #   "choices": [{
  #     "text": "\n\nNim-lang is the best programming language because it is a powerful, statically typed, compiled language that is easy to learn and use. It has a modern syntax that is easy to read and understand, and it is highly efficient and fast. Nim-lang also has a great community of developers who are always willing to help out and answer questions. Additionally, Nim-lang has a wide range of libraries and tools that make it easy to develop applications quickly and efficiently.",
  #     "index": 0,
  #     "logprobs": null,
  #     "finish_reason": "stop"
  #   }, {
  #     "text": "\n\nNim-lang is the best programming language because it is a powerful, statically typed, compiled language that is designed to be fast, efficient, and expressive. It has a simple syntax, a powerful macro system, and a modern type system. Nim-lang also has a great community of developers who are constantly working to improve the language and make it even better. Additionally, Nim-lang is open source and free to use, making it an attractive option for developers.",
  #     "index": 1,
  #     "logprobs": null,
  #     "finish_reason": "stop"
  #   }, {
  #     "text": "\n\nNim-lang is the best programming language because it is a powerful, statically typed, compiled language that is designed to be fast, efficient, and expressive. It has a simple syntax, a powerful macro system, and a modern type system. Nim-lang also has a great community of developers who are constantly working to improve the language and make it even better. Additionally, Nim-lang is open source and free to use, making it an attractive option for developers.",
  #     "index": 2,
  #     "logprobs": null,
  #     "finish_reason": "stop"
  #   }],
  #   "usage": {
  #     "prompt_tokens": 10,
  #     "completion_tokens": 480,
  #     "total_tokens": 490
  #   }
  # }