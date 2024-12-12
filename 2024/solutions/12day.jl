include("../utils.jl")


NUM_OF_SIDES_OF_SQUARE::Int64 = 4

up_down::Vector{Coordinates} = Coordinates[
    (1, 0),
    (-1, 0),
]

left_right::Vector{Coordinates} = Coordinates[
    (0, -1),
    (0, 1),
]

up_down_left_right::Vector{Coordinates} = vcat(up_down, left_right)


struct GardenBed
    plant::Char
    locations::Set{Coordinates}
end

function determine_perimeter(garden_bed::GardenBed)::Int64
    perimeter::Int64 = NUM_OF_SIDES_OF_SQUARE * length(garden_bed.locations)
    for location in garden_bed.locations
        for direction in up_down_left_right
            if (location .+ direction) in garden_bed.locations
                perimeter -= 1
            end
        end
    end
    return perimeter
end

function find_all_garden_beds(input_matrix::Array{Char, 2})::Vector{GardenBed}
    garden_beds::Vector{GardenBed} = GardenBed[]
    visited::Set{Coordinates} = Set{Coordinates}()
    is_in_bounds = make_in_bounds_function(size(input_matrix)...)

    function explore_garden_bed(location::Coordinates, plant::Char)::Nothing
        if location in visited
            return nothing
        end

        garden_bed = GardenBed(plant, Set{Coordinates}())
        frontier = [location]

        while !isempty(frontier)
            location = popfirst!(frontier)
            if location in visited
                continue
            end

            push!(visited, location)
            push!(garden_bed.locations, location)

            for direction in up_down_left_right
                next_location = location .+ direction
                if next_location in visited
                    continue
                end

                if !is_in_bounds(next_location)
                    continue
                end

                if input_matrix[next_location...] == plant
                    push!(frontier, next_location)
                end
            end
        end

        push!(garden_beds, garden_bed)
        return nothing
    end

    for idx in CartesianIndices(input_matrix)
        location = Tuple(idx)
        if location in visited
            continue
        end
        explore_garden_bed(location, input_matrix[location...])
    end

    return garden_beds
end

function get_price_of_garden_beds(garden_beds::Vector{GardenBed}, fence_function::Function)::Int64
    return sum(fence_function(garden_bed) * length(garden_bed.locations) for garden_bed in garden_beds)
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(12)
    input_matrix::Array{Char, 2} = hcat(digest_as_vector_of_vectors(input_data)...)

    garden_beds::Vector{GardenBed} = find_all_garden_beds(input_matrix)
    println("Part 1: $(get_price_of_garden_beds(garden_beds, determine_perimeter))")
end
