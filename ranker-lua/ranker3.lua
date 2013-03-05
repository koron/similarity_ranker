-- vim:set ts=8 sts=4 sw=4 tw=0 et:

local function truncate_scores(score_key, limit)
    local count = redis.call('ZCARD', score_key) - limit
    if count > 0 then
        redis.call('ZREMRANGEBYRANK', score_key, 0, count - 1)
    end
end

local function get_score(pivot_key, target_key, tmp_key)
    redis.call('BITOP', 'OR', tmp_key, pivot_key, target_key)
    local base = redis.call('BITCOUNT', tmp_key)
    if base == 0 then
        return 1.0
    end
    redis.call('BITOP', 'AND', tmp_key, pivot_key, target_key)
    local score = redis.call('BITCOUNT', tmp_key)
    return score / base
end

local function append_scores(pivot_key, targets, score_key, tmp_key)
    for i, v in ipairs(targets) do
        if pivot_key ~= v then
            local score = get_score(pivot_key, v, tmp_key)
            redis.call('ZADD', score_key, score, v)
        end
    end
end

local function get_tail(start, max, offset)
    local tail = start + offset
    if tail > max then
        tail = max
    end
    return tail - 1
end

local function ranking3(pivot_key, keys_key, score_key, tmp_key, limit, offset)
    redis.call('DEL', score_key)
    local keys_len = redis.call('LLEN', keys_key)
    local curr = 0
    while curr < keys_len do
        local tail = get_tail(curr, keys_len, offset)
        local keys = redis.call('LRANGE', keys_key, curr, tail)
        append_scores(pivot_key, keys, score_key, tmp_key)
        truncate_scores(score_key, limit)
        curr = tail + 1
    end
    local retval = redis.call('ZREVRANGE', score_key, 0, -1, 'WITHSCORES')
    redis.call('DEL', tmp_key)
    return retval
end

return ranking3(KEYS[1], KEYS[2], KEYS[3], KEYS[4], ARGV[1], 5000)
