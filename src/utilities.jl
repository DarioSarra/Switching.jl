"""
`get_hierarchy`
Return a vector indicating how many consecutive falses or trues
preceded an event
"""

function nextcount(count::T, rewarded) where {T <: Number}
    if rewarded
        count > 0 ? count + 1 : one(T)
    else
        count < 0 ? count - 1 : -one(T)
    end
end
signedcount(v) = accumulate(nextcount, v;init=0.0)
get_hierarchy(v) = lag(signedcount(v), default = NaN)

Base.findall(v::AbstractVector{Union{Bool,Missing}}) = findall(collect(skipmissing(v)))
Base.findlast(v::AbstractVector{Union{Bool,Missing}}) = findlast(collect(skipmissing(v)))
Base.findprev(v::AbstractVector{Union{Bool,Missing}},idx) = findprev(collect(skipmissing(v)),idx)
