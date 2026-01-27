defmodule GrimWeb.Interaction do
  use Phoenix.Component
  use GrimWeb, :html

  attr :text, :string, default: nil
  attr :icon, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def interaction(assigns) do
    class = [
      "text-fg2",
      "interaction",
      assigns.rest[:class]
    ]

    assigns = assign(assigns, class: class)

    ~H"""
    <button
      class={@class}
      {@rest}
    >
      <div class="interaction-content">
        <%= if (@text) do %>
          <span class="">{@text}</span>
        <% end %>
        {render_slot(@inner_block)}
        <%= if (@icon) do %>
          <.icon
            name={@icon}
            class="w-6 h-6 -mt-1"
          />
        <% end %>
      </div>
    </button>
    """
  end
end
