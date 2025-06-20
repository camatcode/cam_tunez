# Tunez

Clone of sevenseacats's `tunez`, following the [Ash Framework](https://pragprog.com/titles/ldash/ash-framework/) book.

## Table of Contents

* [Changes](#changes)
  * [Important Changes](#important-changes--possible-errata)
  * [To Figure Out](#to-figure-out)
  * [Personal / Style / Opinionated](#personal--style--opinionated-changes)
* [Thoughts](#thoughts--pitfalls--review)

### Important Changes / Possible Errata

* Changed the tool-versions erlang / elixir due to hex being unable to pull `inflex`

### To figure out

* Something about standalone tailwind causes "sh: 1: watchman: not found" (probably important: OS is Linux Mint)

### Personal / Style / Opinionated Changes

* Added docker compose for postgres to sandbox the database
* Created ExUnit tests instead of running examples in IEX under "cam tests"
* Added the following deps

```
      # for generating docs
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},
      # SAST
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      # spec check
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      # opinionated styler
      {:quokka, "~> 2.7", only: [:dev, :test], runtime: false},
      # for fuzzing input to my added tests
      {:faker, "~> 0.18.0", only: :test},
```


### Thoughts / Pitfalls / Review

* **Pitfall**: At least in en-US, *D* in [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) stands for *delete*
  * I mention it only because it tripped me several times - muscle memory is hard to unlearn 😆