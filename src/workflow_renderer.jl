
# =============================================================================
# Petri net viewer using GraphViz
# =============================================================================
"""
    view_workflow(pnet::PetriNet)
    view_workflow(pnet::PetriNet, format::Symbol)
    view_workflow(pnet::PetriNet, path::String)
    view_workflow(pnet::PetriNet, format::Symbol, path::String)
By default this method generates a PNG file after compiling the Petri net into an XML workflow and compiling the workflow.
If path is not given then the workflow image is stored in your home directory in the \"tmp/pnet\" folder.

Note: Supports all the file formats by GraphViz. For example, :png, :svg, :jpg, :pdf, :webp

For other formats, check GraphViz documentation:
https://graphviz.org/docs/outputs/


# Examples
```julia-repl
julia> # first generate a workflow in the form of a Petri net
julia> pn = PetriNet("hello_julia")
A Petri net with name "hello_julia", having 0 ports, 0 places, and 0 transitions.


julia> p1 = place("input_file1")
Place "input_file1" created.


julia> p2 = place("input_file2")
Place "input_file2" created.


julia> p3 = place("output_file1")
Place "output_file1" created.


julia> p4 = place("output_file2")
Place "output_file2" created.


julia> t = transition("hello_jl")
Transition "hello_jl" created.


julia> connect(pn,[(p1, :in),(p2, :in),(p3, :out), (p4, :out)], t)
A Petri net with name "hello_julia", having 0 ports, 4 places, and 1 transitions.


julia> connect(pn, p1, :in)
A Petri net with name "hello_julia", having 1 ports, 4 places, and 1 transitions.


julia> connect(pn, p2, :in)
A Petri net with name "hello_julia", having 2 ports, 4 places, and 1 transitions.


julia> connect(pn, p3, :out)
A Petri net with name "hello_julia", having 3 ports, 4 places, and 1 transitions.


julia> connect(pn, p4, :out)
A Petri net with name "hello_julia", having 4 ports, 4 places, and 1 transitions.


julia> pn
A Petri net with name "hello_julia", having 4 ports, 4 places, and 1 transitions.

# now generate the workflow image
julia> view_workflow(pn, :jpg, "/home/pnet")
"An image of the workflow Petri net could be found in /home/pnet/hello_julia.jpg"

# the following takes the Petri net and the path for storage and generates a PNG file which is stored in the provided path.
julia> view_workflow(pn, "/home/pnet")
"An image of the workflow Petri net could be found in /home/pnet/hello_julia.png"

```

See also [`PetriNet`](@ref), [`place`](@ref), [`transition`](@ref), [`arc`](@ref), [`port`](@ref), [`PetriNet`](@ref), [`connect`](@ref), [`remove`](@ref), [`compile_workflow`](@ref), [`workflow_generator`](@ref).

"""
function view_workflow(pnet::PetriNet, format::Symbol=:png, path::String="")
  # collect ports based on their types in and out for shape
  in_ports = Vector{Port}()
  out_ports = Vector{Port}()
  for p in pnet.ports
    if p.type == :in 
      push!(in_ports, p)
    elseif p.type == :out
      push!(out_ports, p)
    else
      push!(in_ports, p)
      push!(out_ports, p)
    end
  end

  # create a string list that has information for the port nodes
  nd_prt_in = """node [shape=house, style=filled, fillcolor=white]\n"""
  instr_port_list = [nd_prt_in]
  for p in in_ports
    prt_st = """Prt_$(p.name) [label="$(p.name)"]\n"""
    push!(instr_port_list, prt_st)
  end
  nd_prt_out = """node [shape=invhouse, style=filled, fillcolor=white]\n"""
  outstr_port_list = [nd_prt_out]
  for p in out_ports
    prt_st = """Prt_$(p.name) [label="$(p.name)"]\n"""
    push!(outstr_port_list, prt_st)
  end

  # create a string list that has information for the place nodes
  nd_pl = """node [shape=ellipse]\n"""
  plstr_list = [nd_pl]
  P_st = ""
  for i in 1:length(pnet.places)
    p = pnet.places[i]
    if p.type == :control_init
      b = "\u2022"
      P_st = """Pl_$(p.name) [label = "$(b)\n $(p.name)"]\n"""
    elseif p.type == :control
      P_st = """Pl_$(p.name) [label = "$(p.name)"]\n"""
    else
      P_st = """Pl_$(p.name) [label = "$(p.name)"]\n"""
    end
    push!(plstr_list, P_st)
  end

  # create a string list that has information for the transition nodes
  nd_tr = """node [shape=box3d, style=filled, fillcolor=lightblue, margin=0.3, padding=0.2]\n"""
  trstr_list = [nd_tr]
  for t in pnet.transitions
    T_str = """Tr_$(t.name) [label="$(t.name)"]\n"""
    push!(trstr_list, T_str)
  end

  # collect list of different kinds of arcs
  in_arcs = Vector{Arc}()
  out_arcs = Vector{Arc}()
  inout_arcs = Vector{Arc}()
  read_arcs = Vector{Arc}()
  out_many_arcs = Vector{Arc}()
  for a in pnet.arcs
    if a.type == :in
      push!(in_arcs, a)
    elseif a.type == :out
      push!(out_arcs, a)
    elseif a.type == :read
      push!(read_arcs, a)
    elseif a.type == :out_many
      push!(out_many_arcs, a)
    else
      push!(inout_arcs, a)
    end
  end

  title = """label = "$(pnet.name)";"""
  pos = """labelloc = "t";"""
  gen_str_init = """
  digraph petrinet {
    $title
    $pos

    subgraph cluster_init {
      label=""
      color="lightgrey"
      style="filled"
      fillcolor=lightgrey
      margin=15

    
  """
  in_ports_string = ""
  for i in 1:length(instr_port_list)
    in_ports_string = in_ports_string * instr_port_list[i]
  end
  out_ports_string = ""
  for i in 1:length(outstr_port_list)
    out_ports_string = out_ports_string * outstr_port_list[i]
  end

  sub_gh_begin =  """
  $(in_ports_string)

  $(out_ports_string)

  subgraph cluster_net {
    label=""
    style="rounded, filled"
    color="black"
    fillcolor=lightyellow
    margin=25

  """

  place_string = plstr_list[1]  
  for i in 2:length(plstr_list)
    place_string = place_string * plstr_list[i]
  end

  transition_string = trstr_list[1]  
  for i in 2:length(trstr_list)
    transition_string = transition_string * trstr_list[i]
  end
  # // place to transition no arrows
  in_pl_trans_edge_str = ""
  for a in inout_arcs
    arc_str = """[dir="both"]\n"""
    in_pl_trans_edge_str = in_pl_trans_edge_str * """
        Pl_$(a.place.name) -> Tr_$(a.transition.name)\n"""
  end
  for a in in_arcs
    arc_str = """[dir="forward"]\n"""
    in_pl_trans_edge_str = in_pl_trans_edge_str * """
        Pl_$(a.place.name) -> Tr_$(a.transition.name)\n"""
  end
  for a in read_arcs
    arc_str = """[style="dashed", dir="forward"]\n"""
    in_pl_trans_edge_str = in_pl_trans_edge_str * """
        Pl_$(a.place.name) -> Tr_$(a.transition.name)\n"""
  end

  # // Define edges
  prt_pl_edge_str = ""
  for p in pnet.ports
    if p.type in [:in, :inout]
      prt_pl_edge_str = prt_pl_edge_str * """
        Prt_$(p.name) -> Pl_$(p.place.name) [style="dotted", dir="none"]\n"""  
    else
      prt_pl_edge_str = prt_pl_edge_str * """
      Pl_$(p.place.name) -> Prt_$(p.name) [style="dotted", dir="none"]\n"""  
    end
  end

  out_pl_trans_edge_str = ""
  for a in out_arcs
    arc_str = """[dir="back"]\n"""
    out_pl_trans_edge_str = out_pl_trans_edge_str * """
        Tr_$(a.transition.name) -> Pl_$(a.place.name)\n"""
  end
  for a in out_many_arcs
    arc_str = """[dir="back", color = "black:invis:black"]\n"""
    out_pl_trans_edge_str = out_pl_trans_edge_str * """
        Tr_$(a.transition.name) -> Pl_$(a.place.name)\n"""
  end

  sub_gh_end2 = """
    border_node [shape=plaintext, label="", width=2, height=2, style=dotted, color=black];

    }
  
  """

end_gen = """
    border_node [shape=plaintext, label="", width=2, height=2, style=dotted, color=black];

    }
  graph [bgcolor=white, pad=0.3]
  }
  """

  gen_str = gen_str_init * sub_gh_begin * place_string * transition_string * in_pl_trans_edge_str * out_pl_trans_edge_str * sub_gh_end2 * prt_pl_edge_str * end_gen
  path_dir = ""
  if isempty(path)
    path_dir = joinpath(ENV["HOME"], "tmp/pnet")
    run(`mkdir -p $(path_dir)`)
  else
    path_dir = path
    run(`mkdir -p $(path_dir)`)
  end
  store_location = ""
  if format == :png
    graph_viz = GraphViz.Graph(gen_str)
    store_location = joinpath(path_dir, "$(pnet.name).png")
    graph_gen = FileIO.save(store_location, graph_viz)
  else
      # Save DOT content to a file
      dot_file = joinpath(path_dir, "$(pnet.name).dot")
      open(dot_file, "w") do io
        write(io, gen_str)
      end
      fmt = string(format)
      # Convert DOT file to SVG using Graphviz
      svg_file = "$(pnet.name).$(fmt)"
      store_location = joinpath(path_dir, svg_file)
      run(`dot -T$fmt $dot_file -o $store_location`)
      run(`rm $dot_file`)
  end
  return "An image of the workflow Petri net could be found in $(store_location)"
end

function view_workflow(pnet::PetriNet, path::String)
  return view_workflow(pnet, :png, path)
end
