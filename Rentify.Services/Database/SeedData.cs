using Microsoft.EntityFrameworkCore;
using Rentify.Services.Database;
using Rentify.Services.Helpers;
using System.Text;

public static class SeedData
{
    private static readonly DateTime SeminarReferenceDate = new DateTime(2026, 5, 1, 0, 0, 0, DateTimeKind.Utc);
    private static readonly DateTime FixedCreatedAt = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc);

    private static readonly string[] FirstNames =
    {
        "Darko", "Ajla", "Amar", "Amina", "Adnan", "Aldin", "Armin", "Belma",
        "Dino", "Dzenan", "Dzejla", "Emina", "Eldar", "Faris", "Hana", "Haris",
        "Ilda", "Iman", "Jasmin", "Jelena", "Lejla", "Lamija", "Merjem", "Minela",
        "Naida", "Nejra", "Nermin", "Nidal", "Samir", "Selma", "Tarik", "Teodora",
        "Una", "Vedad", "Zehra", "Zejna", "Mahir", "Mersiha", "Adela", "Emir"
    };

    private static readonly string[] LastNames =
    {
        "Hodzic", "Delic", "Mehic", "Basic", "Kovacevic", "Kurtovic", "Begic", "Smajic",
        "Suljic", "Hasic", "Music", "Salkic", "Hadzic", "Catic", "Maric", "Jahic",
        "Mujic", "Alic", "Imsirovic", "Zukic", "Karic", "Masic", "Vranic", "Muminovic",
        "Filipovic", "Salihovic", "Pranjic", "Jukic", "Mikic", "Coric"
    };

    private static readonly string[] Cities =
    {
        "Sarajevo", "Mostar", "Tuzla", "Banja Luka", "Zenica", "Bihać"
    };

    private static readonly string[] StreetNames =
    {
        "Zmaja od Bosne", "Bistrik", "Kolodvorska", "Hamze Hume", "Skenderija",
        "Maršala Tita", "Rade Bitange", "Splitska", "Slatina", "Turalibegova",
        "Brčanska Malta", "Irac", "Kralja Petra", "Cara Dušana", "Solunska",
        "Kninska", "Logavina", "Grbavička", "Stupine", "Vase Pelagića"
    };

    private static readonly string[] PropertyAdjectives =
    {
        "Central", "Modern", "Sunny", "Quiet", "Luxury", "Elegant", "Urban", "Panorama",
        "Premium", "Comfort", "Family", "Bright", "River", "Green", "Classic", "Stylish"
    };

    private static readonly string[] PropertyTypes =
    {
        "Apartment", "Residence", "Flat", "Loft", "Studio", "Home"
    };

    private static readonly string[] ReviewComments =
    {
        "Odlična lokacija i veoma uredan prostor.",
        "Sve je bilo uredno i tačno kako je opisano.",
        "Dobra komunikacija i prijatan ambijent.",
        "Prostor je čist, komforan i dobro opremljen.",
        "Vrlo ugodno iskustvo, preporučujem.",
        "Lokacija je dobra, a stan funkcionalan.",
        "Sve korektno, bez većih zamjerki.",
        "Lijepo sređen prostor i mirno okruženje.",
        "Pristojna cijena i dobar kvalitet usluge.",
        "Vrlo pozitivno iskustvo, rado bih ponovo rezervisao."
    };

    private static readonly string[] QuestionTemplates =
    {
        "Da li su režije uključene u cijenu?",
        "Da li je dozvoljeno držanje kućnih ljubimaca?",
        "Koliki je depozit za ovu nekretninu?",
        "Da li stan ima parking mjesto?",
        "Da li je internet uključen u cijenu?",
        "Može li se nekretnina iznajmiti samo na mjesec dana?",
        "Koji je minimalan period najma?",
        "Da li nekretnina ima balkon?",
        "Koliko iznose prosječne mjesečne režije?",
        "Da li je stan odmah useljiv?"
    };

    private static readonly string[] AnswerTemplates =
    {
        "Da, dostupno je prema dogovoru sa vlasnikom.",
        "Nije uključeno i obračunava se posebno.",
        "Depozit iznosi jednu mjesečnu kiriju.",
        "Da, parking mjesto je dostupno uz nekretninu.",
        "Internet je uključen u cijenu najma.",
        "Minimalni period najma zavisi od termina i dogovora.",
        "Balkon je dostupan i uračunat u opis nekretnine.",
        "Stan je odmah useljiv nakon potvrde rezervacije.",
        "Prosječne režije zavise od sezone i potrošnje.",
        "Sve dodatne informacije možete dobiti direktno od vlasnika."
    };

    private static string PropertyImageUrl(int propertyId, int index)
        => $"https://picsum.photos/seed/property-{propertyId}-{index}/900/600";

    public static void Seed(ModelBuilder modelBuilder)
    {
        UserHelper.CreatePasswordHash(
            "Test123!",
            out var hashBase64,
            out var saltBase64
        );

        var roles = GenerateRoles();
        var users = GenerateUsers(hashBase64, saltBase64);
        var userRoles = GenerateUserRoles(users);
        var properties = GenerateProperties(users.Where(x => x.IsVlasnik).ToList());
        var propertyImages = GeneratePropertyImages(properties);
        var reservations = GenerateReservations(
            renters: users.Where(x => !x.IsVlasnik).ToList(),
            properties: properties
        );
        var payments = GeneratePayments(reservations, properties);
        var appointments = GenerateAppointments(
            renters: users.Where(x => !x.IsVlasnik).ToList(),
            properties: properties
        );
        var reviews = GenerateReviews(reservations);
        
        var questions = GenerateQuestions(
            renters: users.Where(x => !x.IsVlasnik).ToList(),
            properties: properties
        );
        var answers = GenerateAnswers(
            owners: users.Where(x => x.IsVlasnik).ToList(),
            questions: questions,
            properties: properties
        );

        modelBuilder.Entity<City>().HasData(
            new City { Id = 1, Name = "Sarajevo" },
            new City { Id = 2, Name = "Mostar" },
            new City { Id = 3, Name = "Tuzla" },
            new City { Id = 4, Name = "Banja Luka" },
            new City { Id = 5, Name = "Zenica" },
            new City { Id = 6, Name = "Bihać" }
        );

        modelBuilder.Entity<Status>().HasData(
            new Status { Id = 1, Name = "Na čekanju" },
            new Status { Id = 2, Name = "Odobreno" },
            new Status { Id = 3, Name = "Završeno" },
            new Status { Id = 4, Name = "Odbijeno" },
            new Status { Id = 5, Name = "Otkazano" },
            new Status { Id = 6, Name = "Procesiranje" },
            new Status { Id = 7, Name = "Plaćeno" },
            new Status { Id = 8, Name = "Neplaćeno" },
            new Status { Id = 9, Name = "Neuspješno" }
        );

        modelBuilder.Entity<BuildingType>().HasData(
            new BuildingType { Id = 1, Name = "Apartman" },
            new BuildingType { Id = 2, Name = "Kuća" },
            new BuildingType { Id = 3, Name = "Studio" },
            new BuildingType { Id = 4, Name = "Loft" },
            new BuildingType { Id = 5, Name = "Vila" },
            new BuildingType { Id = 6, Name = "Poslovni prostor" }
        );

        modelBuilder.Entity<Role>().HasData(roles);
        modelBuilder.Entity<User>().HasData(users);
        modelBuilder.Entity<UserRole>().HasData(userRoles);
        modelBuilder.Entity<Property>().HasData(properties);
        modelBuilder.Entity<PropertyImage>().HasData(propertyImages);
        modelBuilder.Entity<Reservation>().HasData(reservations);
        modelBuilder.Entity<Payment>().HasData(payments);
        modelBuilder.Entity<Appointment>().HasData(appointments);
        modelBuilder.Entity<Review>().HasData(reviews);
        modelBuilder.Entity<Question>().HasData(questions);
        modelBuilder.Entity<Answer>().HasData(answers);
    }

    private static List<Role> GenerateRoles()
    {
        return new List<Role>
        {
            new Role
            {
                Id = 1,
                Name = "Korisnik",
                Description = "Standardni korisnik aplikacije",
                IsActive = true,
                CreatedAt = FixedCreatedAt
            },
            new Role
            {
                Id = 2,
                Name = "Vlasnik",
                Description = "Vlasnik nekretnina",
                IsActive = true,
                CreatedAt = FixedCreatedAt
            }
        };
    }

    private static List<User> GenerateUsers(string hashBase64, string saltBase64)
    {
        var users = new List<User>();
        var usedUsernames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var usedEmails = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        int nextId = 1;
        int usernameCounter = 10;

        users.Add(new User
        {
            Id = nextId++,
            FirstName = "Darko",
            LastName = "Hodzic",
            Email = "owner.testni@gmail.com",
            Username = "owner1",
            PasswordHash = hashBase64,
            PasswordSalt = saltBase64,
            IsVlasnik = true,
            IsActive = true,
            IsLoggingFirstTime = false
        });

        usedUsernames.Add("owner1");
        usedEmails.Add("owner.testni@gmail.com");

        users.Add(new User
        {
            Id = nextId++,
            FirstName = "Ajla",
            LastName = "Delic",
            Email = "usertestni089@gmail.com",
            Username = "user1",
            PasswordHash = hashBase64,
            PasswordSalt = saltBase64,
            IsVlasnik = false,
            IsActive = true,
            IsLoggingFirstTime = false
        });

        usedUsernames.Add("user1");
        usedEmails.Add("usertestni089@gmail.com");

        for (int i = 0; i < 9; i++) 
        {
            var firstName = FirstNames[(i + 2) % FirstNames.Length];
            var lastName = LastNames[(i * 3 + 2) % LastNames.Length];

            var username = BuildUniqueUsername(firstName, lastName, usernameCounter, usedUsernames);
            var email = BuildUniqueEmail(firstName, lastName, usernameCounter, usedEmails);

            users.Add(new User
            {
                Id = nextId++,
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Username = username,
                PasswordHash = hashBase64,
                PasswordSalt = saltBase64,
                IsVlasnik = true,
                IsActive = true,
                IsLoggingFirstTime = false
            });

            usernameCounter++;
        }

        for (int i = 0; i < 100; i++)
        {
            var firstName = FirstNames[(i + 5) % FirstNames.Length];
            var lastName = LastNames[(i * 7 + 5) % LastNames.Length];

            var username = BuildUniqueUsername(firstName, lastName, usernameCounter, usedUsernames);
            var email = BuildUniqueEmail(firstName, lastName, usernameCounter, usedEmails);

            users.Add(new User
            {
                Id = nextId++,
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Username = username,
                PasswordHash = hashBase64,
                PasswordSalt = saltBase64,
                IsVlasnik = false,
                IsActive = true,
                IsLoggingFirstTime = false
            });

            usernameCounter++;
        }

        return users;
    }

    private static List<UserRole> GenerateUserRoles(List<User> users)
    {
        return users
            .Select(u => new UserRole
            {
                UserId = u.Id,
                RoleId = u.IsVlasnik ? 2 : 1
            })
            .ToList();
    }

    private static readonly (double Lat, double Lng)[] CityCoordinates =
    {
        (43.8563, 18.4131), // 1 Sarajevo
        (43.3438, 17.8078), // 2 Mostar
        (44.5382, 18.6735), // 3 Tuzla
        (44.7722, 17.1910), // 4 Banja Luka
        (44.2035, 17.9078), // 5 Zenica
        (44.8167, 15.8667), // 6 Bihać
    };

    private static List<Property> GenerateProperties(List<User> owners)
    {
        var properties = new List<Property>();
        int propertyId = 1;

        for (int ownerIndex = 0; ownerIndex < owners.Count; ownerIndex++)
        {
            var owner = owners[ownerIndex];

            int propertyCount = owner.Username == "owner1" ? 10 : 4;

            for (int i = 0; i < propertyCount; i++)
            {
                var cityIndex = (ownerIndex + i) % Cities.Length;
                var city = Cities[cityIndex];
                var cityId = cityIndex + 1;
                var buildingTypeId = (propertyId + ownerIndex) % 6 + 1;
                var adjective = PropertyAdjectives[(propertyId + i) % PropertyAdjectives.Length];
                var street = StreetNames[(propertyId + i) % StreetNames.Length];

                var (baseLat, baseLng) = CityCoordinates[cityIndex];
                var offsetLat = ((propertyId * 7 + i * 3) % 21 - 10) * 0.0010;
                var offsetLng = ((propertyId * 11 + i * 5) % 21 - 10) * 0.0010;

                properties.Add(new Property
                {
                    Id = propertyId,
                    UserId = owner.Id,
                    Name = $"{adjective} {propertyId}",
                    CityId = cityId,
                    BuildingTypeId = buildingTypeId,
                    Location = $"{street} {10 + propertyId}",
                    PricePerDay = 45 + ((propertyId * 3) % 45),
                    PricePerMonth = 950 + ((propertyId * 80) % 1200),
                    Tags = new List<string>
                {
                    city.ToLowerInvariant(),
                    adjective.ToLowerInvariant(),
                    "modern",
                    "comfortable"
                },
                    SquareMeters = 35 + (propertyId % 40),
                    Details = $"Automatski generisana nekretnina broj {propertyId} u gradu {city}.",
                    IsRentingPerDay = true,
                    IsActiveOnApp = true,
                    Latitude = Math.Round(baseLat + offsetLat, 6),
                    Longitude = Math.Round(baseLng + offsetLng, 6)
                });

                propertyId++;
            }
        }

        return properties;
    }

    private static List<PropertyImage> GeneratePropertyImages(List<Property> properties)
    {
        var images = new List<PropertyImage>();
        int imageId = 1;

        foreach (var property in properties)
        {
            for (int i = 1; i <= 4; i++)
            {
                images.Add(new PropertyImage
                {
                    Id = imageId++,
                    PropertyId = property.Id,
                    PropertyImg = PropertyImageUrl(property.Id, i),
                    IsMain = i == 1
                });
            }
        }

        return images;
    }

    private static List<Reservation> GenerateReservations(List<User> renters, List<Property> properties)
    {
        var reservations = new List<Reservation>();
        int reservationId = 1;

        var months = new List<(int Year, int Month)>();
        for (int month = 1; month <= 12; month++)
            months.Add((2025, month));
        for (int month = 1; month <= 4; month++)
            months.Add((2026, month));

        var ownerPropertyMap = properties
            .GroupBy(p => p.UserId)
            .ToDictionary(g => g.Key, g => g.OrderBy(x => x.Id).ToList());

        var ownerIds = ownerPropertyMap.Keys.OrderBy(x => x).ToList();

        var demoRenter = renters.FirstOrDefault(x => x.Username == "user1") ?? renters.First();

        var otherRenters = renters
            .Where(x => x.Id != demoRenter.Id)
            .OrderBy(x => x.Id)
            .ToList();

        var demoOwnerProperties = properties
            .Where(x => x.UserId == 1) 
            .OrderBy(x => x.Id)
            .ToList();

        if (demoOwnerProperties.Count < 10)
        {
            demoOwnerProperties = properties.OrderBy(x => x.Id).Take(10).ToList();
        }

        var nonOwner1Properties = properties
            .Where(x => x.UserId != 1)
            .OrderBy(x => x.Id)
            .ToList();

        if (nonOwner1Properties.Count < 8)
        {
            nonOwner1Properties = properties
                .OrderBy(x => x.Id)
                .Skip(2)
                .Take(8)
                .ToList();
        }

        
        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[0].Id,
            PropertyId = demoOwnerProperties[0].Id,
            IsMonthly = true,
            StatusId = 3,
            CreatedAt = new DateTime(2025, 12, 20, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 1, 1, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 3, 1, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[1].Id,
            PropertyId = demoOwnerProperties[1].Id,
            IsMonthly = false,
            StatusId = 3,
            CreatedAt = new DateTime(2026, 1, 8, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 1, 12, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 1, 18, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[2].Id,
            PropertyId = demoOwnerProperties[2].Id,
            IsMonthly = true,
            StatusId = 3,
            CreatedAt = new DateTime(2026, 1, 28, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 2, 1, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 4, 1, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[3].Id,
            PropertyId = demoOwnerProperties[3].Id,
            IsMonthly = false,
            StatusId = 3,
            CreatedAt = new DateTime(2026, 2, 4, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 2, 7, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 2, 13, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[4].Id,
            PropertyId = demoOwnerProperties[4].Id,
            IsMonthly = true,
            StatusId = 3,
            CreatedAt = new DateTime(2026, 2, 24, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 3, 1, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 5, 1, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[5].Id,
            PropertyId = demoOwnerProperties[5].Id,
            IsMonthly = false,
            StatusId = 3,
            CreatedAt = new DateTime(2026, 3, 5, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 3, 9, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 3, 15, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[6].Id,
            PropertyId = demoOwnerProperties[6].Id,
            IsMonthly = true,
            StatusId = 3,
            CreatedAt = new DateTime(2026, 3, 25, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 4, 1, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 5, 1, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[7].Id,
            PropertyId = demoOwnerProperties[7].Id,
            IsMonthly = false,
            StatusId = 3,
            CreatedAt = new DateTime(2026, 4, 3, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 4, 8, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 4, 14, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[8].Id,
            PropertyId = demoOwnerProperties[8].Id,
            IsMonthly = true,
            StatusId = 2,
            CreatedAt = new DateTime(2026, 4, 10, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 4, 15, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 6, 15, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[9].Id,
            PropertyId = demoOwnerProperties[9].Id,
            IsMonthly = false,
            StatusId = 1,
            CreatedAt = new DateTime(2026, 4, 22, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 5, 12, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 5, 17, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[10].Id,
            PropertyId = demoOwnerProperties[0].Id,
            IsMonthly = false,
            StatusId = 4,
            CreatedAt = new DateTime(2026, 4, 11, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 4, 20, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 4, 25, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = otherRenters[11].Id,
            PropertyId = demoOwnerProperties[1].Id,
            IsMonthly = true,
            StatusId = 5,
            CreatedAt = new DateTime(2026, 3, 18, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 4, 1, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 5, 1, 10, 0, 0, DateTimeKind.Utc)
        });

        

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = demoRenter.Id,
            PropertyId = nonOwner1Properties[0].Id,
            IsMonthly = false,
            StatusId = 3,
            CreatedAt = new DateTime(2025, 11, 10, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2025, 11, 15, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2025, 11, 20, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = demoRenter.Id,
            PropertyId = nonOwner1Properties[1].Id,
            IsMonthly = true,
            StatusId = 3,
            CreatedAt = new DateTime(2026, 1, 14, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 1, 20, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 3, 20, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = demoRenter.Id,
            PropertyId = nonOwner1Properties[2].Id,
            IsMonthly = false,
            StatusId = 2,
            CreatedAt = new DateTime(2026, 4, 9, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 4, 25, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 4, 30, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = demoRenter.Id,
            PropertyId = nonOwner1Properties[3].Id,
            IsMonthly = false,
            StatusId = 1,
            CreatedAt = new DateTime(2026, 4, 24, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 5, 18, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 5, 23, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = demoRenter.Id,
            PropertyId = nonOwner1Properties[4].Id,
            IsMonthly = true,
            StatusId = 5,
            CreatedAt = new DateTime(2026, 3, 10, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 4, 1, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 5, 1, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = demoRenter.Id,
            PropertyId = nonOwner1Properties[5].Id,
            IsMonthly = false,
            StatusId = 4,
            CreatedAt = new DateTime(2026, 4, 5, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 4, 21, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 4, 26, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = demoRenter.Id,
            PropertyId = nonOwner1Properties[6].Id,
            IsMonthly = false,
            StatusId = 3,
            CreatedAt = new DateTime(2026, 2, 14, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 2, 18, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 2, 24, 10, 0, 0, DateTimeKind.Utc)
        });

        reservations.Add(new Reservation
        {
            Id = reservationId++,
            UserId = demoRenter.Id,
            PropertyId = nonOwner1Properties[7].Id,
            IsMonthly = true,
            StatusId = 3,
            CreatedAt = new DateTime(2026, 3, 1, 10, 0, 0, DateTimeKind.Utc),
            StartDateOfRenting = new DateTime(2026, 3, 5, 10, 0, 0, DateTimeKind.Utc),
            EndDateOfRenting = new DateTime(2026, 4, 5, 10, 0, 0, DateTimeKind.Utc)
        });

       
        for (int monthIndex = 0; monthIndex < months.Count; monthIndex++)
        {
            var (year, month) = months[monthIndex];

            int reservationsThisMonth = monthIndex < 8 ? 13 : 12;

           
            var dominantOwnerId = year == 2025
                ? ownerIds[0]
                : ownerIds.Count > 1 ? ownerIds[1] : ownerIds[0];

            for (int i = 0; i < reservationsThisMonth; i++)
            {
                int ownerId;
                if (i < Math.Ceiling(reservationsThisMonth * 0.6))
                    ownerId = dominantOwnerId;
                else
                    ownerId = ownerIds[(monthIndex + i) % ownerIds.Count];

                var ownerProperties = ownerPropertyMap[ownerId];
                var property = ownerProperties[(i + monthIndex) % ownerProperties.Count];
                var renter = renters[(reservationId * 3 + i + monthIndex) % renters.Count];

                bool isMonthly = i % 3 != 0;

                int day = Math.Min(2 + (i * 2), DateTime.DaysInMonth(year, month));
                var createdAt = new DateTime(year, month, day, 10, 0, 0, DateTimeKind.Utc);
                var startDate = createdAt.AddDays(2);

                DateTime endDate = isMonthly
                    ? startDate.AddMonths(1 + (i % 2))
                    : startDate.AddDays(3 + (i % 5));

                int statusId;

                bool isCancelled = reservationId % 11 == 0;
                bool isRejected = reservationId % 13 == 0;

                if (isCancelled)
                {
                    statusId = 5;
                }
                else if (isRejected)
                {
                    statusId = 4;
                }
                else if (endDate < SeminarReferenceDate)
                {
                    statusId = 3;
                }
                else if (startDate <= SeminarReferenceDate || createdAt <= SeminarReferenceDate.AddDays(7))
                {
                    statusId = 2;
                }
                else
                {
                    statusId = 1;
                }

                reservations.Add(new Reservation
                {
                    Id = reservationId++,
                    UserId = renter.Id,
                    PropertyId = property.Id,
                    IsMonthly = isMonthly,
                    StatusId = statusId,
                    CreatedAt = createdAt,
                    StartDateOfRenting = startDate,
                    EndDateOfRenting = endDate
                });
            }
        }

        return reservations;
    }

    private static List<Payment> GeneratePayments(List<Reservation> reservations, List<Property> properties)
    {
        var payments = new List<Payment>();
        int paymentId = 1;

        var propertyMap = properties.ToDictionary(x => x.Id, x => x);

        foreach (var reservation in reservations)
        {
            if (reservation.StatusId == 1)
                continue;

            if (!propertyMap.TryGetValue(reservation.PropertyId, out var property))
                continue;

            if (reservation.StartDateOfRenting == null || reservation.EndDateOfRenting == null)
                continue;

       
            bool shouldSeedFinishedButUnpaid =
                reservation.StatusId == 3 &&
                reservation.Id % 7 == 0;

            if (reservation.IsMonthly)
            {
                int monthCount = GetMonthDifference(
                    reservation.StartDateOfRenting.Value,
                    reservation.EndDateOfRenting.Value
                );

                monthCount = Math.Max(1, monthCount);

                for (int m = 0; m < monthCount; m++)
                {
                    var paymentDate = reservation.StartDateOfRenting.Value.AddMonths(m);

                    int paymentStatusId;
                    DateTime? paidAt = null;
                    string comment;

                    bool isLastInstallment = m == monthCount - 1;

                    if (!isLastInstallment)
                    {
   
                        paymentStatusId = 7;
                        paidAt = new DateTime(
                            paymentDate.Year,
                            paymentDate.Month,
                            3,
                            0,
                            0,
                            0,
                            DateTimeKind.Utc
                        );
                        comment = "Automatski generisana evidentirana uplata.";
                    }
                    else
                    {
                        if (reservation.StatusId == 3)
                        {
                            if (shouldSeedFinishedButUnpaid)
                            {
                                paymentStatusId = 8;
                                paidAt = null;
                                comment = "Automatski generisan testni slučaj neplaćene završene rate.";
                            }
                            else
                            {
                                paymentStatusId = 7;
                                paidAt = new DateTime(
                                    paymentDate.Year,
                                    paymentDate.Month,
                                    3,
                                    0,
                                    0,
                                    0,
                                    DateTimeKind.Utc
                                );
                                comment = "Automatski generisana evidentirana uplata.";
                            }
                        }
                        else
                        {
                            paymentStatusId = 1;
                            comment = "Plaćanje je na čekanju.";
                        }
                    }

                    payments.Add(new Payment
                    {
                        Id = paymentId++,
                        ReservationId = reservation.Id,
                        Name = $"Mjesečna rata {paymentDate.Month:D2}.{paymentDate.Year}",
                        Comment = comment,
                        Price = property.PricePerMonth,
                        MonthNumber = paymentDate.Month,
                        YearNumber = paymentDate.Year,
                        DateToPay = new DateTime(
                            paymentDate.Year,
                            paymentDate.Month,
                            5,
                            0,
                            0,
                            0,
                            DateTimeKind.Utc
                        ),
                        WarningDateToPay = new DateTime(
                            paymentDate.Year,
                            paymentDate.Month,
                            12,
                            0,
                            0,
                            0,
                            DateTimeKind.Utc
                        ),
                        SecondWarningDate = new DateTime(
                            paymentDate.Year,
                            paymentDate.Month,
                            17,
                            0,
                            0,
                            0,
                            DateTimeKind.Utc
                        ),
                        PaidAt = paidAt,
                        StatusId = paymentStatusId
                    });
                }
            }
            else
            {
                int days = Math.Max(
                    1,
                    (reservation.EndDateOfRenting.Value - reservation.StartDateOfRenting.Value).Days
                );

                int paymentStatusId;
                DateTime? paidAt = null;
                string comment;

                if (reservation.StatusId == 3)
                {
                    if (shouldSeedFinishedButUnpaid)
                    {
                        paymentStatusId = 8;
                        paidAt = null;
                        comment = "Automatski generisan testni slučaj neplaćenog završenog kratkog boravka.";
                    }
                    else
                    {
                        paymentStatusId = 7;
                        paidAt = reservation.StartDateOfRenting.Value.AddDays(-1);
                        comment = "Automatski generisana evidentirana uplata.";
                    }
                }
                else
                {
                    paymentStatusId = 1;
                    comment = "Plaćanje je na čekanju.";
                }

                payments.Add(new Payment
                {
                    Id = paymentId++,
                    ReservationId = reservation.Id,
                    Name = $"Kratki boravak {reservation.StartDateOfRenting.Value.Month:D2}.{reservation.StartDateOfRenting.Value.Year}",
                    Comment = comment,
                    Price = property.PricePerDay * days,
                    MonthNumber = reservation.StartDateOfRenting.Value.Month,
                    YearNumber = reservation.StartDateOfRenting.Value.Year,
                    DateToPay = reservation.StartDateOfRenting.Value,
                    WarningDateToPay = reservation.StartDateOfRenting.Value.AddDays(2),
                    SecondWarningDate = reservation.StartDateOfRenting.Value.AddDays(5),
                    PaidAt = paidAt,
                    StatusId = paymentStatusId
                });
            }
        }

        return payments;
    }

    private static List<Appointment> GenerateAppointments(List<User> renters, List<Property> properties)
    {
        var appointments = new List<Appointment>();
        int appointmentId = 1;

        for (int i = 0; i < 80; i++)
        {
            var renter = renters[i % renters.Count];
            var property = properties[(i * 2) % properties.Count];

            int statusId;

            if (i % 7 == 0)
                statusId = 1;
            else if (i % 5 == 0)
                statusId = 4;
            else if (i % 3 == 0)
                statusId = 5;
            else if (i % 2 == 0)
                statusId = 3;
            else
                statusId = 2;

            appointments.Add(new Appointment
            {
                Id = appointmentId++,
                UserId = renter.Id,
                PropertyId = property.Id,
                DateAppointment = new DateTime(
                    2026,
                    ((i % 4) + 1),
                    Math.Min(3 + i, 28),
                    9 + (i % 8),
                    0,
                    0,
                    DateTimeKind.Utc
                ),
                StatusId = statusId
            });
        }

        return appointments;
    }

    private static List<Review> GenerateReviews(List<Reservation> reservations)
    {
        var reviews = new List<Review>();
        int reviewId = 1;

        var eligibleReservations = reservations
            .Where(r => r.StatusId == 3)
            .OrderBy(r => r.Id)
            .Take(50)
            .ToList();

        for (int i = 0; i < eligibleReservations.Count; i++)
        {
            var reservation = eligibleReservations[i];

            reviews.Add(new Review
            {
                Id = reviewId++,
                ReservationId = reservation.Id,
                StarRate = 3 + (i % 3),
                Comment = ReviewComments[i % ReviewComments.Length]
            });
        }

        return reviews;
    }

    private static List<Question> GenerateQuestions(List<User> renters, List<Property> properties)
    {
        var questions = new List<Question>();
        int questionId = 1;

        for (int i = 0; i < 140; i++)
        {
            var renter = renters[i % renters.Count];
            var property = properties[(i * 5) % properties.Count];
            bool answered = i % 2 == 0;

            questions.Add(new Question
            {
                Id = questionId++,
                UserId = renter.Id,
                PropertyId = property.Id,
                Content = QuestionTemplates[i % QuestionTemplates.Length],
                CreatedAt = new DateTime(
                    2026,
                    ((i % 4) + 1),
                    Math.Min(1 + i, 28),
                    10 + (i % 6),
                    15,
                    0,
                    DateTimeKind.Utc
                ),
                IsAnswered = answered
            });
        }

        return questions;
    }

    private static List<Answer> GenerateAnswers(List<User> owners, List<Question> questions, List<Property> properties)
    {
        var answers = new List<Answer>();
        int answerId = 1;

        var propertyOwnerMap = properties.ToDictionary(x => x.Id, x => x.UserId);
        var ownerMap = owners.ToDictionary(x => x.Id, x => x);

        foreach (var question in questions.Where(q => q.IsAnswered))
        {
            var ownerId = propertyOwnerMap[question.PropertyId];

            if (!ownerMap.ContainsKey(ownerId))
                ownerId = owners.First().Id;

            answers.Add(new Answer
            {
                Id = answerId++,
                QuestionId = question.Id,
                UserId = ownerId,
                Content = AnswerTemplates[(question.Id - 1) % AnswerTemplates.Length],
                CreatedAt = question.CreatedAt.AddHours(2)
            });
        }

        return answers;
    }

    private static string NormalizeForUsername(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return "usr";

        value = value.ToLowerInvariant()
            .Replace("š", "s")
            .Replace("đ", "dj")
            .Replace("ž", "z")
            .Replace("č", "c")
            .Replace("ć", "c");

        var sb = new StringBuilder();

        foreach (var ch in value)
        {
            if (char.IsLetterOrDigit(ch))
                sb.Append(ch);
        }

        return sb.Length == 0 ? "usr" : sb.ToString();
    }

    private static string BuildUniqueUsername(
        string firstName,
        string lastName,
        int numericSuffix,
        HashSet<string> usedUsernames)
    {
        var first = NormalizeForUsername(firstName);
        var last = NormalizeForUsername(lastName);

        var left = first.Length >= 3 ? first.Substring(0, 3) : first.PadRight(3, 'x');
        var right = last.Length >= 3 ? last.Substring(0, 3) : last.PadRight(3, 'x');

        var username = $"{left}{right}{numericSuffix}";

        while (!usedUsernames.Add(username))
        {
            numericSuffix++;
            username = $"{left}{right}{numericSuffix}";
        }

        return username;
    }

    private static string BuildUniqueEmail(
        string firstName,
        string lastName,
        int numericSuffix,
        HashSet<string> usedEmails)
    {
        var first = NormalizeForUsername(firstName);
        var last = NormalizeForUsername(lastName);

        var email = $"{first}.{last}{numericSuffix}@rentify.dev";

        while (!usedEmails.Add(email))
        {
            numericSuffix++;
            email = $"{first}.{last}{numericSuffix}@rentify.dev";
        }

        return email;
    }

    private static int GetMonthDifference(DateTime start, DateTime end)
    {
        return ((end.Year - start.Year) * 12) + end.Month - start.Month;
    }
}