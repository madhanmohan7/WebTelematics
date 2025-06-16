import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:obdtelematics/testCode.dart';

import 'src/utils/routes/route_names.dart';
import 'src/utils/routes/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyCustomScrollBehavior(),
          child: child!,
        );
      },

      initialRoute: RouteNames.loginPage,
      onGenerateRoute: RouteGenerator.generateRoute,
      // home: MapScreen(),
    );
  }
}


class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
