#!/bin/bash

if [ -z "$DEBUG" ]; then
    echo "Please set debug"
    exit 1
fi

if ["$DEBUG" = 1 ]; then
    export NODE_ENV=development
    npm start
else
    export NODE_ENV=production
    npm run build
    npx serve -s build -l 3000
fi