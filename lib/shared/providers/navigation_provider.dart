import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(NavigationNotifier.new);

class NavigationState {
  final int index;
  final List<GlobalKey<NavigatorState>> navigationKeys;
  final NavigatorState? navigatorState;
  final String? routeName;

  NavigationState({required this.index, required this.navigationKeys, this.routeName, this.navigatorState});

  NavigationState copyWith({
    int? index,
    List<GlobalKey<NavigatorState>>? navigationKeys,
    String? routeName,
    NavigatorState? navigatorState,
  }) {
    return NavigationState(
      index: index ?? this.index,
      routeName: routeName ?? this.routeName,
      navigatorState: navigatorState ?? this.navigatorState,
      navigationKeys: navigationKeys ?? this.navigationKeys,
    );
  }
}

class NavigationNotifier extends Notifier<NavigationState> {
  final List<GlobalKey<NavigatorState>> navigationKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  NavigationState build() {
    state = NavigationState(index: 0, navigationKeys: navigationKeys, navigatorState: navigationKeys[0].currentState);
    selectTab(0);
    return state;
  }

  void selectTab(int index, {String? routeName, bool? removeAllRoutes = false}) {
    if (index < 0 || index >= navigationKeys.length) return;

    state = state.copyWith(index: index, routeName: routeName, navigatorState: navigationKeys[index].currentState);

    if (routeName != null && state.navigatorState != null) {
      state.navigatorState!.pushNamedAndRemoveUntil(routeName, (route) => route.isFirst);
    }
  }
}
