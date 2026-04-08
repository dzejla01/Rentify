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
        var reviews = GenerateReviews(
            renters: users.Where(x => !x.IsVlasnik).ToList(),
            properties: properties
        );
        var questions = GenerateQuestions(
            renters: users.Where(x => !x.IsVlasnik).ToList(),
            properties: properties
        );
        var answers = GenerateAnswers(
            owners: users.Where(x => x.IsVlasnik).ToList(),
            questions: questions,
            properties: properties
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

        // 10 ownera
        for (int i = 0; i < 10; i++)
        {
            var firstName = FirstNames[i % FirstNames.Length];
            var lastName = LastNames[i % LastNames.Length];

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

        // 100 rentera
        int generatedRenters = 0;

        foreach (var firstName in FirstNames)
        {
            foreach (var lastName in LastNames)
            {
                if (generatedRenters >= 100)
                    return users;

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
                generatedRenters++;
            }
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

    private static List<Property> GenerateProperties(List<User> owners)
    {
        var properties = new List<Property>();
        int propertyId = 1;

        for (int ownerIndex = 0; ownerIndex < owners.Count; ownerIndex++)
        {
            var owner = owners[ownerIndex];

            for (int i = 0; i < 5; i++)
            {
                var city = Cities[(ownerIndex + i) % Cities.Length];
                var adjective = PropertyAdjectives[(propertyId + i) % PropertyAdjectives.Length];
                var type = PropertyTypes[(propertyId + ownerIndex) % PropertyTypes.Length];
                var street = StreetNames[(propertyId + i) % StreetNames.Length];

                properties.Add(new Property
                {
                    Id = propertyId,
                    UserId = owner.Id,
                    Name = $"{adjective} {type} {propertyId}",
                    City = city,
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
                    SquareMeters = (35 + (propertyId % 40)),
                    Details = $"Automatski generisana nekretnina broj {propertyId} u gradu {city}.",
                    IsAvailable = propertyId % 7 != 0,
                    IsRentingPerDay = true,
                    IsActiveOnApp = true
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

        foreach (var (year, month) in months)
        {
            // 25 rezervacija po mjesecu = 16 mjeseci * 25 = 400 rezervacija
            // 2025 favorizuje prvog ownera za report
            // 2026 favorizuje drugog ownera da statistika bude zanimljivija
            var dominantOwnerId = year == 2025
                ? ownerIds[0]
                : ownerIds.Count > 1 ? ownerIds[1] : ownerIds[0];

            for (int i = 0; i < 16; i++)
            {
                int ownerId;
                if (i < 10)
                    ownerId = dominantOwnerId;
                else
                    ownerId = ownerIds[(i + month) % ownerIds.Count];

                var ownerProperties = ownerPropertyMap[ownerId];
                var property = ownerProperties[i % ownerProperties.Count];
                var renter = renters[(reservationId + i + month) % renters.Count];

                bool isMonthly = i % 3 != 0;
                int day = Math.Min(1 + i, DateTime.DaysInMonth(year, month));

                var createdAt = new DateTime(year, month, day, 10, 0, 0, DateTimeKind.Utc);
                var startDate = createdAt.AddDays(2);

                DateTime endDate = isMonthly
                    ? startDate.AddMonths(1 + (i % 2))
                    : startDate.AddDays(3 + (i % 5));

                string status;

                if (endDate < SeminarReferenceDate)
                {
                    status = "Završeno";
                }
                else if (startDate <= SeminarReferenceDate || createdAt <= SeminarReferenceDate.AddDays(7))
                {
                    status = "Odobreno";
                }
                else
                {
                    status = "Na čekanju";
                }

                reservations.Add(new Reservation
                {
                    Id = reservationId++,
                    UserId = renter.Id,
                    PropertyId = property.Id,
                    IsMonthly = isMonthly,
                    Status = status,
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
            if (reservation.Status == "Na čekanju")
                continue;

            var property = propertyMap[reservation.PropertyId];

            if (reservation.IsMonthly)
            {
                int monthCount = GetMonthDifference(
                    reservation.StartDateOfRenting!.Value,
                    reservation.EndDateOfRenting!.Value);

                monthCount = Math.Max(1, monthCount);

                for (int m = 0; m < monthCount; m++)
                {
                    var paymentDate = reservation.StartDateOfRenting.Value.AddMonths(m);
                    bool isPaid = reservation.Status == "Završeno"
                        ? true
                        : m < monthCount - 1;

                    payments.Add(new Payment
                    {
                        Id = paymentId++,
                        ReservationId = reservation.Id,
                        Name = $"Mjesečna rata {paymentDate.Month:D2}.{paymentDate.Year}",
                        Comment = isPaid
                            ? "Automatski generisana evidentirana uplata."
                            : "Plaćanje je na čekanju.",
                        Price = property.PricePerMonth,
                        IsPayed = isPaid,
                        MonthNumber = paymentDate.Month,
                        YearNumber = paymentDate.Year,
                        DateToPay = new DateTime(paymentDate.Year, paymentDate.Month, 5, 0, 0, 0, DateTimeKind.Utc),
                        WarningDateToPay = new DateTime(paymentDate.Year, paymentDate.Month, 12, 0, 0, 0, DateTimeKind.Utc),
                        PaidAt = isPaid
                            ? new DateTime(paymentDate.Year, paymentDate.Month, 3, 0, 0, 0, DateTimeKind.Utc)
                            : null,
                        PaymentStatus = isPaid ? "Paid" : "Pending"
                    });
                }
            }
            else
            {
                int days = Math.Max(
                    1,
                    (reservation.EndDateOfRenting!.Value - reservation.StartDateOfRenting!.Value).Days);

                bool isPaid = reservation.Status == "Završeno";

                payments.Add(new Payment
                {
                    Id = paymentId++,
                    ReservationId = reservation.Id,
                    Name = $"Kratki boravak {reservation.StartDateOfRenting!.Value.Month:D2}.{reservation.StartDateOfRenting!.Value.Year}",
                    Comment = isPaid
                        ? "Automatski generisana evidentirana uplata."
                        : "Plaćanje je na čekanju.",
                    Price = property.PricePerDay * days,
                    IsPayed = isPaid,
                    MonthNumber = reservation.StartDateOfRenting.Value.Month,
                    YearNumber = reservation.StartDateOfRenting.Value.Year,
                    DateToPay = reservation.StartDateOfRenting.Value,
                    WarningDateToPay = reservation.StartDateOfRenting.Value.AddDays(2),
                    PaidAt = isPaid ? reservation.StartDateOfRenting.Value.AddDays(-1) : null,
                    PaymentStatus = isPaid ? "Paid" : "Pending"
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
            bool? approved = i % 5 == 0 ? null : (i % 2 == 0);

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
                IsApproved = approved
            });
        }

        return appointments;
    }

    private static List<Review> GenerateReviews(List<User> renters, List<Property> properties)
    {
        var reviews = new List<Review>();
        int reviewId = 1;

        for (int i = 0; i < 50; i++)
        {
            var renter = renters[i % renters.Count];
            var property = properties[(i * 3) % properties.Count];

            reviews.Add(new Review
            {
                Id = reviewId++,
                UserId = renter.Id,
                PropertyId = property.Id,
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