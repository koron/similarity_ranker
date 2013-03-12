-- vim:set ts=8 sts=4 sw=4 tw=0 et:

local KEYS_KEY = 'bench_keys'

local function generate_key(n)
    return 'bench_item_' .. n
end

local function choose_targets(start, count)
    redis.call('DELETE', KEYS_KEY)
    local last = start + count - 1
    for i = start, last do
        local key = generate_key(i)
        redis.call('LPUSH', KEYS_KEY, key)
    end
    return count
end

return choose_targets(ARGV[1], ARGV[2])
