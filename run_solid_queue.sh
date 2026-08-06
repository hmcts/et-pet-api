#!/bin/bash

# Compatibility entry point for deployed charts that predate the provider-neutral name.
exec "$(dirname "$0")/run_queue_worker.sh" "$@"
