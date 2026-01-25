defmodule GrimWeb.ScrollList do
  use Phoenix.Component

  def scroll_list(assigns) do
    ~H"""
    <ul class="border-base-200 border-b-1 border-t-1 divide-base-200 grid divide-y-1">
      <%= for scroll <- @scrolls do %>
        <% base_class =
          "hover:bg-neutral/[40%] px-2 py-2 text-ellipsis text-nowrap w-full min-w-0 truncate cursor-pointer "

        selected_class = "text-primary-content bg-neutral font-bold" %>
        <li
          phx-click="open_scroll"
          phx-value-id={scroll.id}
          bg-neutral
          class={
            base_class <> (if scroll.id == @selected.id, do: selected_class, else: "")}
        >
          {scroll.name}
        </li>
      <% end %>
    </ul>
    """
  end
end
