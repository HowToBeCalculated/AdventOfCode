include("../utils.jl")


OPEN_POSITION = '.'


function parse_inputs_as_integers(input_data::String)::Vector{Int64}
    if input_data[end] == '\n'
        input_data = input_data[1:end-1]
    end
    return parse.(Int64, split(input_data, ""))
end

function make_open_positions_view(input_vector::Vector{Int64})::Vector{Union{Int64, Nothing}}
    block_space::Vector{Union{Int64, Nothing}} = []
    idx = 0
    iter = Iterators.Stateful(input_vector)

    while true
        # the first element is the number of blocks used
        blocks_used = popfirst!(iter)
        for _ in 1:blocks_used
            push!(block_space, idx)
        end
        idx += 1

        # this will be empty for the last element (i.e. odd # of elements)
        if isempty(iter)
            break
        end

        # the subsequent element is the number of free blocks
        free_blocks = popfirst!(iter)
        for _ in 1:free_blocks
            push!(block_space, nothing)
        end
    end
    return block_space
end

function file_system_fragmentation(block_space::Vector{Union{Int64, Nothing}})::Vector{Union{Int64, Nothing}}
    condensed_space::Vector{Union{Int64, Nothing}} = []
    last_block_number = length(block_space) + 1

    for (idx, block) in enumerate(block_space)

        # is we are at the last block, we have gone through all the blocks
        if (idx == last_block_number)
            break
        end

        if isnothing(block)
            # push last non-nothing block to the condensed space if current block is nothing
            while isnothing(block)
                last_block_number -= 1
                block = block_space[last_block_number]
            end
            push!(condensed_space, block)
        else
            push!(condensed_space, block)
        end
    end
    return condensed_space
end

function shift_whole_files(block_space::Vector{Union{Int64, Nothing}})::Vector{Union{Int64, Nothing}}
    condensed_rle::Vector{Tuple{Union{Int64, Nothing}, Int64}} = []
    rle::Vector{Tuple{Union{Int64, Nothing}, Int64}} = run_length_encoding(block_space)
    all_set_files::Vector{Int64} = []

    while !isempty(rle)
        file_num, file_size = popfirst!(rle)

        # if the file number is not in an open position, keep going
        # skip if the file number is already in the set since its space can be reused
        # WARNING: it's not exactly optimal as if a file is already condensed, it should combine
        # its space with the surrounding open space to allow larger files to fill in its open space
        if !isnothing(file_num) && !(file_num in all_set_files)
            push!(all_set_files, file_num)
            push!(condensed_rle, (file_num, file_size))
            continue
        end

        # try to fill empty space with files
        while file_size > 0
            any_change::Bool = false

            # iterate through the run length encoding in decreasing order (priority)
            for (i_file_num, i_file_size) in reverse(rle)
                if isnothing(i_file_num) || (i_file_num in all_set_files)
                    continue
                end

                # if a priority file has the size, add it in and update the file size (open space)
                if i_file_size <= file_size
                    file_size -= i_file_size
                    push!(all_set_files, i_file_num)
                    push!(condensed_rle, (i_file_num, i_file_size))
                    any_change = true
                    break
                end
            end

            # if we had a full iteration with no changes, we can continue
            if !any_change
                push!(condensed_rle, (nothing, file_size))
                break
            end
        end
    end
    return unravel_run_length_encoding(condensed_rle)
end

function determine_condense_score(
    block_space::Vector{Union{Int64, Nothing}},
    condense_function::Function
)::Int64
    condensed_space = condense_function(block_space)
    score = 0
    for (idx, block) in enumerate(condensed_space)
        if isnothing(block)
            continue
        end
        # account for 1-based indexing in Julia
        score += (idx - 1) * block
    end
    return score
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(9)
    input_vector::Vector{Int64} = parse_inputs_as_integers(input_data)

    block_space = make_open_positions_view(input_vector)

    @time println("Part 1: $(determine_condense_score(block_space, file_system_fragmentation))")
    @time println("Part 2: $(determine_condense_score(block_space, shift_whole_files))")
end
