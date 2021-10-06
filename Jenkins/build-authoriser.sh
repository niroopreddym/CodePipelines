#!/usr/bin/env bash

set -e

if [ -d "authsource" ]; then rm -Rf authsource; fi

echo 'authsource executed...'
mkdir -p authsource
git clone https://github.com/emisgroup/authoriser.git authsource
cp ../infrastructure/auth/access_rules.json authsource/src/lambda_function/access_rules.json

cd authsource
make build-lambda
ls