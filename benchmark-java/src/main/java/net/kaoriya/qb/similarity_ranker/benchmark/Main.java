package net.kaoriya.qb.similarity_ranker.benchmark;

import java.util.Set;
import java.util.Random;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public class Main
{
    public static final String PREFIX = "bench_item_";
    public static final String KEYS_KEY = "bench_keys";

    public static String generateKey(String prefix, int n)
    {
        return prefix + n;
    }

    public static byte[] generateValue(Random r, int size) throws Exception
    {
        byte[] b = new byte[size];
        r.nextBytes(b);
        return b;
    }

    public static void setBits(
            Jedis jedis,
            String key,
            byte[] value)
    {
        jedis.del(key);
        for (int i = 0; i < value.length; ++i) {
            int n = (int)value[i] & 0xFF;
            for (int j = 0; j < 8; ++j) {
                if ((n & (0x80 >> j)) != 0) {
                    jedis.setbit(key, i * 8 + j, true);
                }
            }
        }
    }

    public static void setupData(
            Jedis jedis,
            int size,
            int count,
            String keysKey)
        throws Exception
    {
        jedis.del(keysKey);
        Random r = new Random();
        for (int i = 0; i < count; ++i)
        {
            String key = generateKey(PREFIX, i);
            byte[] value = generateValue(r, size);
            //setBits(jedis, key, value);
            jedis.lpush(keysKey, key);
        }
    }

    public static void benchmark(
            String name,
            String host,
            final int size,
            final int count)
        throws Exception
    {
        JedisPool pool = new JedisPool(new JedisPoolConfig(), host);
        final Jedis jedis = pool.getResource();
        try {
            new Measure("setupData") {
                protected void execute() throws Exception {
                    setupData(jedis, size, count, KEYS_KEY);
                }
            }.run();
            Set<String> keys = jedis.keys("*");
        } finally {
            pool.returnResource(jedis);
        }
        pool.destroy();
    }

    public static void main(String[] args) throws Exception
    {
        benchmark("first", "avalon", 64, 1000);
    }
}
