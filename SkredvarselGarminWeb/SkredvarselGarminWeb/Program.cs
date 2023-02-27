using SkredvarselGarminWeb.VarsomApi;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient();

builder.Services.AddTransient<IVarsomApi, VarsomApi>();
builder.Services.AddControllers();

var app = builder.Build();


app.UseStaticFiles();
app.UseRouting();

app.MapControllers();
app.MapFallbackToFile("index.html");

app.Run();
