// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moro_shop/app/app_prefs.dart';
import 'package:moro_shop/app/constants.dart';
import 'package:moro_shop/app/di.dart';
import 'package:moro_shop/data/network/network_info.dart';
import 'package:moro_shop/presentation/common/state_renderer/state_renderer.dart';
import 'package:moro_shop/presentation/common/state_renderer/state_renderer_impl.dart';
import 'package:moro_shop/presentation/resources/assets_manager.dart';
import 'package:moro_shop/presentation/resources/routes_manager.dart';
import 'package:moro_shop/presentation/resources/strings_manager.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer? _timer;
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final NetworkInfo _networkInfo = instance<NetworkInfo>();

  @override
  void initState() {
    _startDelay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 1.0],
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: FutureBuilder(
          future: _checkInternet(),
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return _buildBody(context);
            } else if (snapshot.data == false) {
              return _buildBody(context);
            } else {
              return _buildBody(context);
            }
          },
        ),
      ),
    );
  }

  _startDelay() {
    dismissDialog(context);
    _timer = Timer(const Duration(seconds: Constants.splashDelay), _goNext);
  }

  _goNext() async {
    if (await _checkInternet()) {
      // navigate to main screen
      _appPreferences.isUserLoggedIn().then((isUserLoggedIn) {
        if (isUserLoggedIn) {
          Navigator.pushNamedAndRemoveUntil(context, Routes.mainRoute,
              ModalRoute.withName(Routes.splashRoute));
        } else {
          // navigate to login screen
          _appPreferences
              .isOnBoardingScreenViewed()
              .then((isOnBoardingScreenViewed) {
            if (isOnBoardingScreenViewed) {
              Navigator.pushNamedAndRemoveUntil(context, Routes.loginRoute,
                  ModalRoute.withName(Routes.splashRoute));
            } else {
              // navigate to onBoarding screen
              Navigator.pushNamedAndRemoveUntil(context, Routes.introRoute,
                  ModalRoute.withName(Routes.splashRoute));
            }
          });
        }
      });
    } else {
      ErrorState(StateRendererType.popupErrorState, AppStrings.noInternetError)
          .getScreenWidget(
        context,
        retryActionFunction: () {
          _startDelay();
        },
        buttonTitle: AppStrings.retryAgain,
      );
    }
  }

  Future<bool> _checkInternet() async {
    if (await _networkInfo.isConnected) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildBody(context) {
    return Center(
      child: Lottie.asset(JsonAssets.splashIcon),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
