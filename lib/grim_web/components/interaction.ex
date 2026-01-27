defmodule GrimWeb.Interaction do
  use Phoenix.Component
  use GrimWeb, :html

  def interaction(assigns) do
    ~H"""
    <button
      id="create-button"
      phx-click=""
      class="interaction w-full p-6 h-20 text-lg text-fg2 border-b-1 border-bg3 text-left font-bold truncate">
      <span class="">{@text}</span>
      <.icon 
        name={@icon}
        class="w-7 h-7 -mt-1 ml-2"
      />
    </button>
    """
  end
end
