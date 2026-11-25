import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../data/models/game_configuration.dart';
import '../state/audy_controller.dart';

/// Resolves a snapshot once at the route boundary, before mounting gameplay.
class StudentGameEntry extends StatefulWidget {
  const StudentGameEntry({
    super.key,
    required this.game,
    required this.builder,
  });
  final CaretakerGame game;
  final Widget Function(GameConfiguration?) builder;

  @override
  State<StudentGameEntry> createState() => _StudentGameEntryState();
}

class _StudentGameEntryState extends State<StudentGameEntry> {
  Future<GameConfiguration?>? _load;
  late int _generation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_load != null) return;
    final controller = AudyScope.of(context);
    _generation = controller.studentAccountGeneration;
    _load = controller.studentGameConfiguration(widget.game);
  }

  @override
  Widget build(BuildContext context) => StudentGameGuard(
    generation: _generation,
    child: FutureBuilder<GameConfiguration?>(
      future: _load,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
          ? widget.builder(snapshot.data)
          : Scaffold(
              appBar: AppBar(title: Text(widget.game.title)),
              body: const Center(child: CircularProgressIndicator()),
            ),
    ),
  );
}

/// Also wraps nested game routes, which are mounted above the entry route.
class StudentGameGuard extends StatelessWidget {
  const StudentGameGuard({
    super.key,
    required this.generation,
    required this.child,
  });
  final int generation;
  final Widget child;

  static Widget capture(BuildContext context, Widget child) {
    final controller = AudyScope.of(context);
    if (controller.currentUser?.role != 'child') return child;
    return StudentGameGuard(
      generation: controller.studentAccountGeneration,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    if (controller.currentUser?.role == 'child' &&
        controller.studentAccountGeneration == generation) {
      return child;
    }
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (_) => false),
          child: Text(controller.tr('back_home')),
        ),
      ),
    );
  }
}
