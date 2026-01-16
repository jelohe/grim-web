defmodule GrimWeb.UserLive.Scrolls do
  use GrimWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex">
        <div class="w-1/4">
          <.scroll_list scrolls={@scrolls} />
          <button class="btn" id="create-button" phx-hook="NewScroll">
            o open e lipu sin
          </button>
        </div>

        <div id="create-form" class="hidden mb-8 w-3/4">
          <.form as={:scroll} for={@create_form} id="new-scroll" phx-submit="create-scroll">
            <.input
              class="h-9 border-color-red-400 focus:outline-none text-4xl font-bold"
              field={@create_form[:name]}
              value="lipu sin"
            />
            <.input
              field={@create_form[:content]}
              type="textarea"
              class="w-full h-100 resize-none border-0 focus:outline-none text-xl"
            />
            <button class="btn">o pali</button>
          </.form>
        </div>

        <%= if @selected do %>
          <div id="update-form" class="mb-8 w-3/4">
            <.form as={:scroll} for={@create_form} id="update_scroll" phx-submit="update_scroll">
              <.input field={@create_form[:name]} value={@selected.name} />
              <.input type="hidden" field={@create_form[:id]} value={@selected.id} />
              <.input
                field={@create_form[:content]}
                type="textarea"
                class="w-full h-100 resize-none border-1"
                value={@selected.content}
              />
              <button class="btn">o ante</button>
            </.form>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  def scroll_list(assigns) do
    ~H"""
    <ul class="border-base-200 border-r-1 divide-base-200 grid divide-y-1 overflow-hidden">
      <%= for scroll <- @scrolls do %>
        <li phx-click="open_scroll" phx-value-id={scroll.id} class="">
          <%= scroll.name %>
        </li>
      <% end %>
    </ul>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    scrolls = Grim.Repo.preload(user, :scrolls).scrolls
    create_form = %Grim.Scroll{}
                  |> Ecto.Changeset.change()
                  |> to_form()

    {:ok, assign(
      socket,
      scrolls: scrolls,
      selected: nil,
      create_form: create_form,
      trigger_submit: false
    )}
  end

  @impl true
  def handle_event("open_scroll", %{"id" => selected_id}, socket) do
    {id, _} = Integer.parse(selected_id)
    selected = socket.assigns.scrolls
               |> Enum.find_value(fn v -> if v.id == id, do: v end)

    {:noreply, assign(
      socket,
      selected: selected
    )}
  end

  def handle_event("update_scroll", %{"scroll" => scroll_params}, socket) do
    %{"id" => id_param} = scroll_params
    {id, _} = Integer.parse(id_param)
    user = socket.assigns.current_scope.user
    scrolls = Grim.Repo.preload(user, :scrolls).scrolls
    index = scrolls |> Enum.find_index(&(&1.id == id))
    scroll = Enum.at(scrolls, index)

    changeset = Ecto.Changeset.cast(scroll, scroll_params, [:content, :name])

    case Grim.Repo.update(changeset) do
      {:ok, scroll} ->
        {:noreply,
          socket
          |> put_flash(:info, "scroll updated")
          |> assign(:scrolls, List.replace_at(scrolls, index, scroll))
          |> assign(:create_form, to_form(Ecto.Changeset.change(%Grim.Scroll{})))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, create_form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("create-scroll", %{"scroll" => scroll_params}, socket) do
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
          |> assign(:create_form, to_form(Ecto.Changeset.change(%Grim.Scroll{})))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, create_form: to_form(changeset))}
    end
  end
end
