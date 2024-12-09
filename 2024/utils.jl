using DotEnv
using HTTP

DotEnv.load!()

function fetch_input(day::Int, year::Int = 2024)::Union{String, Nothing}
    url = "https://adventofcode.com/$year/day/$day/input"

    # Need session cookie to fetch input
    session = ENV["SESSION"]
    headers = ["Cookie" => "session=$session"]

    response = HTTP.get(url, headers)
    
    if response.status == 200
        return String(response.body)
    else
        error("Failed to fetch input for day $day. HTTP Status: ", response.status)
        return nothing
    end
end

function digest_as_lines(input_data::String)::Vector{String}
    lines::Array{String, 1} = readlines(IOBuffer(input_data))
    return lines
end

function digest_as_vector_of_vectors(input_data::String)::Vector{Vector{Char}}
    lines::Array{String, 1} = readlines(IOBuffer(input_data))
    matrix::Vector{Vector{Char}} = [collect(line) for line in lines]
    return matrix
end

function combination_2(arr::Vector{T})::Vector{Tuple{T, T}} where T
    combinations::Vector{Tuple{T, T}} = Tuple{T, T}[]
    for i in 1:length(arr)
        for j in i+1:length(arr)
            push!(combinations, (arr[i], arr[j]))
        end
    end
    return combinations
end

function make_in_bounds_function(n::Int64, m::Int64)::Function
    function f(x::Tuple{Int64, Int64})::Bool
        i, j = x
        return 1 <= i <= n && 1 <= j <= m
    end
    return f
end

function run_length_encoding(arr::Vector{T})::Vector{Tuple{T, Int64}} where T
    result::Vector{Tuple{T, Int64}} = Tuple{T, Int64}[]

    # initialize the first element
    current_element = arr[1]
    current_count = 1

    for i in 2:length(arr)
        if arr[i] == current_element
            current_count += 1
        else
            push!(result, (current_element, current_count))
            current_element = arr[i]
            current_count = 1
        end
    end

    # push the last element
    push!(result, (current_element, current_count))

    return result
end

function unravel_run_length_encoding(arr::Vector{Tuple{T, Int64}})::Vector{T} where T
    result::Vector{T} = T[]
    for (element, count) in arr
        for _ in 1:count
            push!(result, element)
        end
    end
    return result
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data = fetch_input(4)
    println(digest_as_vector_of_vectors(input_data))
end
