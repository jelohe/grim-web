defmodule GrimWeb.UserLive.Scrolls do
  use GrimWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1 class="text-4xl font-bold">lipu ale</h1>
      <ul class="border-solid border-1 grid divide-y-1 divide-white">
        <%= for scroll <- @scrolls do %>
          <li class=""><%= scroll.name %></li>
        <% end %>
      </ul>

      <h1 class="mt-16 text-4xl font-bold">pali e lipu sin</h1>
      <.form as={:scroll} for={@form} id="new-scroll" phx-submit="save">
        <.input
          field={@form[:name]}
        />
        <.input
          field={@form[:content]}
          type="textarea"
          class="w-full h-100 resize-none"
        />
        <button class="btn">o awen</button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    scrolls = Grim.Repo.preload(user, :scrolls).scrolls
    form = %Grim.Scroll{}
           |> Ecto.Changeset.change()
           |> to_form()

    {:ok, assign(
      socket,
      scrolls: scrolls,
      form: form,
      trigger_submit: false
    )}
  end

  @impl true
  def handle_event("save", %{"scroll" => scroll_params}, socket) do
    scope = socket.assigns.current_scope
    user = scope.user

    changeset = %Grim.Scroll{user_id: user.id}
                |> Grim.Scroll.changeset(scroll_params, scope)

    case Grim.Repo.insert(changeset) do
      {:ok, scroll} ->
        {:noreply,
          socket
          |> put_flash(:info, "scroll created")
          |> assign(:scrolls, [scroll | socket.assigns.scrolls])
          |> assign(:form, to_form(Ecto.Changeset.change(%Grim.Scroll{})))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
