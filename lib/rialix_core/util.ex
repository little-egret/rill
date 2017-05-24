defmodule RialixCore.Util do
    def start_app_deps(app) do
        {ok, dep_apps} = Application.get_key(app, :applications)
        # returns :ok if the application was already started
        _ = for a <- dep_apps, do: :ok = Application.ensure_started(a)
        :ok
    end
end