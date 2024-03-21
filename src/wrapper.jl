# TODO: Add documentation.
struct Application_config
  port::String
  impl::String
  fname::String
end

struct Application_config_many
  ports::Vector{String}
  impl::Vector{String}
  fnames::Vector{String}
end

"""
    application_config(port::String, impl::String, fname::String)
Description of function here...

# Examples
```julia-repl


```

See also [`PetriNet`](@ref), [`workflow_generator`](@ref), [`compile_workflow`](@ref).
""" 
application_config(port::String, impl::String, fname::String) = Application_config(port, impl, fname)

"""
    application_config(ports::Vector{String}, impl::String, fnames::Vector{String})
Description of function here...

# Examples
```julia-repl


```

See also [`PetriNet`](@ref), [`workflow_generator`](@ref), [`compile_workflow`](@ref).
"""
application_config(ports::Vector{String}, impl::Vector{String}, fnames::Vector{String}) = Application_config_many(ports, impl, fnames)

application_config(ports::Vector{String}, impl::String, fnames::Vector{String}) = Application_config_many(ports, [impl], fnames)

"""
    client(workers::Int, nodefile::String, rif_strategy::String, log_host::String, log_port::Int)
Description of function here...

# Examples
```julia-repl


```

See also [`PetriNet`](@ref), [`workflow_generator`](@ref), [`compile_workflow`](@ref).
"""
function client(workers::Int, nodefile::String, rif_strategy::String, log_host::String, log_port::Int)
  run(`touch $nodefile`)
  if rif_strategy=="local"
    write(nodefile, gethostname())
    # ToDo: add an else condition for the nodefile
  end
  worker = string("worker:", workers)
  gspc_home = string("--gspc-home=", readchomp(`spack location -i gpi-space`))
  nodefile = string("--nodefile=", nodefile)
  rif_strategy = string("--rif-strategy=", rif_strategy)
  log_host = string("--log-host=", log_host)
  log_port = string("--log-port=", log_port)
  app_search_path = string("--application-search-path=", config["workflow_path"])
  client_config = string(gspc_home, " " , app_search_path, " " , nodefile, " ", rif_strategy, " ", log_host, " ", log_port, " --worker-env-copy-current")

  DistributedWorkflow.Client(worker, client_config)
end

"""
    client(workers::Int, nodefile::String, rif_strategy::String)
Description of function here...

# Examples
```julia-repl


```

See also [`PetriNet`](@ref), [`workflow_generator`](@ref), [`compile_workflow`](@ref).
"""
function client(workers::Int, nodefile::String, rif_strategy::String)
  run(`touch $nodefile`)
  if rif_strategy=="local"
    write(nodefile, gethostname())
    # ToDo: add an else condition for the nodefile
  end
  worker = string("worker:", workers)
  gspc_home = string("--gspc-home=", readchomp(`spack location -i gpi-space`))
  nodefile = string("--nodefile=", nodefile)
  rif_strategy = string("--rif-strategy=", rif_strategy)
  # app_search_path = string("--application-search-path=", ENV["GSPC_APPLICATION_SEARCH_PATH"])
  app_search_path = string("--application-search-path=", config["workflow_path"])
  client_config = string(gspc_home, " " , app_search_path, " ", nodefile, " ", rif_strategy, " --worker-env-copy-current")

  DistributedWorkflow.Client(worker, client_config)
end

"""
    input_pair(port_name::String, path::String)
Description of function here...

# Examples
```julia-repl


```

See also [`PetriNet`](@ref), [`workflow_generator`](@ref), [`compile_workflow`](@ref), [`port_info`](@ref).
"""
input_pair(port_name::String, path::String) = KeyValuePair(port_name, path)

"""
    implementation(port_name::String, path::String)
Description of function here...

# Examples
```julia-repl


```

See also [`PetriNet`](@ref), [`workflow_generator`](@ref), [`compile_workflow`](@ref), [`port_info`](@ref).
"""
implementation(port_name::String, path::String) = KeyValuePair(port_name, path)

"""
    submit_workflow(client, workflow, input_params::Vector)
Description of function here...

# Examples
```julia-repl


```

See also [`PetriNet`](@ref), [`workflow_generator`](@ref), [`compile_workflow`](@ref).
"""
function submit_workflow(client, workflow, input_params::Vector)
  input_vec = StdVector(input_params)
  output = DistributedWorkflow.submit(client, workflow, input_vec)
  output_list = String[]
  for val in output
    _, deref_val = DistributedWorkflow.port_info(val)
    push!(output_list, deref_val) 
  end
  return output_list
end

"""
    workflow_config(workflow::String, output_dir::String, app_config::Application_config)
Description of function here...

# Examples
```julia-repl


```

See also [`PetriNet`](@ref), [`workflow_generator`](@ref), [`compile_workflow`](@ref).
"""
function workflow_config(workflow::String, output_dir::String, app_config::Application_config)
  run(`mkdir -p $output_dir`)
  portname = app_config.port
  executor_file = joinpath(pkgdir(DistributedWorkflow), "utils/executor.jl")
  workflow_cfg = [DistributedWorkflow.implementation(portname, "julia $executor_file $(app_config.impl) $(app_config.fname) $output_dir")]
  workflow_config = StdVector(workflow_cfg)
  workflow_path = joinpath(DistributedWorkflow.config["workflow_path"], workflow)
  DistributedWorkflow.Workflow(workflow_path, workflow_config)
end

"""
    workflow_config(workflow::String, output_dir::String, app_config::Vector{Application_config})
Description of function here...

# Examples
```julia-repl


```

See also [`PetriNet`](@ref), [`workflow_generator`](@ref), [`compile_workflow`](@ref).
"""
function workflow_config(workflow::String, output_dir::String, app_config::Vector{Application_config})
  run(`mkdir -p $output_dir`)
  executor_file = joinpath(pkgdir(DistributedWorkflow), "utils/executor.jl")
  n = length(app_config)
  workflow_cfg = Vector(undef, n)
  for i in 1:n
    portname = app_config[i].port
    workflow_cfg[i] = DistributedWorkflow.implementation(portname, "julia $executor_file $(app_config[i].impl) $(app_config[i].fname) $output_dir")
  end
  workflow_config = StdVector(workflow_cfg)
  workflow_path = joinpath(DistributedWorkflow.config["workflow_path"], workflow)
  DistributedWorkflow.Workflow(workflow_path, workflow_config)
end

"""
    workflow_config(workflow::String, output_dir::String, app_config::Application_config_many)
Description of function here...

# Examples
```julia-repl


```

See also [`PetriNet`](@ref), [`workflow_generator`](@ref), [`compile_workflow`](@ref).
"""
function workflow_config(workflow::String, output_dir::String, app_config::Application_config_many)
  run(`mkdir -p $output_dir`)
  executor_file = joinpath(pkgdir(DistributedWorkflow), "utils/executor.jl")
  n = length(app_config.ports)
  m = length(app_config.fnames)
  @assert n == m "The number of $(app_config.ports) should match the number of $(app_config.fnames), since each port gets a function name in the order they occur in the struct."
  workflow_cfg = Vector(undef, n)
  for i in 1:n
    impl = ""
    if length(app_config.impl) == 1
      impl = app_config.impl[1]
    else
     impl = app_config.impl[i]
    end
    portname = app_config.ports[i]
    fname = app_config.fnames[i]
    workflow_cfg[i] = DistributedWorkflow.implementation(portname, "julia $executor_file $(impl) $fname $output_dir")
  end
  workflow_config = StdVector(workflow_cfg)
  workflow_path = joinpath(DistributedWorkflow.config["workflow_path"], workflow)
  DistributedWorkflow.Workflow(workflow_path, workflow_config)
end
