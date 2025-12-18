defmodule Mix.Template do
  @app :ehelper

  def eval_template(priv_file, assigns \\ []) do
    tmpl_file = get_priv_file(priv_file)
    EEx.eval_file(tmpl_file, assigns: assigns)
  end

  def get_priv_file(priv_file) do
    Path.join(:code.priv_dir(@app), priv_file)
  end
end
