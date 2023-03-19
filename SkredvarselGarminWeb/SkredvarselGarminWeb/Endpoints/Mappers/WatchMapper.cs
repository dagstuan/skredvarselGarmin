using WatchEndpointModel = SkredvarselGarminWeb.Endpoints.Models.Watch;
using WatchEntityModel = SkredvarselGarminWeb.Entities.Watch;

namespace SkredvarselGarminWeb.Endpoints.Mappers;

public static class WatchMapper
{
    public static WatchEndpointModel ToEndpointModel(this WatchEntityModel entity)
    {
        return new WatchEndpointModel
        {
            Id = entity.Id,
            Name = entity.PartNumber.ToWatchName()
        };
    }

    private static string ToWatchName(this string partNumber) => partNumber switch
    {
        "006-B3943-00" => "Epix 2",
        "006-B3110-00" => "Fēnix 5 Plus",
        "006-B2900-00" => "Fēnix 5S Plus",
        "006-B3111-00" => "Fēnix 5X Plus",
        "006-B3289-00" => "Fēnix 6",
        "006-B3287-00" => "Fēnix 6S",
        "006-B3290-00" => "Fēnix 6 Pro",
        "006-B3288-00" => "Fēnix 6S Pro",
        "006-B3291-00" => "Fēnix 6X Pro",
        "006-B3906-00" => "Fēnix 7",
        "006-B3905-00" => "Fēnix 7S",
        "006-B3907-00" => "Fēnix 7X",
        "006-B3076-00" => "Forerunner 245",
        "006-B3077-00" => "Forerunner 245 Music",
        "006-B3992-00" => "Forerunner 255",
        "006-B3990-00" => "Forerunner 255 Music",
        "006-B4257-00" => "Forerunner 265",
        "006-B2156-00" => "Forerunner 630",
        "006-B2886-00" => "Forerunner 645",
        "006-B2888-00" => "Forerunner 645 Music",
        "006-B2158-00" => "Forerunner 735XT",
        "006-B3589-00" => "Forerunner 745",
        "006-B1765-00" => "Forerunner 920XT",
        "006-B2691-00" => "Forerunner 935",
        "006-B3113-00" => "Forerunner 945",
        "006-B3652-00" => "Forerunner 945 LTE",
        "006-B4024-00" => "Forerunner 955",
        "006-B4315-00" => "Forerunner 965",
        "006-B4105-00" => "Marq 2",
        "006-B4124-00" => "Marq 2 Aviator",
        "006-B3624-00" => "Marq 2 Adventurer",
        "006-B3251-00" => "Marq 2 Athlete",
        "006-B3703-00" => "Venu 2",
        "006-B3851-00" => "Venu 2 Plus",
        "006-B2700-00" => "Vivoactive 3",
        "006-B2988-00" => "Vivoactive 3 Music",
        "006-B3225-00" => "Vivoactive 4",
        "006-B3224-00" => "Vivoactive 4S",
        _ => "Ukjent klokke"
    };
}
