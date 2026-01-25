defmodule GrimWeb.Playground do
  use GrimWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex min-h-screen">
      <!-- Sidebar -->
      <aside
        id="sidebar"
        class="w-64 bg-gray-800 text-white transition-all duration-300 overflow-hidden"
      >
        <ul class="p-4 space-y-2">
          <li class="hover:bg-gray-700 p-2 rounded">Dashboard</li>
          <li class="hover:bg-gray-700 p-2 rounded">Usuarios</li>
          <li class="hover:bg-gray-700 p-2 rounded">Settings</li>
        </ul>
      </aside>
      
    <!-- Main content -->
      <main class="flex-1">
        <button
          onclick="toggleSidebar()"
          class="mb-4 px-4 py-2 bg-indigo-600 text-white rounded"
        >
          ☰
        </button>

        <p>Contenido principal</p>
      </main>
    </div>
    """
  end
end
