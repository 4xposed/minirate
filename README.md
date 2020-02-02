![Elixir CI](https://github.com/4xposed/minirate/workflows/Elixir%20CI/badge.svg?event=push)

# Minirate

A dead simple distributed rate limiting library in Elixir using Mnesia.

# What is it?

A distributed rate limiter with a focus on readable and well tested code.

The counter is syncronized on all connected nodes

```elixir
iex(test2@127.0.0.1)19> Minirate.check_limit("download", "user_1", 100)
{:allow, 1}
```
```elixir
iex(test1@127.0.0.1)14> Minirate.check_limit("download", "user_1", 100)
{:allow, 2}
```

## Installation

Minirate is availabe as in Hex, just add it to your `mix.exs` file:

```elixir
def deps
  [{:minirate, "~> 0.1"}]
end
```

and add it to your extra applications:
```elixir
def applications do
[
  extra_applications: [:minirate]
]
```

## Configuration

Minirate needs to be configured using Mix.Config.

For example, in `config/config.exs`:

```
config :minirate,
  mnesia_table: :rate_limiter,
  expiry_ms: 60_000
  cleanup_period_ms: 10_000
```

`mnesia_table` specifies which table will Mnesia use to write the counters.
`expiry_ms` specifies the counter life in millisecconds (for example to have rates like x request every 10 seconds, you would set `expiry_ms` to 10_000)
`cleanup_period_ms` specifies how often minirate will clean expired counters from the mnesia database


## Usage

With Minirate you can rate limit any action on your application.

The module `Minirate` the function `check_limit(action_name, identifier, limit)`

An Example:

```elixir
@download_limit 1_000

def download_file(file, user_id) do
  case Minirate.check_limit("download_file", user_id, @download_limit) do
    {:allow, _count} ->
      # Logic to download the file

    {:block, _reason} ->
      # Logic when the limit has been reached

    {:skip, _reason} ->
     # Skip will only happen if there's a problem with your nodes or mnesia setup and a count cannot be determined.
  end
```

## Using Minirate.Plug

`Minirate.Plug` can rate-limit actions in your web application using the ip address of the requester.

You can just put in the pipeline of your web application something like this:

```elixir
plug Minirate.Plug, [action: action, limt: 10_000]
```

or for more flexibilty:
```elixir
plug Minirate.Plug, [action: "custom_action", limt: 10_000] when action == :update or action == :create
```
