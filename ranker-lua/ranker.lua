-- vim:set ts=8 sts=4 sw=4 tw=0 et:

local function get_keys(prefix)
    return redis.call('KEYS', prefix .. '*')
end

local function get_score(pivot_key, key, tmpkey)
    redis.call('BITOP', 'AND', tmpkey, pivot_key, key)
    local count = redis.call('BITCOUNT', tmpkey)
    return count
end

local function get_score_list(pivot_key, keys, tmpkey)
    local list = {}
    for i, v in ipairs(keys) do
        local score = get_score(pivot_key, v, tmpkey)
        table.insert(list, { key=v, score=score })
    end
    redis.call('DEL', tmpkey)
    return list
end

local function compare_score(a, b)
    return a.score > b.score
end

local function get_heads(list, count, cmp, tostr)
    count = tonumber(count)
    table.sort(list, cmp)
    local heads = {}
    for i, v in ipairs(list) do
        table.insert(heads, tostr(v))
        if #heads >= count then
            break
        end
    end
    return heads
end

local function score2str(v)
    return v.key
    --return v.key .. ' score=' .. v.score
end

local function ranking(pivot_key, tmpkey, prefix, count)
    local keys = get_keys(prefix)
    local score_list = get_score_list(pivot_key, keys, tmpkey)
    local heads = get_heads(score_list, count, compare_score, score2str)
    return heads
end

return ranking(KEYS[1], KEYS[2], ARGV[1], ARGV[2])
