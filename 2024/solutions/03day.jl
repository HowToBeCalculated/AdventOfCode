include("../utils.jl")


MUL_REGEX = r"mul\((\d{1,3}),(\d{1,3})\)"
DO = "do()"
DONT = "don't()"


function perform_each_valid_mul(input_data::String)::Int64
    summed::Int64 = 0

    for match in eachmatch(MUL_REGEX, input_data)
        summed += parse(Int64, match.captures[1]) * parse(Int64, match.captures[2])
    end

    return summed
end

function clean_input_for_dos_and_donts(input_data::String)::String
    # add dummy tags at end to ensure last section is added
    processed_string = input_data * DO * DONT
    # start in a state of being allowed
    is_allowed::Bool = true

    cleaned_parts::Vector{String} = String[]

    while processed_string != ""
        # look for next DONT if in DO state, or vice versa
        next_state_switch_term = is_allowed ? DONT : DO
        next_section, processed_string = split(processed_string, next_state_switch_term, limit=2)

        # if in a state of being allowed, add the section
        if is_allowed
            push!(cleaned_parts, next_section)
        end

        is_allowed = !is_allowed
    end

    return join(cleaned_parts)
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(3)

    @time println("Part 1: $(perform_each_valid_mul(input_data))")
    @time println("Part 2: $(perform_each_valid_mul(clean_input_for_dos_and_donts(input_data)))")
end
