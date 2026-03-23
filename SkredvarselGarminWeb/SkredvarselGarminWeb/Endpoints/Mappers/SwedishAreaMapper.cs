using System.Text.Json;

using SkredvarselGarminWeb.Endpoints.Models;
using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.Endpoints.Mappers;

public static class SwedishAreaMapper
{
    public static SwedishAreaSummary ToSwedishAreaSummary(this WfsFeature<JsonElement> area)
    {
        var properties = area.Properties;

        return new SwedishAreaSummary
        {
            Id = properties.GetProperty("id").GetInt32(),
            Name = properties.GetProperty("label").GetString() ?? string.Empty,
            ParentId = properties.TryGetProperty("parent_id", out var parentId) && parentId.ValueKind != JsonValueKind.Null
                ? parentId.GetInt32()
                : null,
        };
    }
}
