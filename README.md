# Table

A virtual table-top for basic roleplaying games.

## Requirements

- Ruby 2.6.4
- Yarn
- Postgres

## Setup

```
$ bin/setup
```

## Priming

Get started with some helpful data in development:

```
$ rails dev:prime
```

## Testing

Tests are handled by rspec:

```
$ rails spec
```

## Linting

Run linting before merging. Linting for ruby and scss is setup:

```
$ rails lint      # Runs lint:ruby and lint:scss
$ rails lint:ruby # Runs rubocop
$ rails lint:scss # Rubs scss-lint
```
