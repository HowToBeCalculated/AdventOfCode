include("../utils.jl")

OPEN_POSITION = '.'

function product_antenna_map_locations(input_vec_of_vecs::Vector{Vector{Char}})::Dict{Char, Vector{Tuple{Int64, Int64}}}
    antenna_map::Dict{Char, Vector{Tuple{Int64, Int64}}} = Dict{Char, Vector{Tuple{Int64, Int64}}}()

    function add_to_antenna_map(char::Char, i::Int64, j::Int64)::Nothing
        if haskey(antenna_map, char)
            push!(antenna_map[char], (i, j))
        else
            antenna_map[char] = [(i, j)]
        end
        return nothing
    end

    for (i, line) in enumerate(input_vec_of_vecs)
        for (j, char) in enumerate(line)
            if char != OPEN_POSITION
                add_to_antenna_map(char, i, j)
            end
        end
    end
    return antenna_map
end

function determine_rise_and_run(
    location_1::Tuple{Int64, Int64},
    location_2::Tuple{Int64, Int64}
)::Tuple{Int64, Int64}
    rise = location_2[1] - location_1[1]
    run = location_2[2] - location_1[2]
    return rise, run
end

function get_either_side_between_locations(
    location_1::Tuple{Int64, Int64},
    location_2::Tuple{Int64, Int64},
    is_in_bounds::Function,
)::Vector{Tuple{Int64, Int64}}
    rise, run = determine_rise_and_run(location_1, location_2)
    result::Vector{Tuple{Int64, Int64}} = Tuple{Int64, Int64}[]

    other_side_1 = (location_1[1] - rise, location_1[2] - run)
    is_in_bounds(other_side_1) && push!(result, other_side_1)

    other_side_2 = (location_2[1] + rise, location_2[2] + run)
    is_in_bounds(other_side_2) && push!(result, other_side_2)

    return result
end

function get_all_anti_node_locations(
    location_1::Tuple{Int64, Int64},
    location_2::Tuple{Int64, Int64},
    is_in_bounds::Function,
)::Vector{Tuple{Int64, Int64}}
    rise, run = determine_rise_and_run(location_1, location_2)
    result::Vector{Tuple{Int64, Int64}} = Tuple{Int64, Int64}[location_1, location_2]

    while true
        location_1 = (location_1[1] - rise, location_1[2] - run)
        if !is_in_bounds(location_1)
            break
        end
        push!(result, location_1)
    end

    while true
        location_2 = (location_2[1] + rise, location_2[2] + run)
        if !is_in_bounds(location_2)
            break
        end
        push!(result, location_2)
    end

    return result
end

function count_anti_nodes(
    antenna_map::Dict{Char, Vector{Tuple{Int64, Int64}}},
    num_of_rows::Int64,
    num_of_cols::Int64,
    anti_node_location_function::Function,
)::Int64
    is_in_bounds::Function = make_in_bounds_function(num_of_rows, num_of_cols)
    anti_nodes::Set{Tuple{Int64, Int64}} = Set{Tuple{Int64, Int64}}()
    for (_, locations) in antenna_map
        for (location_i, location_j) in combination_2(locations)
            union!(anti_nodes, anti_node_location_function(location_i, location_j, is_in_bounds))
        end
    end

    return length(anti_nodes)
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(8)
    input_vec_of_vecs::Vector{Vector{Char}} = digest_as_vector_of_vectors(input_data)
    num_of_rows = length(input_vec_of_vecs)
    num_of_cols = length(input_vec_of_vecs[1])
    antenna_map::Dict{Char, Vector{Tuple{Int64, Int64}}} = product_antenna_map_locations(input_vec_of_vecs)
    @time println("Part 1: $(count_anti_nodes(antenna_map, num_of_rows, num_of_cols, get_either_side_between_locations))")
    @time println("Part 2: $(count_anti_nodes(antenna_map, num_of_rows, num_of_cols, get_all_anti_node_locations))")
end
