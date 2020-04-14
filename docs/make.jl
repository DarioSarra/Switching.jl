using Documenter, Switching

makedocs(;
    modules=[Switching],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/DarioSarra/Switching.jl/blob/{commit}{path}#L{line}",
    sitename="Switching.jl",
    authors="DarioSarra",
    assets=String[],
)

deploydocs(;
    repo="github.com/DarioSarra/Switching.jl",
)
