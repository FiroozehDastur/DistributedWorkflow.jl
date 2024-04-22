# DistributedWorkflow.jl - A Julia interface to a distributed task-based workflow management system

![DistributedWorkflowImage](logo/DistributedWorkflow.png)

[![CI](https://github.com/FiroozehDastur/DistributedWorkflow.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/FiroozehDastur/DistributedWorkflow.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/FiroozehDastur/DistributedWorkflow.jl/graph/badge.svg?token=9JIYL7YJYK)](https://codecov.io/gh/FiroozehDastur/DistributedWorkflow.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](http://bjack205.github.io/DistributedWorkflow.jl/dev)


# How to cite DistributedWorkflow.jl
Please cite this package as follows if you use it in your work:

```
@misc{DistributedWorkflow,
  author    = {Dastur, Firoozeh and Zeyen, Max and Rahn, Mirko},
  title     = {DistributedWorkflow.jl - A Julia interface to a distributed 
               task-based workflow management system},
  year     = {2024},
  month    = {January},
  howpublished     = {\url{https://github.com/FiroozehDastur/DistributedWorkflow.jl}}
}
```

# Initial setup
To install DistributedWorkflow.jl we first need to install the package manager Spack. Follow the steps from [Spack - Getting Started](https://spack.readthedocs.io/en/latest/getting_started.html) to install Spack. You might also want to read [Spack - Basic Usage](https://spack.readthedocs.io/en/latest/basic_usage.html) to learn basic usage of Spack.

Note: if you already have Spack installed, then you can skip the above step.

Next, download the binary with respect to your system from the following:

### Related binaries
The binaries are all built for the `x86_64_v3` architechture

* [Ubuntu 22.04](https://github.com/FiroozehDastur/DistributedWorkflow.jl/releases/download/v0.1.0/distributedworkflow.tar.gz)
* <!-- [Ubuntu 24.04]() -->
* <!-- [Debian 11]() -->
* <!-- [Debian 12]() -->
* <!-- [OracleLinux 8.9]() -->
* <!-- [Rocky Linux 9]() -->

Once the installation is complete load the package by running the following:
```
  unpack tar file
  run the install script
```
If the installation script was successful, then running the following should load the required dependencies of `DistributedWorkflow.jl`.
```
  spack load distributedworkflow
```
Now we are ready to start Julia and make use of DistributedWorkflow.jl
## DistributedWorkflow.jl

  This package can be installed similar to any Julia package by:
  ```
    import Pkg; Pkg.add("DistributedWorkflow")
  ```

# How to use DistributedWorkflow.jl
```
> **Note**
Detailed instructions on the usage, as well as more examples, will follow soon.
```
## Testing an example locally
When testing the application locally, set the hostname as follows:
```hostname > <path-to-a-nodefile>```

NOTE: the hostname needs to be setup before starting a Julia REPL.

Start a Julia session and load the package with ```using DistributedWorkflow``` and 

Assuming that you have a workflow Petri net stored in an accessible location, use ```compile_workflow(<workflow-name>.xpnet, "/path/to/build/location")``` function to compile the workflow.

Next, start the client using ```client(<number-of-workers>, "/path/to/nodefile", "rif-strategy")```

As a next step, it is advisible to create a script with your workflow configuration (see the executor files in the examples folder), and submit your application using the ```submit_workflow()``` function.

Once your application runs through, the output files will be stored in your desired output location.

## Running the example on a cluster

## A simple example
* A small example to create a Petri net, compile it, start agent and run the application locally.

NOTE: for a more complex example see: [examples](examples).
# API Functions
* A list of all the api functions plus the description in a table.
<!-- insert table of methods available to the user with a short description of what they do -->

# Features
* Serializer agnostic, for details see [custom serialize](docs/src/Serialization/custom_serializer.md) section in the documentation.
* Reduced complexity in deploying your parallel application.
* Localised testing of workflow, before launching expensive cluster resources.
* Write your own `xpnet` file and compile your workflow using the `compile_workflow()` function. 
* You could also, generate a Petri net in Julia using `PetriNet()` and generate the `xpnet` file from the Petri net using `workflow_generator()` before compiling it.
* Visualise Petri net within the Julia REPL.

# Shortcomings
* At the moment, this package is only efficient and recommended for long running processes.
* Due to the underlying workflow manager, this package only supports the following operating systems:
```
* Ubuntu 20.04 LTS
* Ubuntu 22.04 LTS
```

# See also
* [More Examples]( ./examples)
* [XPNET Format Schema](https://github.com/cc-hpc-itwm/gpispace/blob/v23.06/share/xml/xsd/pnet.xsd)
* [GPI-Space database on Petri nets](https://github.com/cc-hpc-itwm/gpispace/tree/v23.06/share/doc/example)

# ToDo...
* Add examples for a cluster run.
* Improve UI by adding documentation and examples.
* Extend the interface to add more features.


# Appendix
The underlying workflow management system is called [GPI-Space](https://www.gpi-space.de/) which is a task-based workflow management system for parallel applications developed at Fraunhofer ITWM by the CC-HPC group.

# Package Dependency
* [Cairo]()
* [CxxWrap](https://docs.juliahub.com/General/CxxWrap/stable/)
* [FileIO](https://juliaio.github.io/FileIO.jl/stable/)
* [GraphViz](https://graphviz.org/)
* [GPI-Space](https://www.gpi-space.de/)
* [LightXML](https://juliapackages.com/p/lightxml)
* [Markdown](https://docs.julialang.org/en/v1/stdlib/Markdown/)
* [Serialization](https://docs.julialang.org/en/v1/stdlib/Serialization/)
* [TOML](https://docs.julialang.org/en/v1/stdlib/TOML/)
