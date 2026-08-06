#!/bin/bash

exec env WEB_CONCURRENCY=0 bin/rails server --binding 0.0.0.0 --port "${PORT:-8080}"
