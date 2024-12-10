include("../utils.jl")


const Coordinates = Tuple{Int64, Int64}

TRAIL_HEAD = 0
TRAIL_END = 9


up_down_left_right::Vector{Coordinates} = Coordinates[
    (-1, 0),
    (1, 0),
    (0, -1),
    (0, 1),
]

function parse_inputs_as_integers(input_vector::String)::Vector{Vector{Int64}}
    res::Vector{Vector{Int64}} = [parse.(Int64, split(line, "")) for line in digest_as_lines(input_vector)]
    return res
end

mutable struct Trail
    starting_location::Coordinates
    traveled::Vector{Coordinates}
    frontier::Vector{Coordinates}
    ending_locations::Vector{Coordinates}
end

function move_one_space(trail::Trail, input_matrix::Vector{Vector{Int64}})::Nothing
    inbounds_function = make_in_bounds_function(length(input_matrix), length(input_matrix[1]))
    new_frontier::Vector{Coordinates} = Coordinates[]

    for location in trail.frontier
        elevation = input_matrix[location[1]][location[2]]
        push!(trail.traveled, location)

        for (i, j) in up_down_left_right
            next_location = location .+ (i, j)

            if !inbounds_function(next_location) || (input_matrix[next_location[1]][next_location[2]] - elevation) != 1
                continue
            end

            next_elevation = input_matrix[next_location[1]][next_location[2]]
            if next_location in trail.traveled
                continue
            elseif next_elevation == TRAIL_END
                push!(trail.ending_locations, next_location)
            else
                push!(new_frontier, next_location)
            end
        end
    end

    trail.frontier = new_frontier
    return nothing
end

function find_all_trail_heads(input_matrix::Vector{Vector{Int64}})::Vector{Trail}
    trail_heads::Vector{Trail} = Trail[]

    # Took out the following: for idx in CartesianIndices(input_matrix)
    # Julia arrays are column-major which was messing me up when trying to use Array{Int64, 2} instead of Vector{Vector{Int64}}
    for (i, row) in enumerate(input_matrix)
        for (j, elevation) in enumerate(row)
            if elevation == TRAIL_HEAD
                push!(trail_heads, Trail((i, j), Vector{Tuple{Int64, Int64}}(), [(i, j),], Vector{Tuple{Int64, Int64}}()))
            end
        end
    end

    return trail_heads
end

function fill_out_trails(trail_heads::Vector{Trail}, input_matrix::Vector{Vector{Int64}})::Nothing
    for trail in trail_heads
        while !isempty(trail.frontier)
            move_one_space(trail, input_matrix)
        end
    end
    return nothing
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(10)

    input_matrix::Vector{Vector{Int64}} = parse_inputs_as_integers(input_data)
    trail_heads::Vector{Trail} = find_all_trail_heads(input_matrix)

    @time fill_out_trails(trail_heads, input_matrix)
    println("Part 1: $(sum([length(Set(trail.ending_locations)) for trail in trail_heads]))")
    println("Part 2: $(sum([length(trail.ending_locations) for trail in trail_heads]))")
end
