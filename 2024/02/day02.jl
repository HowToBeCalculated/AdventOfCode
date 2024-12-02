include("../utils.jl")


MIN_DELTA::Int64 = 1
MAX_DELTA::Int64 = 3


function is_safe_report(report::Array{Int64})::Union{Int64, Nothing}
    last_num::Int64 = report[1]
    direction::Int64 = last_num - report[end] > 0 ? 1 : -1 

    for i in 2:length(report)
        num::Int64 = report[i]
        diff::Int64 = last_num - num

        if sign(diff) != direction || abs(diff) > MAX_DELTA || abs(diff) < MIN_DELTA
            return i
        end
        last_num = num
    end

    return nothing
end

function is_safe_report_with_tolerance(report::Array{Int64}, tolerance::Int64 = 1)::Bool
    # TODO: support tolerances other than 1
    @assert tolerance == 1 "Tolerance must be 1"

    problem_index::Union{Int64, Nothing} = is_safe_report(report)

    if isnothing(problem_index)
        return true
    end

    # this is needed as it may be the first number that is the problem
    if problem_index == 2
        if isnothing(is_safe_report(report[2:end]))
            return true
        end
    end

    without_problem_index::Array{Int64} = vcat(report[1:problem_index-1], report[problem_index+1:end])
    return isnothing(is_safe_report(without_problem_index))
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(2)
    all_reports_as_strings::Array{String} = digest_as_lines(input_data)
    all_reports_as_ints::Vector{Vector{Int}} = [parse.(Int, split(report)) for report in all_reports_as_strings]

    println("Part 1: $(sum(is_safe_report.(all_reports_as_ints) .== nothing))")
    println("Part 2: $(sum(is_safe_report_with_tolerance.(all_reports_as_ints, 1)))")
end
