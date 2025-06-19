# Tunez

Clone of sevenseacats's `tunez`, following the [Ash Framework](https://pragprog.com/titles/ldash/ash-framework/) book.

## Important Changes / Errata

* Changed the tool-versions erlang / elixir due to hex being unable to pull `inflex`

## To figure out

* Something about standalone tailwind causes "sh: 1: watchman: not found"

## Personal / Opinionated Changes

* Added docker compose for postgres to sandbox the database
* Added the following deps
```
      # generating docs
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},
      # SAST
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      # spec check
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      # opinionated styler
      {:quokka, "~> 2.7", only: [:dev, :test], runtime: false},
```
