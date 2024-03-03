function _xpnet_generator(pnet::PetriNet)
  xpnet = XMLDocument()
  defun = create_root(xpnet, "defun")
  set_attribute(defun, "name", pnet.name)
  
  for i in 1:length(pnet.transitions)
    impl_port = new_child(defun, "in")
    set_attributes(impl_port, Dict("name"=>"implementation_$i", "type"=>"string", "place"=>"implementation_$i"))
  end

  for i in 1:length(pnet.ports)
    port = new_child(defun, string(pnet.ports[i].type))
    set_attributes(port, Dict("name"=>pnet.ports[i].name, "type"=>"string" , "place"=>pnet.ports[i].place.name))
  end

  net = new_child(defun, "net")
  for i in 1:length(pnet.transitions)
    impl_pl = new_child(net, "place")
    set_attributes(impl_pl, Dict("name"=>"implementation_$i", "type"=>"string"))
  end

  for i in 1:length(pnet.places)
    if pnet.places[i].type == :control
      pl = new_child(net, "place")
      set_attributes(pl, Dict("name"=>pnet.places[i].name, "type"=>"control"))
      tk = new_child(pl, "token")
      vl = new_child(tk, "value")
      add_text(vl,"[]")
    else
      pl = new_child(net, "place")
      set_attributes(pl, Dict("name"=>pnet.places[i].name, "type"=>string(pnet.places[i].type)))
    end
  end

  for i in 1:length(pnet.transitions)
    trans = new_child(net, "transition")
    t_name = pnet.transitions[i].name
    set_attribute(trans, "name", t_name)
    def = new_child(trans, "defun")
    impl = new_child(def, "in")
    set_attributes(impl, Dict("name"=>"implementation_$i", "type"=>"string"))

    in_place_list = Vector{Tuple{Place,Symbol}}()
    out_place_list = Vector{Tuple{Place,Symbol}}()
    inout_place_list = Vector{Tuple{Place,Symbol}}()
    for j in 1:length(pnet.arcs)
      if pnet.arcs[j].transition == pnet.transitions[i]
        if pnet.arcs[j].type == :out_many
          prt = new_child(def, "out")
          set_attributes(prt, Dict("name"=>pnet.arcs[j].place.name, "type"=>"list"))
        elseif pnet.arcs[j].type == :read
          prt = new_child(def, "in")
          set_attributes(prt, Dict("name"=>pnet.arcs[j].place.name, "type"=>string(pnet.arcs[j].place.type)))
        else
          prt = new_child(def, string(pnet.arcs[j].type))
          set_attributes(prt, Dict("name"=>pnet.arcs[j].place.name, "type"=>string(pnet.arcs[j].place.type)))
        end
        if pnet.arcs[j].type in [:in, :read]
          push!(in_place_list, (pnet.arcs[j].place, pnet.arcs[j].type))
        elseif pnet.arcs[j].type in [:out, :out_many]
          push!(out_place_list, (pnet.arcs[j].place, pnet.arcs[j].type))
        else
          push!(inout_place_list, (pnet.arcs[j].place, pnet.arcs[j].type))
        end
      end
    end
    for pl in inout_place_list
      push!(in_place_list, pl)
      push!(out_place_list, pl)
    end

    in_str = in_place_list[1][1].name
    out_str = out_place_list[1][1].name
    for j in 2:length(in_place_list)
      in_str = in_str * ", " * in_place_list[j][1].name
    end
    for j in 2:length(out_place_list)
      out_str = out_str * ", " * out_place_list[j][1].name
    end
    mod = new_child(def, "module")
    set_attributes(mod, Dict("name"=>pnet.name, "function"=>"operation ($(in_str), $(out_str), implementation_$i)", "require_function_unloads_without_rest"=>"false"))
    
    cin1 = new_child(mod, "cinclude")
    set_attribute(cin1, "href", "zeda/executor.hpp")
    
    cin2 = new_child(mod, "cinclude")
    set_attribute(cin2, "href", "iostream")
    
    cin3 = new_child(mod, "cinclude")
    set_attribute(cin3, "href", "string")
    
    cin4 = new_child(mod, "cinclude")
    set_attribute(cin4, "href", "vector")
    
    num_outs = length(out_place_list)
    out_port_list = ""
    for j in 1:length(out_place_list)
      k = j-1
      if out_place_list[j][2] == :out_many
        str = string(out_place_list[j][1].name, ".assign(__output[$k].begin(), __output[$k].end());")
        out_port_list = out_port_list * str
      else
        str = string(out_place_list[j][1].name, " = __output[$k][0];\n") 
        out_port_list = out_port_list * str
      end
    end
    code = new_child(mod, "code")
    add_cdata(xpnet, code, string("std::vector<std::vector<std::string>> __output = zeda::execute(implementation_$i, {$(in_str)}, $(num_outs));\n", out_port_list))

    if !isempty(pnet.transitions[i].condition)
      cond = new_child(trans, "condition")
      add_text(cond, pnet.transitions[i].condition)
    end

    for j in 1:length(pnet.arcs)
      if pnet.arcs[j].transition == pnet.transitions[i]
        if pnet.arcs[j].type == :out_many
          connect_prt = new_child(trans, "connect-out-many")
          set_attributes(connect_prt, Dict("port"=>pnet.arcs[j].place.name, "place"=>string(pnet.arcs[j].place.name)))
        else
          connect_prt = new_child(trans, string("connect-", pnet.arcs[j].type))
          set_attributes(connect_prt, Dict("port"=>pnet.arcs[j].place.name, "place"=>string(pnet.arcs[j].place.name)))
        end
      end
    end

    impl_port_connect = new_child(trans, "connect-in")
    set_attributes(impl_port_connect, Dict("port"=>"implementation_$i", "place"=>"implementation_$i"))
  end
  return xpnet
end

"""
    workflow_generator(pnet::PetriNet)
    workflow_generator(pnet::PetriNet, path::String)
Given a Petri net description, creates an XML workflow and writes it to a file in the path.

# Examples
```julia-repl
julia> pn = PetriNet("hello_julia")
A Petri net with name "hello_julia", having 0 ports, 0 places, and 0 transitions.


julia> p1 = place("input1", :string)
Place input1 with control token created.


julia> p2 = place("input2",:string)
Place input2 with control token created.


julia> p3 = place("output",:string)
Place output with control token created.


julia> t = transition("trans")
Transition trans created.


julia> connect(pn, p1,t, :in)
A Petri net with name "hello_julia", having 0 ports, 1 places, and 1 transitions.


julia> connect(pn, p2,t, :read)
A Petri net with name "hello_julia", having 0 ports, 2 places, and 1 transitions.


julia> connect(pn, p3,t, :out_many)
A Petri net with name "hello_julia", having 0 ports, 3 places, and 1 transitions.


julia> connect(pn, p1, :in)
A Petri net with name "hello_julia", having 1 ports, 3 places, and 1 transitions.


julia> connect(pn, :in, p2)
A Petri net with name "hello_julia", having 2 ports, 3 places, and 1 transitions.


julia> connect(pn, :out, p3)
A Petri net with name "hello_julia", having 3 ports, 3 places, and 1 transitions.


julia> workflow_generator(pn)
"An XML workflow \"hello_julia\" has been written to the location: /root/tmp."


```

See also [`place`](@ref), [`transition`](@ref), [`arc`](@ref), [`port`](@ref), [`PetriNet`](@ref), [`connect`](@ref), [`remove`](@ref), [`compile_workflow`](@ref).
"""
function workflow_generator(pnet::PetriNet, path::String="")
  xpnet = _xpnet_generator(pnet)
  dir = ""
  if !isempty(path)
    save_file(xpnet, joinpath(path,"$(pnet.name).xpnet"))
    dir = path
  else
    dir = joinpath(ENV["HOME"],"tmp")
    run(`mkdir -p $dir`)
    save_file(xpnet, joinpath(ENV["HOME"],"tmp/$(pnet.name).xpnet"))
  end
  free(xpnet)
  return "An XML workflow \"$(pnet.name)\" has been written to the location: $(dir)."
end

# transition parallel-reduce

# transition counter
