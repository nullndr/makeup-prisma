defmodule MakeupPrisma.Application do
  @moduledoc false
  use Application

  alias Makeup.Registry
  alias Makeup.Lexers.MakeupPrisma

  def start(_type, _args) do
    Registry.register_lexer(MakeupPrisma,
      options: [],
      names: ["prisma"],
      extensions: ["prisma"]
    )

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
