defmodule GrimWeb.Scrolls do
  use GrimWeb, :live_view

  import GrimWeb.ScrollList

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      
    <!-- HEADER -->
      <div class="min-h-11 border-box p-0 m-0 h-11 flex justify-between">
        
    <!-- left -->
        <div>
          <button
            onclick="toggleSidebar()"
            class="px-3 h-full text-base cursor-pointer hover:bg-neutral/[40%]"
          >
            <.icon name="hero-bars-3-bottom-left" class="w-6 h-6" />
          </button>
          <button
            class="h-11 px-4 cursor-pointer text-center hover:bg-neutral/[40%]"
            id="create-button"
            phx-click="new_scroll"
          >
            <.icon name="hero-document-plus" class="w-5 h-5" />
          </button>
        </div>
        
    <!-- right -->
        <%= if (@scroll.id) do %>
          <button
            class="cursor-pointer hover:bg-neutral/[40%] px-4 text-warning float-right"
            phx-click="remove_scroll"
          >
            <.icon name="hero-trash" class="w-5 h-5 -mt-1" />
          </button>
        <% end %>
      </div>
      
    <!-- SIDEBAR -->
      <div class="flex flex-1 h-[calc(100vh-2.75rem)]">
        <aside
          id="sidebar"
          class="w-64 transition-all duration-300 overflow-hidden flex flex-col justify-between"
        >
          <.scroll_list selected={@scroll} scrolls={@scrolls} />
          <div class=" h-11 flex justify-between bg-base-200">
            <.link
              href={~p"/users/settings"}
              method="delete"
              class="p-3 h-full border-box text-base cursor-pointer hover:bg-neutral/[40%]"
            >
              <.icon name="hero-cog-6-tooth" class="w-6 h-6 -mt-2" />
            </.link>
            <.link
              href={~p"/users/log-out"}
              method="delete"
              class="text-warning p-3 h-full border-box text-base cursor-pointer hover:bg-neutral/[40%]"
            >
              <.icon name="hero-arrow-left-start-on-rectangle" class="w-6 h-6 -mt-2" />
            </.link>
          </div>
        </aside>
        
    <!-- FORM -->
        <div
          id="create-form"
          class="border-l-1 border-base-200 w-full flex flex-col"
        >
          <.form
            class="flex-1 flex flex-col"
            as={:scroll}
            for={@form}
            id="scroll-editor"
            phx-change="autosave_scroll"
          >
            <.input
              phx-debounce="500"
              class="h-9 border-y-1 border-base-200 focus:outline-none text-4xl font-bold box-border p-8 min-w-0 w-full"
              field={@form[:name]}
            />
            <.input
              phx-debounce="500"
              field={@form[:content]}
              type="textarea"
              class="m-0 flex-1 p-4 resize-none border-0 focus:outline-none text-base box-border px-8 min-w-0 w-full"
            />
          </.form>
        </div>
      </div>
    </Layouts.app>
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

  def handle_event("remove_scroll", _, socket) do
    scroll = socket.assigns.scroll

    {:ok, _} = Grim.Repo.delete(scroll)

    scrolls =
      socket.assigns.scrolls
      |> Enum.reject(fn sc -> sc.id == scroll.id end)

    case scrolls do
      [first | _] ->
        {:noreply,
         socket
         |> assign(scrolls: scrolls)
         |> assign(scroll: first)
         |> assign(:form, to_form(Ecto.Changeset.change(first)))}

      [] ->
        {:noreply,
         socket
         |> assign(scrolls: [])
         |> assign(scroll: new_empty_scroll())
         |> assign(:form, to_form(Ecto.Changeset.change(new_empty_scroll())))}
    end
  end

  @impl true
  def handle_event("autosave_scroll", %{"scroll" => scroll_params}, socket) do
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
         |> assign(:scroll, updated_scroll)
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
