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


function digest_as_lines(input_data::String)::Array{String, 1}
    lines::Array{String, 1} = readlines(IOBuffer(input_data))
    return lines
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data = fetch_input(1)
    println(digest_as_lines(input_data))
end
