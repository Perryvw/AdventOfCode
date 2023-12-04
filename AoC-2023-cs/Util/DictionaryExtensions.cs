namespace AoC2023;

internal static class DictionaryExtensions
{
    internal static TValue GetOrAdd<TKey, TValue>(this IDictionary<TKey, TValue> dict, TKey key, Func<TKey, TValue> v)
    {
        if (dict.TryGetValue(key, out var value))
        {
            return value;
        }
        else
        {
            var val = v(key); dict.Add(key, val); return val;
        }
    }
}
