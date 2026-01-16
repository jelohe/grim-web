# Grimorio

Grimorio is a note-taking web application that allows users to write, store, link and search through their notes. It is built with Phoenix and Elixir.



## Features


### Rich Notes

Grimorio supports Markdown, allowing you to write [external links](https://www.example.com) and [internal links](example note name) to your own notes


### Tags

Tags are what allow you to group notes together, to search specific topics.
You will need to manually add tags to your notes if you want to use them.


### Privacy

A user account is required to protect your notes. Users can only see their own notes.
A possible future feature is the ability to generate **temporary public links** to allow anonymous viewing of specific notes.


## Development

* Run `mix setup` to install and set up dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


##### Dev Hints

* As of now, most of the logic resides in the `scrolls` LiveView.
* Auth is managed through [Phoenix GenAuth](https://hexdocs.pm/phoenix/mix_phx_gen_auth.html)
* The content is stored in a PostgreSQL db with a simple schema (see `priv/repo/migrations/`)
