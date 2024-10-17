defmodule MakeupPrisma.MixProject do
  use Mix.Project

  @url "https://github.com/nullndr/makeup_prisma"

  def project do
    [
      app: :makeup_prisma,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  defp package do
    [
      name: "makeup_prisma",
      links: %{"GitHub" => @url}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:makeup, "~> 1.0"},
      {:nimble_parsec, "~> 1.1"}
    ]
  end
end
