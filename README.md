# Tunez

Clone of sevenseacats's `tunez`, following the [Ash Framework](https://pragprog.com/titles/ldash/ash-framework/) book.

## Table of Contents

* [Changes](#changes)
  * [Important Changes](#important-changes--possible-errata)
  * [To Figure Out](#to-figure-out)
  * [Personal / Style / Opinionated](#personal--style--opinionated-changes)
* [Thoughts](#thoughts--pitfalls--review)

## Changes 

### Important Changes / Possible Errata

(empty)

### To figure out

* Changed the tool-versions erlang / elixir due to hex being unable to pull `inflex` (this might be something to do with my local hex?)
* Something about standalone tailwind causes "`sh: 1: watchman: not found`" (probably important: OS is Linux Mint)

### Personal / Style / Opinionated Changes

* Added docker compose for postgres to sandbox the database
* Created ExUnit tests instead of running examples in IEX under "cam tests"
* Added the following deps

```
      # I prefer mix docs over IEx's `h`
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},
      # static code analysis
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      # spec check
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      # opinionated styler
      {:quokka, "~> 2.7", only: [:dev, :test], runtime: false},
      # for fuzzing input to my added tests
      {:faker, "~> 0.18.0", only: :test},
```


## Thoughts / Pitfalls / Review

* **Pitfall**: At least in en-US, *D* in [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) stands for *delete*
  * See this Issue from Zach Daniel to learn more: https://github.com/ash-project/ash/issues/165
* **Pitfall**: On page 42, when I was testing out the album form, I thought *hmm those albums aren't showing up right*, 
went on a side-quest with show_live, discovered the `load: albums` on my own, then literally page 43 said, to do exactly that.
  * That's my own damn fault for not reading carefully - but it was validating I had the right idea.
