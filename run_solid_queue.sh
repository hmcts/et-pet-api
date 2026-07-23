#!/bin/bash

exec bin/rails server --binding 0.0.0.0 --port "${PORT:-8080}"
