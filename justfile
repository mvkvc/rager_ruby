help:
    @just --list

setup:
    ./bin/setup

clean-deps:
    rm -rf ../../.bundle

clean-test:
    rm -rf ./test/fixtures/http

clean: clean-deps clean-test

dev:
    ./bin/console

test:
   bundle exec rake test

test-file *args:
    bundle exec ruby -Ilib:test {{args}}

format:
    bundle exec standardrb -x

lint:
    -bundle exec standardrb
    -bundle exec srb tc

fix:
    -bundle exec standardrb -a
    -bundle exec srb tc -a

run file *args:
    bundle exec ruby {{file}} {{args}}

examples:
    #!/usr/bin/env bash
    set -euxo pipefail
    for f in ./examples/*.rb; do
        bundle exec ruby "$f"
    done

ci:
    act --secret-file .env
