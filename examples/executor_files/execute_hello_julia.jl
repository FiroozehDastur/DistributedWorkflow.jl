# ================================================================
# hello julia Petri net
# ================================================================
# using DistributedWorkflow, CxxWrap

DistributedWorkflow.compile_workflow("/root/zeda-examples/hello_julia/hello_julia.xpnet", "/root/tmp/build_dir")
client = DistributedWorkflow.client(1, "/root/tmp/nodefile", "local", "localhost", 6789)
impl_path = "/root/DistributedWorkflow.jl/utils/executor.jl"
impl = DistributedWorkflow.implementation("implementation", impl_path)

jl_impl = DistributedWorkflow.julia_implementation("julia_impl", "/root/DistributedWorkflow.jl/examples/applications/hello_julia.jl")

fname = DistributedWorkflow.function_name("fname", "test_func")

out_dir = DistributedWorkflow.output_dir("output_dir", "/root/tmp/output_dir_hello")

workflow_N2M_jl = DistributedWorkflow.workflow_config("hello_julia.pnet", [impl, jl_impl, fname, out_dir])

input_1 = DistributedWorkflow.input_pair("input_file1", "/root/DistributedWorkflow.jl/examples/serialized_data/int1_julia_nativefmt")

input_2 = DistributedWorkflow.input_pair("input_file2", "/root/DistributedWorkflow.jl/examples/serialized_data/int2_julia_nativefmt")

input_vars = [input_1, input_2];

submit_func = DistributedWorkflow.submit_workflow(client, workflow_N2M_jl, input_vars)
