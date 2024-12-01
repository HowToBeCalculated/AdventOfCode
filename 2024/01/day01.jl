include("../utils.jl")


function get_day1_input()
    return fetch_input(1)
end

function produce_sorted_list_from_day1_input(input_data)::Tuple{Array{Int64, 1}, Array{Int64, 1}}
    list1 = Int64[]
    list2 = Int64[]

    for line in split(input_data, '\n')
        if line == ""
            continue
        end
        first, second = split(line)
        push!(list1, parse(Int64, first))
        push!(list2, parse(Int64, second))
    end

    sorted_list1 = sort!(list1)
    sorted_list2 = sort!(list2)

    return sorted_list1, sorted_list2
end

function calculate_sum_of_differences(sorted_list1, sorted_list2)
    sum_of_differences = 0

    for i in 1:length(sorted_list1)
        sum_of_differences += abs(sorted_list1[i] - sorted_list2[i])
    end

    return sum_of_differences
end

# inefficient as it doesn't need to scan the list as it's already sorted
function num_in_list(num, list)
    return sum(num .== list)
end

function calculate_similarity(sorted_list1, sorted_list2)
    similarity = 0
    j=0

    for i in 1:length(sorted_list1)
        left_num = sorted_list1[i]
        # while (right_num = sorted_list2[j]) < left_num
        #     j += 1
        # end

        times_in_right = num_in_list(left_num, sorted_list2)
        if times_in_right == 0
            continue
        end
        similarity += left_num * times_in_right
    end

    return similarity
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data = get_day1_input()
    sorted_list1, sorted_list2 = produce_sorted_list_from_day1_input(input_data)
    println("Part 1: $(calculate_sum_of_differences(sorted_list1, sorted_list2))")
    println("Part 2: $(calculate_similarity(sorted_list1, sorted_list2))")
end
