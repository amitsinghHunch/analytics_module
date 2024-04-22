import 'package:get_it/get_it.dart';
import 'package:hunch_analyitcs/analytics.dart';

final locator = GetIt.instance;

void initLocator(
  String? firebaseToken, {
  required String email,
  required bool isDarkTheme,
  required String userUid,
  required String awsTrakingId,
  required Function(String adid) adjustAdidValue,
  required void Function(bool isCheck)
      getUnreadNotificationsCountAndChatParameters,
  required void Function(String userUid) activateEndpoint,
}) {
  locator.registerLazySingleton(
    () => AnalyticsServices(
      firebaseToken,
      email: email,
      isNightMode: isDarkTheme,
      userUid: userUid,
      awsTrakingId: awsTrakingId,
      adjustAdidValue: adjustAdidValue,
      getUnreadNotificationsCountAndChatParameters:
          getUnreadNotificationsCountAndChatParameters,
      activateEndpoint: activateEndpoint,
    ),
  );
}
