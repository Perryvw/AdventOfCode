using System.Numerics;

namespace AoC2023.Util;

internal static class MathUtils
{
    public static T Gcd<T>(T a, T b) where T : INumber<T>
    {
        while (b != T.Zero)
        {
            var temp = b;
            b = a % b;
            a = temp;
        }
        return a;
    }

    public static T Lcm<T>(T a, T b) where T : INumber<T>
    {
        return (a / Gcd(a, b)) * b;
    }
}
