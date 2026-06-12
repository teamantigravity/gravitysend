import 'package:common/isolate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gravitysend_app/ads/ad_manager.dart';
import 'package:gravitysend_app/config/init.dart';
import 'package:gravitysend_app/config/init_error.dart';
import 'package:gravitysend_app/config/theme.dart';
import 'package:gravitysend_app/gen/strings.g.dart';
import 'package:gravitysend_app/model/persistence/color_mode.dart';
import 'package:gravitysend_app/pages/home_page.dart';
import 'package:gravitysend_app/provider/local_ip_provider.dart';
import 'package:gravitysend_app/provider/settings_provider.dart';
import 'package:gravitysend_app/util/ui/dynamic_colors.dart';
import 'package:gravitysend_app/widget/watcher/life_cycle_watcher.dart';
import 'package:gravitysend_app/widget/watcher/shortcut_watcher.dart';
import 'package:gravitysend_app/widget/watcher/tray_watcher.dart';
import 'package:gravitysend_app/widget/watcher/window_watcher.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize AdMob in the background
  AdManager.init();

  // Restore ad-free status on app launch (for returning users)
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    try {
      InAppPurchase.instance.purchaseStream.listen((purchases) {
        for (final p in purchases) {
          if (p.productID == 'gravitysend_remove_ads' &&
              (p.status == PurchaseStatus.purchased ||
                  p.status == PurchaseStatus.restored)) {
            AdManager.setAdFree(true);
            InAppPurchase.instance.completePurchase(p);
          }
        }
      });
    } catch (_) {}
  }

  final RefenaContainer container;
  try {
    container = await preInit(args);
  } catch (e, stackTrace) {
    showInitErrorApp(
      error: e,
      stackTrace: stackTrace,
    );
    return;
  }

  runApp(
    RefenaScope.withContainer(
      container: container,
      child: TranslationProvider(
        child: const GravitySendApp(),
      ),
    ),
  );
}

class GravitySendApp extends StatelessWidget {
  const GravitySendApp();

  @override
  Widget build(BuildContext context) {
    final ref = context.ref;
    final (themeMode, colorMode) = ref.watch(settingsProvider.select((settings) => (settings.theme, settings.colorMode)));
    final dynamicColors = ref.watch(dynamicColorsProvider);
    return TrayWatcher(
      child: WindowWatcher(
        child: LifeCycleWatcher(
          onChangedState: (AppLifecycleState state) {
            switch (state) {
              case AppLifecycleState.resumed:
                ref.redux(localIpProvider).dispatch(InitLocalIpAction());
                break;
              case AppLifecycleState.detached:
                // The main isolate is only exited when all child isolates are exited.
                // https://github.com/gravitysend/app/issues/1568
                ref.redux(parentIsolateProvider).dispatch(IsolateDisposeAction());
                break;
              default:
                break;
            }
          },
          child: ShortcutWatcher(
            child: MaterialApp(
              title: t.appName,
              locale: TranslationProvider.of(context).flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              debugShowCheckedModeBanner: false,
              theme: getTheme(colorMode, Brightness.light, dynamicColors),
              darkTheme: getTheme(colorMode, Brightness.dark, dynamicColors),
              themeMode: colorMode == ColorMode.oled ? ThemeMode.dark : themeMode,
              navigatorKey: Routerino.navigatorKey,
              home: RouterinoHome(
                builder: () => const HomePage(
                  initialTab: HomeTab.receive,
                  appStart: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


