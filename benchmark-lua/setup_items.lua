-- vim:set ts=8 sts=4 sw=4 tw=0 et:

local function generate_key(n)
    return 'bench_item_' .. n
end

local function generate_value(n, len)
    local buffer = {}
    for i = 1, len do
        table.insert(buffer, math.random(0, 255))
    end
    return string.char(unpack(buffer))
end

local function data_setup(len, num)
    --math.randomseed(os.time())
    local count = 0
    for i = 0, num - 1 do
        redis.call('SET', generate_key(i), generate_value(i, len))
        count = count + 1
    end
    return count
end

return data_setup(ARGV[1], ARGV[2])
