defmodule GrimWeb.ScrollList do
  use Phoenix.Component

  def scroll_list(assigns) do
    ~H"""
    <ul class="grid">
      <%= for scroll <- @scrolls do %>
        <% base_class =
          "text-fg2 hover:text-fg1 px-6 h-20 text-nowrap w-full min-w-0 truncate cursor-pointer text-lg font-light "

        selected_class =
          "bg-bg3 !font-bold" %>
        <li
          phx-click="open_scroll"
          phx-value-id={scroll.id}
          bg-neutral
          class={
            base_class <> (if scroll.id == @selected.id, do: selected_class, else: "")}
        >
          <p class="mt-3 truncate text-ellipsis">{scroll.name}</p>
          <p class="truncate text-ellipsis mt-1 font-medium text-xs transition-all break-words">{scroll.content}</p>
        </li>
      <% end %>
    </ul>
    """
  end
end
