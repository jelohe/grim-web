defmodule GrimWeb.Scrolls do
  use GrimWeb, :live_view

  alias Grim.Scroll

  import GrimWeb.ScrollList
  import GrimWeb.Interaction
  import Ecto.Query

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <!-- SIDEBAR -->
      <div class="flex flex-1 h-[calc(100vh)]">
        <aside
          id="sidebar"
          class={"#{if @sidebar_open, do: "sidebar-open", else: "sidebar-close"} h-screen flex flex-col bg-bg2 transition-all duration-300 overflow-hidden"}
        >
          <!-- Header -->
          <.interaction
            id="create-button"
            class="font-bold border-bg3 h-18 p-6 w-full text-left text-lg truncate shrink-0"
            phx-click="new_scroll"
            text={gettext("Create note")}
            icon="hero-document-plus"
          />
          <input
            id="search-input"
            class="h-8 px-4 text-sm rounded-full bg-bg1 text-fg2 mt-0 mb-2 mx-2"
            phx-keyup="search_scroll"
            placeholder={gettext("search")}
          />
          <.interaction
            icon="hero-x-circle"
            class="block -mt-9 self-end mr-4"
            onclick="clearSearch()"
            phx-click="all_scrolls"
          />
          <div class="flex-1 overflow-y-auto min-h-0 mt-2">
            <.scroll_list selected={@scroll} scrolls={@scrolls} />
          </div>
          <!-- Footer -->
          <div class="h-11 shrink-0 flex justify-between border-t-1 border-bg3 mb-2">
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
          class="px-3 h-full bg-bg2 cursor-w-resize"
          onclick="toggleSidebar()"
          phx-click="toggle_sidebar"
          icon="hero-bars-3-bottom-left"
        />
        
    <!-- FORM -->
        <div
          id="create-form"
          class={"#{if @sidebar_open, do: "content-open", else: "content-close"} flex flex-col w-full"}
        >
          <.form
            class="flex-1 flex flex-col"
            as={:scroll}
            for={@form}
            id="scroll-editor"
            phx-change="autosave_scroll"
          >
            <div class="flex w-full justify-between px-8 py-6 pr-2 border-b-1 border-bg2">
              <.input
                id="scroll-name"
                phx-hook="Refocus"
                phx-debounce="500"
                class="flex-1 h-9 focus:outline-none text-3xl font-bold box-border pr-4 min-w-0 w-full truncate text-ellipsis border-box text-fg2"
                field={@form[:name]}
                placeholder={gettext("New note ...")}
              />
              <.interaction
                icon="hero-trash"
                class="pt-1 pr-4 hover:text-warning"
                phx-value-id={@scroll.id}
                phx-click="remove_scroll"
              />
            </div>
            <.input
              phx-debounce="500"
              field={@form[:content]}
              type="textarea"
              class="m-0 flex-1 p-4 resize-none border-0 focus:outline-none text-base box-border px-8 min-w-0 w-full text-fg2"
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

    {:ok,
      socket
      |> assign(scrolls: scrolls)
      |> assign(sidebar_open: true)
      |> assign_scroll(scroll)
    }
  end

  @impl true
  def handle_event("new_scroll", _params, socket) do
    {:noreply, assign_scroll(socket, new_empty_scroll())}
  end

  @impl true
  def handle_event("all_scrolls", _params, socket) do
    user = socket.assigns.current_scope.user
    scrolls = Grim.Repo.preload(user, :scrolls).scrolls
    {:noreply, assign(socket, scrolls: scrolls)}
  end

  @impl true
  def handle_event("search_scroll", %{"value" => value}, socket) do
    user = socket.assigns.current_scope.user
    q = from s in Scroll,
      where: ilike(s.name, ^"%#{value}%")
      and s.user_id == ^user.id

    results = Grim.Repo.all(q)

    {:noreply,
      socket
    |> assign(:scrolls, results)}
  end

  @impl true
  def handle_event("open_scroll", %{"id" => selected_id}, socket) do
    {id, _} = Integer.parse(selected_id)

    scroll =
      socket.assigns.scrolls
      |> Enum.find_value(fn v -> if v.id == id, do: v end)

    {:noreply, assign_scroll(socket, scroll)}
  end

  @impl true
  def handle_event("remove_scroll", %{"id" => selected_id}, socket) do
    {id, _} = Integer.parse(selected_id)
    scroll =
      socket.assigns.scrolls
      |> Enum.find_value(fn v -> if v.id == id, do: v end)

    {:ok, _} = Grim.Repo.delete(scroll)

    scrolls =
      socket.assigns.scrolls
      |> Enum.reject(fn sc -> sc.id == id end)

    next_scroll = new_empty_scroll()

    {:noreply,
     socket
     |> assign(scrolls: scrolls)
     |> assign_scroll(next_scroll)}
  end

  @impl true
  def handle_event("autosave_scroll", %{"scroll" => scroll_params}, socket) do
    scroll = socket.assigns.scroll

    case scroll.id do
      nil ->
        create_scroll(scroll_params, socket)

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

  @impl true
  def handle_event("toggle_sidebar", _params, socket) do
    {:noreply,
     assign(socket, :sidebar_open, !socket.assigns.sidebar_open)}
  end

  defp create_scroll(params, socket) do
    %{current_scope: scope} = socket.assigns
    user = scope.user

    changeset =
      %Grim.Scroll{user_id: user.id}
      |> Grim.Scroll.changeset(params, scope)

    case Grim.Repo.insert(changeset) do
      {:ok, scroll} ->
        {:noreply,
         socket
         |> assign(:scrolls, [scroll | socket.assigns.scrolls])
         |> assign_scroll(scroll)}

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
         |> assign(:scrolls, scrolls)
         |> assign_scroll(updated_scroll)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp new_empty_scroll do
    %Grim.Scroll{}
  end

  defp scroll_form(scroll), do: to_form(Ecto.Changeset.change(scroll))

  defp assign_scroll(socket, scroll) do
    socket
    |> assign(:scroll, scroll)
    |> assign(:form, scroll_form(scroll))
  end
end
