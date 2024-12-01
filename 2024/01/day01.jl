include("../utils.jl")


function get_day1_input()::String
    return fetch_input(1)
end

function produce_sorted_list_from_day1_input(input_data::String)::Tuple{Array{Int64, 1}, Array{Int64, 1}}
    list1::Array{Int64, 1} = Int64[]
    list2::Array{Int64, 1} = Int64[]

    for line in split(input_data, '\n')
        if line == ""
            continue
        end
        first, second = split(line)
        push!(list1, parse(Int64, first))
        push!(list2, parse(Int64, second))
    end

    sorted_list1::Array{Int64, 1} = sort!(list1)
    sorted_list2::Array{Int64, 1} = sort!(list2)

    return sorted_list1, sorted_list2
end

function calculate_sum_of_differences(sorted_list1::Array{Int64, 1}, sorted_list2::Array{Int64, 1})
    # Interestingly, this function is ok here in this scope but Julia complains if a loop otherwise updates global var
    sum_of_differences::Int64 = 0

    for i in 1:length(sorted_list1)
        sum_of_differences += abs(sorted_list1[i] - sorted_list2[i])
    end

    return sum_of_differences
end

# inefficient as it doesn't need to scan the list as it's already sorted
function num_in_list(num::Int64, list::Array{Int64, 1})::Int64
    return sum(num .== list)
end

function calculate_similarity(sorted_list1::Array{Int64, 1}, sorted_list2::Array{Int64, 1})::Int64
    similarity::Int64 = 0

    queued_up::Int64 = -1
    num_of::Int64 = 0
    j::Int64 = 1

    max_len::Int64 = length(sorted_list1)

    for i in 1:max_len
        left_num::Int64 = sorted_list1[i]

        # if the left number is the same as the last number we queued up, we can skip the search
        if left_num == queued_up
            similarity += left_num * num_of
            continue
        end

        # find the first time the left number appears in the right list
        while (right_num = sorted_list2[j]) < left_num && j < max_len
            j += 1
        end

        # count how many times the left number appears in the right list
        num_of = 0
        while (right_num = sorted_list2[j]) == left_num
            num_of += 1
            j += 1
        end

        queued_up = left_num
        similarity += left_num * num_of
    end

    return similarity
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data = get_day1_input()
    sorted_list1, sorted_list2 = produce_sorted_list_from_day1_input(input_data)
    println("Part 1: $(calculate_sum_of_differences(sorted_list1, sorted_list2))")
    println("Part 2: $(calculate_similarity(sorted_list1, sorted_list2))")
end