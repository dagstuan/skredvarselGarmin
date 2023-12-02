using Microsoft.EntityFrameworkCore;
using SkredvarselGarminWeb.Database;
using SkredvarselGarminWeb.Entities;
using SkredvarselGarminWeb.Helpers;
using SkredvarselGarminWeb.ServiceModels;

namespace SkredvarselGarminWeb.Services;

public class UserService : IUserService
{
    private readonly SkredvarselDbContext _dbContext;
    private readonly IDateTimeNowProvider _dateTimeNowProvider;

    public UserService(SkredvarselDbContext dbContext, IDateTimeNowProvider dateTimeNowProvider)
    {
        _dbContext = dbContext;
        _dateTimeNowProvider = dateTimeNowProvider;
    }

    public async Task RegisterLogin(UserLogin user)
    {
        var dateNow = DateOnly.FromDateTime(_dateTimeNowProvider.Now);

        var dbUser = await _dbContext.Users.Where(u => u.Id == user.Id).FirstOrDefaultAsync();
        if (dbUser == null)
        {
            dbUser = new User
            {
                Id = user.Id,
                Name = user.Name,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                CreatedDate = dateNow,
                LastLoggedIn = dateNow
            };

            _dbContext.Users.Add(dbUser);
        }

        dbUser.Name = user.Name;
        dbUser.Email = user.Email;
        dbUser.PhoneNumber = user.PhoneNumber;
        dbUser.LastLoggedIn = dateNow;

        await _dbContext.SaveChangesAsync();
    }
}
