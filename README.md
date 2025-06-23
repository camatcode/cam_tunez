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
* TODO: Double-check the email confirmation page

### Personal / Style / Opinionated Changes

* **Infrastructure**: Added docker compose for postgres to sandbox the database
* **TDD Preference**: Created ExUnit tests instead of running examples in IEX (put under `cam tests`)
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

* Something about standalone tailwind causes "`sh: 1: watchman: not found`"
  * Despite Meta warning against it, your best bet is to use the `watchman` package found from your normal `sudo apt-get install watchman`
  * *Trust me*: All other options are a nightmare



## Thoughts / Pitfalls / Review

### Chapter 1

* 🤔 *D* in [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) usually stands for *delete*
  * See this Issue from Zach Daniel to learn more: https://github.com/ash-project/ash/issues/165

### Chapter 2 

* (ᵕ—ᴗ—) : On page 42, when I was testing out the album form, I thought *hmm those albums aren't showing up right*, 
  * went on a side-quest with show_live, 
  * discovered the `load: albums` on my own, 
  * then literally next page said, to do exactly that.
  * That's my own damn fault for not reading carefully - but it was validating I had the right idea.
 
### Chapter 3

* 😎 [Preparations](https://hexdocs.pm/ash/preparations.html) are super nice

### Chapter 4

* 👌 I love the light touch of `mix ash.extend`
  *  I **despise** having to remove things from generated code, perfectly fine with adding things after. It doesn't get in the way.

### Chapter 5

* TIL: IEx's `v()`
* No end of trouble with the CSS styling on the sign-in and magic link pages, will have to come back to it.

### Chapter 6

* I have many complex thoughts on this chapter (that's okay, it's a complex topic!) - holding off until I finish the book

<!-- use a process dictionary instead of always saying *this is my actor* -->


<!-- page 65 -->
