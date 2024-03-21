"""
    compile_workflow(workflow::String, build_dir::String)
Given a path for the workflow and an accessible location for the build directory, this function compiles the XML workflow.

Note:
  workflow => absolute path to the xpnet file
  build_dir => path to build directory
  
# Examples
```julia-repl
julia> compile_workflow("/root/tmp/hello_julia.xpnet")
...
Success: Workflow compiled

```

See also [`place`](@ref), [`transition`](@ref), [`arc`](@ref), [`port`](@ref), [`PetriNet`](@ref), [`connect`](@ref), [`remove`](@ref), [`workflow_generator`](@ref).
"""
function compile_workflow(workflow::String, build_dir::String="")
  source_dir = joinpath(readchomp(`spack location -i gspcdriver`), "share/zeda-gspcdriver/utils")
  install_dir = DistributedWorkflow.config["workflow_path"]
  # compile
  if isempty(build_dir)
    build_dir = joinpath(ENV["HOME"], "tmp/build")
  end
  run(`mkdir -p $(build_dir)`)
  run(`cmake -D WORKFLOW=$workflow -B $build_dir -S $source_dir`)
  # build
  run(`cmake --build $build_dir -j 8`)
  # install
  run(`cmake --install $build_dir --prefix $install_dir`)
  # cleanup
  run(`rm -rf $build_dir`)
  println("Success: Workflow compiled")
end
