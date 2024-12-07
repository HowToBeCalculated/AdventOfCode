include("../utils.jl")

OBSTACLE = '#'
OPEN_POSITION = '.'
TRAVEL_MARKER = 'X'

struct Direction
    symbol::Char
    h::Int8
    v::Int8
end

UP = Direction('^', -1, 0)
RIGHT = Direction('>', 0, 1)
DOWN = Direction('v', 1, 0)
LEFT = Direction('<', 0, -1)

direction_map::Dict{Char, Direction} = Dict{Char, Direction}(
    UP.symbol => UP,
    RIGHT.symbol => RIGHT,
    DOWN.symbol => DOWN,
    LEFT.symbol => LEFT
)

# Rotate 90 degrees to the right
next_direction_map::Dict{Direction, Direction} = Dict{Direction, Direction}(
    UP => RIGHT,
    RIGHT => DOWN,
    DOWN => LEFT,
    LEFT => UP
)

function get_next_direction(direction::Direction)::Direction
    return next_direction_map[direction]
end

mutable struct Guard
    location::Tuple{Int64, Int64}
    direction::Direction
    has_left::Bool
end

function move_one_space(guard::Guard, input_matrix::Array{Array{Char, 1}, 1})::Nothing
    # determine the next location
    current_i, current_j = guard.location
    add_i, add_j = guard.direction.h, guard.direction.v
    next_location = (current_i + add_i, current_j + add_j)

    # if going out of bounds, the guard has left the area
    if next_location[1] < 1 || next_location[1] > length(input_matrix) || next_location[2] < 1 || next_location[2] > length(input_matrix[1])
        guard.has_left = true
    
    # if hitting an obstacle, find the next direction
    elseif input_matrix[next_location[1]][next_location[2]] == OBSTACLE
        guard.direction = get_next_direction(guard.direction)

    # move to the next location
    else
        guard.location = next_location
    end

    return nothing
end

function find_guard(input_matrix::Array{Array{Char, 1}, 1})::Guard
    for n in eachindex(input_matrix), m in eachindex(input_matrix[n])
        if input_matrix[m][n] in direction_map.keys
            return Guard((m, n), direction_map[input_matrix[m][n]], false)
        end
    end
    @assert false "Must have a guard"
end

function guard_traveled_spaces(input_matrix::Array{Array{Char, 1}, 1})::Int64
    guard::Guard = find_guard(input_matrix)
    traveled_map = deepcopy(input_matrix)

    while !guard.has_left
        traveled_map[guard.location[1]][guard.location[2]] = TRAVEL_MARKER
        move_one_space(guard, input_matrix)
        traveled_map[guard.location[1]][guard.location[2]] = guard.direction.symbol
    end

    # account for the last position that shows the guard leaving
    num_traveled = 1
    for n in eachindex(input_matrix), m in eachindex(input_matrix[n])
        if traveled_map[m][n] == TRAVEL_MARKER
            num_traveled += 1
        end
    end

    return num_traveled
end

function find_all_initial_open_positions(input_matrix::Array{Array{Char, 1}, 1})::Array{Tuple{Int64, Int64}, 1}
    open_positions::Array{Tuple{Int64, Int64}, 1} = []
    for n in eachindex(input_matrix), m in eachindex(input_matrix[n])
        if input_matrix[m][n] == OPEN_POSITION
            push!(open_positions, (m, n))
        end
    end
    return open_positions
end

function ways_to_form_guard_loops(input_matrix::Array{Array{Char, 1}, 1})::Int64
    starting_guard::Guard = find_guard(input_matrix)

    num_loops = 0
    for position in find_all_initial_open_positions(input_matrix)

        # reset the guard and the travel record
        guard::Guard = deepcopy(starting_guard)
        travel_record::Array{Tuple{Char, Int64, Int64}, 1} = []

        # add in the obstacle to test
        with_position_matrix = deepcopy(input_matrix)
        with_position_matrix[position[1]][position[2]] = OBSTACLE

        while !guard.has_left
            new_record = (guard.direction.symbol, guard.location[1], guard.location[2])
            if new_record in travel_record
                num_loops += 1
                break
            end
            travel_record = push!(travel_record, new_record)
            move_one_space(guard, with_position_matrix)
        end
    end

    return num_loops
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(6)
    input_matrix::Array{Array{Char, 1}, 1} = digest_as_matrix(input_data)
    @time println("Part 1: $(guard_traveled_spaces(input_matrix))")
    @time println("Part 2: $(ways_to_form_guard_loops(input_matrix))")
end
