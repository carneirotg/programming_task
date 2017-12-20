# Overview

A RESTful application to handle requests from Sensors, calculating them average acceleration and
writing to an ElasticSearch server.

# Requirements
  * Erlang >=18
  * Elixir >= 1.4
  * Phoenix >= 1.3

# Configuration
The `Port` settings is inside `config/dev.exs` and the
ElasticSearch and HostName configurations are inside `config/config.exs`

# Usage
  * Install dependencies with `mix deps.get`
  * If you wish to test it also run an ElasticSearch server. Ex: `docker run -p 9200:9200 -it --rm elasticsearch:5.1.2`
  * Run `mix phx.server`
  The application will be available at `http://localhost:4001`

# Running Unit Tests
Run `mix test` to run all controller tests.

# Testing
Run `curl -v -XPOST 'http://localhost:4001/api/measurements' -H 'Content-Type: application/json'  '{ "createdTime": "2017-10-06T19:31:54.942000Z", "sensorId": "AGT0001", "data": [-1,0.7,0.3], "dataType": "accelerometer", "dataUnit": "m/s^2" }'`
