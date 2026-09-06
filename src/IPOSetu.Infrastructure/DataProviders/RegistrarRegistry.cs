namespace IPOSetu.Infrastructure.DataProviders;

public static class RegistrarRegistry
{
    private static readonly Dictionary<string, string> OfficialUrls = new(StringComparer.OrdinalIgnoreCase)
    {
        { "Link Intime", "https://linkintime.co.in/initial_offer/public-issues.html" },
        { "Link Intime India Private Ltd", "https://linkintime.co.in/initial_offer/public-issues.html" },
        { "Link Intime India", "https://linkintime.co.in/initial_offer/public-issues.html" },
        { "KFin Technologies", "https://ris.kfintech.com/ipostatus/" },
        { "KFin Technologies Limited", "https://ris.kfintech.com/ipostatus/" },
        { "KFin Technologies Private Limited", "https://ris.kfintech.com/ipostatus/" },
        { "KFintech", "https://ris.kfintech.com/ipostatus/" },
        { "Bigshare Services", "https://ipo.bigshareonline.com/" },
        { "Bigshare Services Pvt Ltd", "https://ipo.bigshareonline.com/" },
        { "Skyline Financial Services", "https://www.skylinerta.com/ipo.php" },
        { "Skyline Financial Services Private Ltd", "https://www.skylinerta.com/ipo.php" },
        { "Purva Sharegistry", "https://www.purvashare.com/investor-service/ipo-query" },
        { "Purva Sharegistry India Pvt Ltd", "https://www.purvashare.com/investor-service/ipo-query" },
        { "Cameo Corporate Services", "https://ipo.cameoindia.com/" },
        { "Cameo Corporate Services Limited", "https://ipo.cameoindia.com/" },
        { "Beetal Financial & Computer Services", "http://www.beetalfinancial.com/" },
        { "Maashitla Securities", "https://maashitla.com/allotment-status/public-issues" },
        { "Maashitla Securities Private Limited", "https://maashitla.com/allotment-status/public-issues" },
        { "Integrated Registry Management Services", "https://www.integratedindia.in/" },
        { "MUDS Management", "https://muds.co.in/" }
    };

    public static string? GetOfficialStatusUrl(string? registrarName)
    {
        if (string.IsNullOrWhiteSpace(registrarName)) return null;

        var clean = registrarName.Trim();
        foreach (var kvp in OfficialUrls)
        {
            if (clean.Contains(kvp.Key, StringComparison.OrdinalIgnoreCase) ||
                kvp.Key.Contains(clean, StringComparison.OrdinalIgnoreCase))
            {
                return kvp.Value;
            }
        }

        return null;
    }
}
