
import
  std/asyncdispatch,
  std/httpclient,
  std/json,
  std/strutils


const
  urlCompletionLegacy = "https://api.openai.com/v1/completions"
  urlCompletion = "https://api.openai.com/v1/chat/completions"




proc aiHeaders*(apiKey: string): HttpHeaders =
  ## Authorization: Bearer
  return newHttpHeaders({"Content-Type": "application/json", "Authorization": "Bearer " & apiKey})




proc aiGetAsync*(client: AsyncHttpClient, url: string, headers: HttpHeaders, body: string): Future[JsonNode] {.async.} =
  ## API: Async with custom client
  let
    response = await client.request(url, headers = headers, body = $body, httpMethod = HttpPost)
  return parseJson(await response.body)

proc aiGetAsync*(apiKey, body: string, openAIendpoint = urlCompletion): Future[JsonNode] {.async.} =
  ## API: Async with one-time client
  return await aiGetAsync(newAsyncHttpClient(), openAIendpoint, aiHeaders(apiKey), body)




proc aiGetSync*(client: HttpClient, url: string, headers: HttpHeaders, body: string): JsonNode =
  ## API: Sync with custom client
  let
    response = client.request(url, headers = headers, body = $body, httpMethod = HttpPost)
  return parseJson(response.body)

proc aiGetSync*(apiKey, body: string, openAIendpoint = urlCompletion): JsonNode =
  ## API: Sync with one-time client
  return aiGetSync(newHttpClient(), openAIendpoint, aiHeaders(apiKey), body)



proc aiCreateRequest*(
    prompt = "What is nim-lang",
    model = "gpt-4",
    role = "system",
    temperature = 1.0,
    maxTokens = 30,
    top_p = 1,
    n = 1,
    stop = "",
    presence_penalty = 0,
    frequency_penalty = 0,
    user = "",
    multipleMessages: seq[JsonNode] = @[]
  ): string =
  ## Create request body

  var
    body = %*
      {
        "model": model,
        "messages": [{
          "role": role,
          "content": prompt,
        }],
        "temperature": temperature,
        "top_p": top_p,
        "n": n,
        "max_tokens": maxTokens,
        "presence_penalty": presence_penalty,
        "frequency_penalty": frequency_penalty,
      }

  if multipleMessages.len > 0:
    body["messages"] = %* multipleMessages
  if stop != "":
    body["stop"] = %* stop
  if user != "":
    body["user"] = %* user

  return $body


proc aiCreateRequestLegacy*(
    prompt = "What is nim-lang",
    model = "text-davinci-003",
    suffix = "",
    temperature = 0.0,
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
  ## Create request body

  var
    body = %* {
      "model": model,
      "prompt": prompt,
      "temperature": temperature,
      "max_tokens": maxTokens,
      "top_p": top_p,
      "n": n,
      "presence_penalty": presence_penalty,
      "frequency_penalty": frequency_penalty,
      "best_of": best_of,
    }

  if suffix != "":
    body["suffix"] = %* suffix
  if logprobs != "":
    body["logprobs"] = %* parseInt(logprobs)
  if stop != "":
    body["stop"] = %* stop
  if logit_bias != "":
    body["logit_bias"] = %* logit_bias
  if user != "":
    body["user"] = %* user

  return $body



proc aiPrompt*(apiKey, prompt: string, maxTokens = 30, openAIendpoint = urlCompletion): JsonNode =
  ## Basic prompt
  let
    body =
      if openAIendpoint == urlCompletion:
        aiCreateRequest(prompt = prompt, maxTokens = maxTokens)
      else:
        aiCreateRequestLegacy(prompt = prompt, maxTokens = maxTokens)

  return aiGetSync(newHttpClient(), openAIendpoint, aiHeaders(apiKey), body)

