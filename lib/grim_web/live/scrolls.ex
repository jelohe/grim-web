defmodule GrimWeb.Scrolls do
  use GrimWeb, :live_view

  import GrimWeb.ScrollList
  import GrimWeb.Interaction

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <!-- SIDEBAR -->
      <div class="flex flex-1 h-[calc(100vh)]">
        <aside
          id="sidebar"
          class="w-128 h-screen flex flex-col bg-bg2 border-r-1 border-bg3 transition-all duration-300"
        >
          <!-- Header -->
          <.interaction
            id="create-button"
            class="font-bold border-b-1 border-bg3 h-20 p-6 w-full text-left text-lg truncate shrink-0"
            phx-click="new_scroll"
            text={gettext("Create note")}
            icon="hero-document-plus"
          />
          <div class="flex-1 overflow-y-auto min-h-0">
            <.scroll_list selected={@scroll} scrolls={@scrolls} />
          </div>
          <!-- Footer -->
          <div class="h-11 shrink-0 flex justify-between border-t-1 border-bg3 text-fg2 mb-2">
            <.link href={~p"/users/settings"}>
              <.interaction text={gettext("Settings")} icon="hero-cog-6-tooth" class="p-3" />
            </.link>
            <.link href={~p"/users/log-out"} method="delete">
              <.interaction
                phx-click="logout"
                text={gettext("Sign out")}
                icon="hero-arrow-left-start-on-rectangle"
                class="p-3 hover:text-warning"
              />
            </.link>
          </div>
        </aside>
        <.interaction
          id="sidebar-btn"
          class="px-3 h-full bg-bg2 border-l-1 border-bg3 cursor-w-resize"
          onclick="toggleSidebar()"
          icon="hero-bars-3-bottom-left"
        />
        
    <!-- FORM -->
        <div
          id="create-form"
          class="flex flex-col w-full"
        >
    <!-- FORM -->
          <.form
            class="flex-1 flex flex-col"
            as={:scroll}
            for={@form}
            id="scroll-editor"
            phx-change="autosave_scroll"
            phx-submit="autosave_scroll"
          >
            <div class="flex w-full justify-between px-8 py-6 pr-2 border-b-1 border-bg2">
              <.input
                phx-debounce="500"
                class="flex-1 h-9 focus:outline-none text-3xl font-bold box-border pr-4 min-w-0 w-full truncate text-ellipsis border-box"
                field={@form[:name]}
                placeholder={gettext("New note ...")}
              />
              <.interaction
                icon="hero-trash"
                class="pt-1 pr-4 hover:text-warning"
                phx-click="remove_scroll"
              />
            </div>
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

  @impl true
  def handle_event("logout", _params, socket) do
    {:noreply,
     socket
     |> push_navigate(to: ~p"/users/log-out", method: :delete)}
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
    %Grim.Scroll{}
  end
end
