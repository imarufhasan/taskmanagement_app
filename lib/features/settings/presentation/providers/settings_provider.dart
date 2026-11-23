import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmanagement_app/core/constants/api_constants.dart';
import 'package:taskmanagement_app/core/storage/preferences_service.dart';
import 'package:taskmanagement_app/features/auth/presentation/providers/auth_provider.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String serverHost;

  const SettingsState({
    required this.themeMode,
    required this.serverHost,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? serverHost,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      serverHost: serverHost ?? this.serverHost,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final PreferencesService _prefs;
  final Ref _ref;

  SettingsNotifier(this._prefs, this._ref)
      : super(
          SettingsState(
            themeMode: _parseThemeMode(_prefs.getThemeMode()),
            serverHost: _prefs.getCustomServerHost() ?? '',
          ),
        ) {
    if (state.serverHost.isNotEmpty) {
      ApiConstants.customHost = state.serverHost;
      _ref.read(apiClientProvider).updateBaseUrl();
    }
  }

  static ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await _prefs.setThemeMode(modeString);
  }

  Future<void> setServerHost(String host) async {
    state = state.copyWith(serverHost: host);
    await _prefs.setCustomServerHost(host.isEmpty ? null : host);
    ApiConstants.customHost = host.isEmpty ? null : host;
    _ref.read(apiClientProvider).updateBaseUrl();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return SettingsNotifier(prefs, ref);
});
