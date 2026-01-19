defmodule GrimWeb.UserLive.Scrolls do
  use GrimWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex">
        <div class="w-1/4">
          <button class="btn w-full" id="create-button" phx-click="new_scroll">
            {gettext("Create a note")}
          </button>
          <.scroll_list scrolls={@scrolls} />
        </div>

        <div id="create-form" class="w-3/4 border-l-1 border-base-200">
          <.form
            as={:scroll}
            for={@form}
            id="scroll-editor"
            phx-submit="save_scroll"
          >
            <.input
              class="h-9 border-y-1 border-base-200 focus:outline-none text-4xl font-bold box-border p-8 min-w-0 w-full"
              field={@form[:name]}
            />
            <.input
              field={@form[:content]}
              type="textarea"
              class="h-100 resize-none border-0 focus:outline-none text-base box-border px-8 min-w-0 w-full"
            />
            <button class="btn w-full">
              {gettext("Save")}
            </button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def scroll_list(assigns) do
    ~H"""
    <ul class="border-base-200 border-b-1 border-t-1 divide-base-200 grid divide-y-1">
      <%= for scroll <- @scrolls do %>
        <li
          phx-click="open_scroll"
          phx-value-id={scroll.id}
          class="px-2 py-2 text-ellipsis text-nowrap w-full min-w-0 truncate cursor-pointer"
        >
          {scroll.name}
        </li>
      <% end %>
    </ul>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    Gettext.put_locale(GrimWeb.Gettext, user.locale)

    scrolls = Grim.Repo.preload(user, :scrolls).scrolls
    scroll = List.first(scrolls) || new_empty_scroll()

    form =
      scroll
      |> Ecto.Changeset.change()
      |> to_form()

    {:ok,
     assign(socket,
       scrolls: scrolls,
       scroll: scroll,
       form: form
     )}
  end

  @impl true
  def handle_event("new_scroll", _params, socket) do
    scroll = new_empty_scroll()

    form =
      scroll
      |> Ecto.Changeset.change()
      |> to_form()

    {:noreply,
     assign(
       socket,
       scroll: scroll,
       form: form
     )}
  end

  @impl true
  def handle_event("open_scroll", %{"id" => selected_id}, socket) do
    {id, _} = Integer.parse(selected_id)

    scroll =
      socket.assigns.scrolls
      |> Enum.find_value(fn v -> if v.id == id, do: v end)

    form =
      scroll
      |> Ecto.Changeset.change()
      |> to_form()

    {:noreply,
     assign(
       socket,
       scroll: scroll,
       form: form
     )}
  end

  @impl true
  def handle_event("save_scroll", %{"scroll" => scroll_params}, socket) do
    scope = socket.assigns.current_scope
    user = scope.user
    scroll = socket.assigns.scroll

    case scroll.id do
      nil ->
        create_scroll(scroll_params, user, scope, socket)

      _id ->
        update_scroll(scroll, scroll_params, socket)
    end
  end

  defp create_scroll(params, user, scope, socket) do
    changeset =
      %Grim.Scroll{user_id: user.id}
      |> Grim.Scroll.changeset(params, scope)

    case Grim.Repo.insert(changeset) do
      {:ok, scroll} ->
        {:noreply,
         socket
         |> put_flash(:info, "scroll created")
         |> assign(:scroll, scroll)
         |> assign(:scrolls, [scroll | socket.assigns.scrolls])
         |> assign(:form, to_form(Ecto.Changeset.change(scroll)))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp update_scroll(scroll, params, socket) do
    changeset =
      scroll
      |> Ecto.Changeset.cast(params, [:name, :content])

    case Grim.Repo.update(changeset) do
      {:ok, updated_scroll} ->
        scrolls =
          socket.assigns.scrolls
          |> Enum.map(fn s ->
            if s.id == updated_scroll.id, do: updated_scroll, else: s
          end)

        {:noreply,
         socket
         |> put_flash(:info, "scroll created")
         |> assign(:scroll, scroll)
         |> assign(:scrolls, scrolls)
         |> assign(:form, to_form(Ecto.Changeset.change(scroll)))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp new_empty_scroll do
    %Grim.Scroll{name: gettext("New note ...")}
  end
end
