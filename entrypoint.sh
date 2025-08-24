#!/bin/bash
if [ "$1" = "" ]; then
  jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=''
else
  exec "$@"
fi

