include("../utils.jl")


function read_in_input(input_data::String)::Tuple{Vector{Int64}, Vector{Vector{Int64}}}
    function digest_line(line::String)::Tuple{Int64, Vector{Int64}}
        # ex. `100: 10 20 30` -> 100, [10, 20, 30]`
        split_by_whitespace::Vector{String} = split(line)
        return (
            parse(Int64, split_by_whitespace[1][1:end-1]),
            [parse(Int64, num) for num in split_by_whitespace[2:end]]
        )
    end

    test_values::Vector{Int64} = Int64[]
    input_matrix::Array{Array{Int64, 1}, 1} = Array{Int64, 1}[]

    for line::String in digest_as_lines(input_data)
        test_value::Int64, inputs::Vector{Int64} = digest_line(line)
        push!(test_values, test_value)
        push!(input_matrix, inputs)
    end

    return (test_values, input_matrix)
end

function is_true_using_add_and_multiple(test_value::Int64, inputs::Vector{Int64})::Bool
    preceding_outputs::Vector{Int64} = [inputs[1]]
    remaining_inputs = inputs[2:end]

    while !isempty(remaining_inputs)
        next_num::Int64 = popfirst!(remaining_inputs)
        new_proceeding_outputs::Vector{Int64} = Int64[]
        for output in preceding_outputs
            if output > test_value
                return continue
            end
            push!(new_proceeding_outputs, output + next_num)
            push!(new_proceeding_outputs, output * next_num)
        end
        preceding_outputs = new_proceeding_outputs
    end
    return any(==(test_value), preceding_outputs) 
end

function is_true_with_concatenation(test_value::Int64, inputs::Vector{Int64})::Bool
    preceding_outputs::Vector{Int64} = [inputs[1]]
    remaining_inputs = inputs[2:end]

    while !isempty(remaining_inputs)
        next_num::Int64 = popfirst!(remaining_inputs)
        new_proceeding_outputs::Vector{Int64} = Int64[]
        for output in preceding_outputs
            if output > test_value
                return continue
            end
            push!(new_proceeding_outputs, output + next_num)
            push!(new_proceeding_outputs, output * next_num)

            # instead of str concat, push the output to the right magnitude (saves .5 seconds)
            magnitude = 10 ^ ceil(Int, log10(next_num + 1))
            push!(new_proceeding_outputs, (output * magnitude) + next_num)
        end
        preceding_outputs = new_proceeding_outputs
    end
    return any(==(test_value), preceding_outputs) 
end

function num_of_true_equations(test_values::Vector{Int64}, input_matrix::Vector{Vector{Int64}}, is_true_equation::Function)::Int64
    summed::Int64 = 0
    for (test_value, inputs) in zip(test_values, input_matrix)
        if is_true_equation(test_value, inputs)
            summed += test_value
        end
    end
    return summed
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(7)
    test_values::Vector{Int64}, input_matrix::Vector{Vector{Int64}} = read_in_input(input_data)
    @time println("Part 1: $(num_of_true_equations(test_values, input_matrix, is_true_using_add_and_multiple))")
    @time println("Part 2: $(num_of_true_equations(test_values, input_matrix, is_true_with_concatenation))")
end
