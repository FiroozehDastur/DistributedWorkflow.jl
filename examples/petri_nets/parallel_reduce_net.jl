pn = PetriNet("parallel_reduce")

p1 = place("input_file")
p2 = place("partial_result")
p3 = place("Left")
p4 = place("Right")
p5 = place("output_file1")
p6 = place("output_file2")
p7 = place("sanity_gcd")
p8 = place("count", :counter)
p9 = place("send_to_partial_result")
p10 = place("right_init", :control_init)
p11 = place("left_init", :control)

t1 = transition("generate_N")
t2 = transition("take_R", :exp)
t3 = transition("take_L", :exp)
t4 = transition("reduce")
t5 = transition("counter", :exp, ["\${count} := \${count} - 1UL"])
t6 = transition("finalise", "\${count} :eq: 0UL")

connect(pn, [(p1, :in), (p8, :out), (p6, :out), (p2, :out_many)], t1)
connect(pn, [(p10, :in), (p11, :out), (p2, :in), (p4, :out)], t2)
connect(pn, [(p11, :in), (p10, :out), (p2, :in), (p3, :out)], t3)
connect(pn, [(p3, :in), (p4, :in), (p7, :out), (p9, :out)], t4)
connect(pn, [(p8, :inout), (p9, :in), (p2, :out)], t5)
connect(pn, [(p8, :in), (p4, :in), (p5, :out), (p6, :out)], t6)


connect(pn, [(p1, :in), (p5, :out), (p6, :out), (p7, :out)])

workflow_generator(pn)