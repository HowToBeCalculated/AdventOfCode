include("../utils.jl")


OPEN_POSITION = '.'
MULTIPLIER::Int64 = 2024


function follow_rule_for_digit(digit::Int64)::Vector{Int64}
    if digit == 0
        return [1]
    end

    magnitude = ceil(Int, log10(digit + 1))
    if isodd(magnitude)
        return [digit * MULTIPLIER]
    else
        magnitude /= 2
        tens_place::Int64 = 10 ^ (magnitude)
        left_digit::Int64 = floor(digit / tens_place)
        right_digit::Int64 = (digit - (left_digit * tens_place))
        return [left_digit, right_digit]
    end
end

function solve_for_num_steps(input_vector::Vector{Int64}, num_steps::Int64)::Vector{Int64}
    current_vector = copy(input_vector)
    for _ in 1:num_steps
        new_vector = Vector{Int64}[]
        for digit in current_vector
            next_digits = follow_rule_for_digit(digit)
            new_vector = vcat(new_vector, next_digits)
        end
        current_vector = new_vector
    end
    return current_vector
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(11)
    input_vector::Vector{Int64} = digest_as_vector_of_integers(input_data, " ")

    @time println("Part 1: $(length(solve_for_num_steps(input_vector, 25)))")
    # uncomment if you dare
    # @time println("Part 2: $(length(solve_for_num_steps(input_vector, 75)))")
end
