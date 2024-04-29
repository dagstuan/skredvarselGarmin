using System.Reflection;

using Refit;

namespace SkredvarselGarminWeb.VarsomApi;

public class DateOnlyUrlParameterFormatter : DefaultUrlParameterFormatter
{
    public override string? Format(object? parameterValue, ICustomAttributeProvider attributeProvider, Type type)
    {
        if (typeof(DateOnly?).IsAssignableFrom(type) && parameterValue != null)
        {
            return ((DateOnly)parameterValue).ToString("yyyy-MM-dd");
        }

        return base.Format(parameterValue, attributeProvider, type);
    }
}
