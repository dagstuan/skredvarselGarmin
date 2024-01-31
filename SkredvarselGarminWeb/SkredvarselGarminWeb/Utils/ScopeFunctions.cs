namespace SkredvarselGarminWeb.Utils;

public static class ScopeFunctions
{
    public static TResult Let<T, TResult>(this T self, Func<T, TResult> func) => func(self);
}
