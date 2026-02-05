defmodule GrimWeb.ScrollList do
  use Phoenix.Component
  import GrimWeb.Interaction

  attr :scrolls, :list, default: []
  attr :selected, :map, default: []

  def scroll_list(assigns) do
    ~H"""
    <ul class="grid flex-1 overflow-y-auto min-h-0">
      <%= for scroll <- @scrolls do %>
        <% base_class =
          "hover:brightness-100 h-20 text-nowrap w-full min-w-0 truncate cursor-pointer font-light "

        selected_class =
          "bg-bg3" %>

        <li
          phx-click="open_scroll"
          phx-value-id={scroll.id}
          class={
            base_class <> (if scroll.id == @selected.id, do: selected_class, else: "")}
        >
          <.interaction class="h-full w-full text-left px-6">
            <p class="truncate text-sm text-ellipsis mt-1 font-lg font-bold transition-all break-words brightness-80">
              {scroll.name}
            </p>
            <p class="truncate text-sm text-ellipsis mt-1 brightness-80 transition-all break-words">
              {scroll.content}
            </p>
          </.interaction>
        </li>
      <% end %>
    </ul>
    """
  end
end
