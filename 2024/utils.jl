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


function delimit_each_line_by_whitespace(input_data::String)::Array{Array{String, 1}, 1}
    for line in split(input_data, '\n')
        println(split(line))
    end
end

if abspath(PROGRAM_FILE) === @__FILE__
    # Sample
    day = 1
    input_data = fetch_input(day)
    println(delimit_each_line_by_whitespace(input_data))
end
