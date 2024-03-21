# A Petri net with 2 input places and 2 output places
pn = PetriNet("hello_julia")
p1 = place("input_file1")
p2 = place("input_file2")
p3 = place("output_file1")
p4 = place("output_file2")
t = transition("hello_jl")

connect(pn,[(p1, :in),(p2, :in),(p3, :out), (p4, :out)], t)
connect(pn, p1, :in)
connect(pn, p2, :in)
connect(pn, p3, :out)
connect(pn, p4, :out)

wf = workflow_generator(pn)
