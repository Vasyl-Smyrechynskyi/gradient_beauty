import 'package:get_it/get_it.dart';
import './services/settings_storage_service/settings_storage_service_interface.dart';
import './services/settings_storage_service/preferences_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingletonAsync<SettingsStorageService>(
      () async => PreferencesService().init());
}
