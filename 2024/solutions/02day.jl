include("../utils.jl")


MIN_DELTA::Int64 = 1
MAX_DELTA::Int64 = 3


function is_safe_report(report::Vector{Int64}, tolerance::Int64 = 0)::Bool
    last_num::Int64 = report[1]
    direction::Int64 = last_num - report[end] > 0 ? 1 : -1 

    for i in 2:length(report)
        num::Int64 = report[i]
        diff::Int64 = last_num - num

        if sign(diff) != direction || abs(diff) > MAX_DELTA || abs(diff) < MIN_DELTA
            if tolerance == 0
                return false
            end
            tolerance -= 1
            continue
        end
        last_num = num
    end

    return true
end

function is_safe_report_with_tolerance(report::Vector{Int64}, tolerance::Int64 = 1)::Bool
    # TODO: support tolerances other than 1
    @assert tolerance == 1 "Tolerance must be 1"

    # account for the first or last element being unsafe
    if is_safe_report(report[2:end]) || is_safe_report(report[1:end-1])
        return true
    end

    return is_safe_report(report, tolerance)
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(2)
    all_reports_as_strings::Vector{String} = digest_as_lines(input_data)
    all_reports_as_ints::Vector{Vector{Int}} = [parse.(Int, split(report)) for report in all_reports_as_strings]

    @time println("Part 1: $(sum(is_safe_report.(all_reports_as_ints)))")
    @time println("Part 2: $(sum(is_safe_report_with_tolerance.(all_reports_as_ints, 1)))")
end
