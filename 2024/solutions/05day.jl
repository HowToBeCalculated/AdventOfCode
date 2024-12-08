include("../utils.jl")


struct PageValidator
    must_be_before_map::Dict{Int64, Set{Int64}}
end

PageValidator() = PageValidator(Dict{Int64, Set{Int64}}())

function add_rule!(page_validator::PageValidator, lower_page::Int64, higher_page::Int64)
    if haskey(page_validator.must_be_before_map, lower_page)
        push!(page_validator.must_be_before_map[lower_page], higher_page)
    else
        page_validator.must_be_before_map[lower_page] = Set([higher_page])
    end
end

function is_valid_page_order(page_validator::PageValidator, page_order::Vector{Int64})::Bool
    higher_pages::Set{Int64} = Set{Int64}([page_order[1]])
    for page in page_order[2:end]
        if !haskey(page_validator.must_be_before_map, page)
            continue
        else
            should_be_higher_pages::Set{Int64} = page_validator.must_be_before_map[page]
            if !isempty(intersect(higher_pages, should_be_higher_pages))
                return false
            else
                push!(higher_pages, page)
            end
        end
    end
    return true
end

function solve_part_1(page_validator::PageValidator, pages::Vector{Vector{Int64}})::Int64
    summed::Int64 = 0
    for page_order in pages
        if is_valid_page_order(page_validator, page_order)
            middle_index::Int64 = (length(page_order) + 1) / 2
            summed += page_order[middle_index]  
        end
    end
    return summed
end

function find_invalid_pages(page_validator::PageValidator, page_order::Vector{Int64})::Tuple{Vector{Int64}, Vector{Int64}}
    higher_pages::Vector{Int64} = Vector{Int64}([page_order[1]])
    invalid_pages::Vector{Int64} = Int64[]
    for page in page_order[2:end]
        if !haskey(page_validator.must_be_before_map, page)
            continue
        else
            should_be_higher_pages::Set{Int64} = page_validator.must_be_before_map[page]
            if !isempty(intersect(higher_pages, should_be_higher_pages))
                push!(invalid_pages, page)
            else
                push!(higher_pages, page)
            end
        end
    end
    return invalid_pages, higher_pages
end

function solve_part_2(page_validator::PageValidator, pages::Vector{Vector{Int64}})::Int64
    summed::Int64 = 0
    for page_order in pages
        invalid_pages, valid_pages = find_invalid_pages(page_validator, page_order)

        if isempty(invalid_pages)
            continue
        end
        while !isempty(invalid_pages)
            for invalid_page in invalid_pages
                for i in 1:length(valid_pages)
                    test_page_order = copy(valid_pages)
                    insert!(test_page_order, i, invalid_page)
                    if is_valid_page_order(page_validator, test_page_order)
                        valid_pages = test_page_order
                        deleteat!(invalid_pages, findfirst(==(invalid_page), invalid_pages))
                        break
                    end
                end
            end
        end
        middle_index::Int64 = (length(valid_pages) + 1) / 2
        summed += valid_pages[middle_index]
    end
    return summed
end

function construct_page_validator_and_get_lines(input_data::String)::Tuple{PageValidator, Vector{Vector{Int64}}}
    lines::Vector{String} = digest_as_lines(input_data)
    rule_to_page_split = findfirst(==(""), lines)

    page_validator::PageValidator = PageValidator()
    for line in lines[1:rule_to_page_split-1]
        lower_page, higher_page = split(line, "|")
        add_rule!(page_validator, parse(Int64, lower_page), parse(Int64, higher_page))
    end

    pages::Vector{Vector{Int64}} = [parse.(Int, split(page, ",")) for page in lines[rule_to_page_split+1:end]]

    return page_validator, pages
end


if abspath(PROGRAM_FILE) === @__FILE__
    input_data::String = fetch_input(5)
    page_validator::PageValidator, pages::Vector{Vector{Int64}} = construct_page_validator_and_get_lines(input_data)
    @time println(solve_part_1(page_validator, pages))
    @time println(solve_part_2(page_validator, pages))
end
