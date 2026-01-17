defmodule Mix.Template do
  @app :ehelper

  def eval_template(priv_file, assigns \\ []) do
    tmpl_file = get_priv_file(priv_file)
    EEx.eval_file(tmpl_file, assigns: assigns)
  end

  def get_priv_file(priv_file, app \\ @app) do
    Path.join(:code.priv_dir(app), priv_file)
  end

  def task_to_module_name(task_name) do
    task_name
    |> String.split(".")
    |> Enum.map(&Macro.camelize/1)
    |> Enum.join(".")
  end
end
