include("../utils.jl")


WORD::String = "XMAS"

struct Direction
    h::Int8
    v::Int8
end


ALL_DIRECTIONS::Array{Direction, 1} = [
    Direction(0, 1),
    Direction(1, 0),
    Direction(0, -1),
    Direction(-1, 0),
    Direction(1, 1),
    Direction(1, -1),
    Direction(-1, 1),
    Direction(-1, -1),
]


function helper_follow_line(
    input_matrix::Vector{Vector{Char}},
    start::Tuple{Int64, Int64},
    direction::Direction,
    rest_of_word::String
)::Bool
    i, j = start
    for char in rest_of_word
        new_i = i + direction.h
        new_j = j + direction.v

        # out of bounds check
        if new_i < 1 || new_i > length(input_matrix) || new_j < 1 || new_j > length(input_matrix[1])
            return false
        end

        if input_matrix[new_i][new_j] != char
            return false
        end
        i, j = new_i, new_j
    end
    return true
end

function solve_word_search(input_matrix::Vector{Vector{Char}}, word::String = WORD)::Int64
    first_char::Char = word[1]
    rest_of_word::String = word[2:end]
    cnt::Int64 = 0

    for (i, line) in enumerate(input_matrix)
        for (j, char) in enumerate(line)
            if char != first_char
                continue
            end
            for direction in ALL_DIRECTIONS
                if helper_follow_line(input_matrix, (i, j), direction, rest_of_word)
                    cnt += 1
                end
            end
        end
    end
    return cnt
end


function x_marks_the_spot(
    input_matrix::Vector{Vector{Char}},
    start::Tuple{Int64, Int64},
    full_word::String
)::Bool
    @assert length(full_word) == 3 "Only works for 3 letter words"
    i, j = start

    # out of bounds check
    if i == 1 || i == length(input_matrix) || j == 1 || j == length(input_matrix[1])
        return false
    end

    matching_set::Set{Char} = Set{Char}([full_word[1], full_word[3]])

    left_slash::Set{Char} = Set{Char}()
    push!(left_slash, input_matrix[i-1][j-1])
    push!(left_slash, input_matrix[i+1][j+1])

    if left_slash != matching_set
        return false
    end

    right_slash::Set{Char} = Set{Char}()
    push!(right_slash, input_matrix[i-1][j+1])
    push!(right_slash, input_matrix[i+1][j-1])

    if right_slash != matching_set
        return false
    end

    return true
end

function solve_x_search(input_matrix::Vector{Vector{Char}}, word::String = WORD[2:end])::Int64
    @assert length(word) == 3 "Only works for 3 letter words"

    middle_char = word[2]
    cnt = 0

    for (i, line) in enumerate(input_matrix)
        for (j, char) in enumerate(line)
            if char != middle_char
                continue
            end
            if x_marks_the_spot(input_matrix, (i, j), word)
                cnt += 1
            end
        end
    end
    return cnt
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(4)
    input_matrix::Vector{Vector{Char}} = digest_as_vector_of_vectors(input_data)

    @time println("Part 1: $(solve_word_search(input_matrix))")
    @time println("Part 2: $(solve_x_search(input_matrix))")
end
