using SkredvarselGarminWeb.VarsomApi;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient();

builder.Services.AddTransient<IVarsomApi, VarsomApi>();
builder.Services.AddControllers();

var app = builder.Build();

app.MapControllers();

app.Run();
