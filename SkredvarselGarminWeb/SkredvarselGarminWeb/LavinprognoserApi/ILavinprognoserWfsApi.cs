using Refit;

using SkredvarselGarminWeb.LavinprognoserApi.Models;

namespace SkredvarselGarminWeb.LavinprognoserApi;

public interface ILavinprognoserWfsApi
{
    [Get("/ows")]
    Task<ApiResponse<WfsFeatureCollection<System.Text.Json.JsonElement>>> GetAllLocationPolygons(
        [AliasAs("service")] string service,
        [AliasAs("version")] string version,
        [AliasAs("request")] string request,
        [AliasAs("typeName")] string typeName,
        [AliasAs("outputFormat")] string outputFormat,
        [AliasAs("CQL_FILTER")] string? cqlFilter = null);

    [Get("/ows")]
    Task<ApiResponse<WfsFeatureCollection<LavinprognoserLocation>>> GetLocationPolygons(
        [AliasAs("service")] string service,
        [AliasAs("version")] string version,
        [AliasAs("request")] string request,
        [AliasAs("typeName")] string typeName,
        [AliasAs("outputFormat")] string outputFormat,
        [AliasAs("CQL_FILTER")] string? cqlFilter = null);
}
