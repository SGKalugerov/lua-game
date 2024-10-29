function FirstOrDefault(collection, predicate)
    for _, item in ipairs(collection) do
        if predicate(item) then
            return item
        end
    end
    return nil
end

function Where(collection, predicate)
    local result = {}
    for _, item in ipairs(collection) do
        if predicate(item) then
            table.insert(result, item)
        end
    end
    return result
end

function Contains(collection, item)
    for _, value in ipairs(collection) do
        if value == item then
            return true
        end
    end
    return false
end

function Select(collection, selector)
    local result = {}
    for _, item in ipairs(collection) do
        table.insert(result, selector(item))
    end
    return result
end

function Any(collection, predicate)
    for _, item in ipairs(collection) do
        if predicate(item) then
            return true
        end
    end
    return false
end

function All(collection, predicate)
    for _, item in ipairs(collection) do
        if not predicate(item) then
            return false
        end
    end
    return true
end

function Count(collection, predicate)
    local count = 0
    for _, item in ipairs(collection) do
        if predicate(item) then
            count = count + 1
        end
    end
    return count
end

function First(collection)
    if #collection > 0 then
        return collection[1]
    end
    return nil
end

function Last(collection)
    if #collection > 0 then
        return collection[#collection]
    end
    return nil
end

function Take(collection, count)
    local result = {}
    for i = 1, math.min(count, #collection) do
        table.insert(result, collection[i])
    end
    return result
end

function Skip(collection, count)
    local result = {}
    for i = count + 1, #collection do
        table.insert(result, collection[i])
    end
    return result
end

function Sum(collection, selector)
    local sum = 0
    for _, item in ipairs(collection) do
        sum = sum + selector(item)
    end
    return sum
end

function Max(collection, selector)
    local maxValue = selector(collection[1])
    for _, item in ipairs(collection) do
        local value = selector(item)
        if value > maxValue then
            maxValue = value
        end
    end
    return maxValue
end

function Min(collection, selector)
    local minValue = selector(collection[1])
    for _, item in ipairs(collection) do
        local value = selector(item)
        if value < minValue then
            minValue = value
        end
    end
    return minValue
end

function FindIndex(collection, predicate)
    for index, item in ipairs(collection) do
        if predicate(item) then
            return index
        end
    end
    return nil
end

return {
    FirstOrDefault = FirstOrDefault,
    Where = Where,
    Contains = Contains,
    Select = Select,
    Any = Any,
    All = All,
    Count = Count,
    First = First,
    Last = Last,
    Take = Take,
    Skip = Skip,
    Sum = Sum,
    Max = Max,
    Min = Min,
    FindIndex = FindIndex
}
