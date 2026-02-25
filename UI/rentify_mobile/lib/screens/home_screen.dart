import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentify_mobile/routes/app_routes.dart';
import 'package:rentify_mobile/screens/base_screen.dart';
import 'package:rentify_mobile/utils/session.dart';
import 'package:rentify_mobile/providers/user_provider.dart';
import 'package:rentify_mobile/providers/property_provider.dart';
import 'package:rentify_mobile/models/user.dart';
import 'package:rentify_mobile/models/property.dart';
import 'package:rentify_mobile/helper/univerzal_pagging_helper.dart';
import 'package:rentify_mobile/widgets/home_screen_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserProvider _userProvider;
  late PropertyProvider _propertyProvider;

  late UniversalPagingProvider<Property> _propertiesPaging;

  User? _user;
  bool _loadingUser = true;
  String? _userError;

  @override
  void initState() {
    super.initState();

    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    _initPaging();
    _loadUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
    _propertiesPaging.refresh();
  });
  }

  void _initPaging() {
    _propertiesPaging = UniversalPagingProvider<Property>(
      pageSize: 5,
      fetcher:
          ({
            required int page,
            required int pageSize,
            String? filter,
            Map<String, dynamic>? extra,
            bool includeTotalCount = true,
          }) async {
            final query = <String, dynamic>{
              "Page": page,
              "PageSize": pageSize,
              "IncludeTotalCount": includeTotalCount,

              if (filter != null && filter.trim().isNotEmpty)
                "Name": filter.trim(),

              if (extra?["City"] != null &&
                  extra!["City"].toString().trim().isNotEmpty)
                "City": extra["City"].toString().trim(),

              if (extra?["MinPrice"] != null)
                "MinPriceMonth": extra?["MinPrice"],
              if (extra?["MaxPrice"] != null)
                "MaxPriceMonth": extra?["MaxPrice"],
              if (extra?["MinDailyPrice"] != null)
                "MinPriceDays": extra?["MinDailyPrice"],
              if (extra?["MaxDailyPrice"] != null)
                "MaxPriceDays": extra?["MaxDailyPrice"],
            };

            return await _propertyProvider.get(filter: query);
          },
    );
  }

  Future<void> _loadUser() async {
    setState(() {
      _loadingUser = true;
      _userError = null;
    });

    try {
      final userId = Session.userId;
      if (userId == null) {
        throw Exception("Nema userId u sesiji.");
      }

      final user = await _userProvider.getById(userId);

      if (!mounted) return;

      setState(() {
        _user = user;
        _loadingUser = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _userError = e.toString();
        _loadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseMobileScreen(
      title: "Početna",
      NameAndSurname: "${_user?.firstName ?? ""} ${_user?.lastName ?? ""}"
          .trim(),
      userUsername: Session.username ?? "Nepoznato",
      onLogout: () {
        Session.odjava();
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      child: _loadingUser
          ? const Center(child: CircularProgressIndicator())
          : _userError != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _userError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadUser,
                    child: const Text("Pokušaj ponovo"),
                  ),
                ],
              ),
            )
          : BaseBody(
              paging: _propertiesPaging,
              showWelcome: true,
              fullName: "${_user?.firstName ?? ""} ${_user?.lastName ?? ""}"
                  .trim(),
              username: Session.username ?? "Nepoznato",
              sectionTitle: "Ponude po vašem ukusu",
              sectionSubtitle:
                  "Preporuke bazirane na vašim tagovima i aktivnostima.",
              showSearch: false,
              showFilter: false,
            ),
    );
  }

  @override
  void dispose() {
    _propertiesPaging.dispose();
    super.dispose();
  }
}
