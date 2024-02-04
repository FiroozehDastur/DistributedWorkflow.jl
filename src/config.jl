using TOML

function set_workflow_env(path::String)
  DistributedWorkflow.config["workflow_path"] = path
  workflow_path = DistributedWorkflow.config["workflow_path"]
  run(`mkdir -p $workflow_path`)
  config_file = joinpath(ENV["HOME"], ".distributedworkflow/config.toml")
  open(config_file, "w") do io
    TOML.print(io, DistributedWorkflow.config)
  end
  println(string("Workflow environment is set to: ", path))
end