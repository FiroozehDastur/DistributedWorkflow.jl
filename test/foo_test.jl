# [test/foo_test.jl]
@testset "Foo test" begin
  s = "This is a string"  
  @test typeof(s) == String
end