module TestIO
    using Base.Test
    using DataFrames
    using LaTeXStrings
    using NullableArrays
    using CategoricalArrays

    # Test LaTeX export
    df = DataFrame(A = 1:4,
                   B = ["\$10.0", "M&F", "A~B", "\\alpha"],
                   C = [L"\alpha", L"\beta", L"\gamma", L"\sum_{i=1}^n \delta_i"],
                   D = [1.0, 2.0, Nullable(), 3.0]
                   )
    str = """
        \\begin{tabular}{r|cccc}
        \t& A & B & C & D\\\\
        \t\\hline
        \t1 & 1 & \\\$10.0 & \$\\alpha\$ & 1.0 \\\\
        \t2 & 2 & M\\&F & \$\\beta\$ & 2.0 \\\\
        \t3 & 3 & A\\textasciitilde{}B & \$\\gamma\$ &  \\\\
        \t4 & 4 & \\textbackslash{}alpha & \$\\sum_{i=1}^n \\delta_i\$ & 3.0 \\\\
        \\end{tabular}
        """
    @test reprmime(MIME("text/latex"), df) == str

    #Test HTML output for IJulia and similar
    df = DataFrame(Fish = ["Suzy", "Amir"], Mass = [1.5, Nullable()])
    io = IOBuffer()
    show(io, "text/html", df)
    str = String(take!(io))
    @test str == "<table class=\"data-frame\"><tr><th></th><th>Fish</th><th>Mass</th></tr><tr><th>1</th><td>Suzy</td><td>1.5</td></tr><tr><th>2</th><td>Amir</td><td>#NULL</td></tr></table>"

    # test limit attribute of IOContext is used
    df = DataFrame(a=collect(1:1000))
    ioc = IOContext(IOBuffer(), displaysize=(10, 10), limit=false)
    show(ioc, "text/html", df)
    @test length(String(take!(ioc.io))) > 10000

    io = IOBuffer()
    show(io, "text/html", df)
    @test length(String(take!(io))) < 10000

    df = DataFrame(A = 1:3,
                   B = 'a':'c',
                   C = ["A", "B", "C"],
                   D = CategoricalArray('a':'c'),
                   E = NullableCategoricalArray(["A", "B", "C"]),
                   E = NullableArray(1:3),
                   F = NullableArray(fill(Nullable(), 3)),
                   G = fill(Nullable(), 3))

    answer = Sys.WORD_SIZE == 64 ? 0x3bd4a4a099ae8aac : 0x5ecdc4bb
    @test hash(sprint(printtable, df)) == answer

    # DataStreams
    using CSV

    df = CSV.read(joinpath(dirname(@__FILE__), "data/iris.csv"), DataFrame)
    @test size(df) == (150, 5)
end
