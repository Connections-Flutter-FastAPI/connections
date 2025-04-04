#!/bin/bash

./bin/activate && uvicorn src.server:app --reload --port 1163 --host 100.97.215.85
