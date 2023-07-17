import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsup/common/repositories/user.dart';
import 'package:whatsup/common/util/logger.dart';
import 'package:whatsup/features/home/pages/home.dart';
import 'package:whatsup/features/startup/controller/startup_controller.dart';
import 'package:whatsup/features/welcome/pages/welcome.dart';

class StartUp extends ConsumerStatefulWidget {
  const StartUp({
    super.key,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StartUpState();
}

class _StartUpState extends ConsumerState<StartUp> with WidgetsBindingObserver {
  static final _logger = AppLogger.getLogger((StartUp).toString());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ref.read(startUpControllerProvider).updateOnlineState(true);
      return;
    }
    ref.read(startUpControllerProvider).updateOnlineState(false);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(userFetchProvider).when(
          data: (user) {
            return user.match(
              () {
                _logger.d("No user found, redirecting to WelcomePage");
                return const WelcomePage();
              },
              (_) {
                _logger.d("There is an active session, redirecting to HomePage");
                return const HomePage();
              },
            );
          },
          error: (err, trace) {
            return Scaffold(
              body: Text(err.toString()),
            );
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
  }
}