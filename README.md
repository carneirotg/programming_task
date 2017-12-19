# Overview

A RESTful application to handle requests from Sensors, calculating them average acceleration and
writing to an ElasticSearch server.

# Requirements
  * Erlang >=18
  * Elixir >= 1.4
  * Phoenix >= 1.3

# Configuration
The Port settings is inside `config/dev.exs` and the
ElasticSearch and HostName configurations are inside `config/config.exs`

# Usage
  * Install dependencies with `mix deps.get`
  * If you wish to test it also run an ElasticSearch server. Ex: `docker run -p 9200:9200 -it --rm elasticsearch:5.1.2`
  * Run `mix phx.server`
  The application will be available at `http://localhost:4001`

# Running Tests
Run `mix test` to run all unit tests.
