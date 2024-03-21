pn = PetriNet("multi_module")

p1 = place("input_file")
p2 = place("output_file0")
p3 = place("output_file1")
p4 = place("output_file2")
p5 = place("mid_point")

t1 = transition("transition1")
t2 = transition("transition2")

connect(pn, [(p1, :in), (p2, :out), (p5, :out)], t1)
connect(pn, [(p5, :in), (p3, :out), (p4, :out)], t2)

connect(pn, [(p1, :in), (p2, :out), (p3, :out), (p4, :out)])

workflow_generator(pn)
