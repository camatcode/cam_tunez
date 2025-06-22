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


* ‼️ (~ page 54 / Chp 2) When defining the `previous_names` logic for artist, you gotta remove the `defaults` for `:update` (e.g to `defaults [:create, :read, :destroy]`) 

### To figure out

* Changed the tool-versions erlang / elixir due to hex being unable to pull `inflex` (this might be something to do with my local hex?)
* Something about standalone tailwind causes "`sh: 1: watchman: not found`" (probably important: OS is Linux Mint)

### Personal / Style / Opinionated Changes

* **Infrastructure**: Added docker compose for postgres to sandbox the database
* **Preference**: Created ExUnit tests instead of running examples in IEX (put under `cam tests`)
* **Style**: `render(assigns)` functions go at the bottom - I have no clue where I picked this style up, but I can't live without it.
* **Helpers**: Added the following deps

```
      # I prefer `mix docs` over IEx's `h`
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

### Chapter 1

* ⚠️:  *D* in [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) usually stands for *delete*
  * See this Issue from Zach Daniel to learn more: https://github.com/ash-project/ash/issues/165

### Chapter 2 

* ⚠️ : On page 42, when I was testing out the album form, I thought *hmm those albums aren't showing up right*, 
  * went on a side-quest with show_live, 
  * discovered the `load: albums` on my own, 
  * then literally next page said, to do exactly that.
  * That's my own damn fault for not reading carefully - but it was validating I had the right idea.
 
### Chapter 3

* 😎 [Preparations](https://hexdocs.pm/ash/preparations.html) are super nice

### Chapter 4

* 😎 I love the light touch of `mix ash.extend`
  *  I **despise** having to remove things from generated code, perfectly fine with adding things after. It doesn't get in the way.

<!-- page 65 -->
