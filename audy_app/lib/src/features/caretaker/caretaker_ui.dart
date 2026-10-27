import 'package:flutter/material.dart';
import '../../state/audy_controller.dart';
import '../../core/audy_ui.dart';
import '../../services/auth_service.dart';

class CaretakerAccountGuard extends StatefulWidget {
  const CaretakerAccountGuard({super.key, required this.child});
  final Widget child;
  @override
  State<CaretakerAccountGuard> createState() => _CaretakerAccountGuardState();
}

class _CaretakerAccountGuardState extends State<CaretakerAccountGuard> {
  String? _accountId;
  bool _captured = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_captured) {
      _accountId = AudyScope.of(context).currentUser?.id;
      _captured = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AudyScope.of(context).currentUser;
    if (user?.mode != AppMode.caretaker || user?.id != _accountId) {
      return Scaffold(
        body: Center(
          child: Text(
            ct(
              context,
              'This Caretaker session has ended.',
              'สิ้นสุดเซสชันผู้ดูแลแล้ว',
            ),
          ),
        ),
      );
    }
    return AudyControls(child: widget.child);
  }
}

String ct(BuildContext context, String english, String thai) =>
    AudyScope.of(context).currentLanguage == 'th' ? thai : english;

class CaretakerNotice extends StatelessWidget {
  const CaretakerNotice(this.message, {super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message),
        if (onRetry != null)
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(ct(context, 'Retry', 'ลองอีกครั้ง')),
          ),
      ],
    ),
  );
}

class CaretakerPageBody extends StatelessWidget {
  const CaretakerPageBody({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => AudyResponsivePage(
    builder: (context, adaptive) => AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );
}

Future<bool> confirmLeave(
  BuildContext context,
  Future<bool> Function() save,
) async {
  final answer = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        ct(context, 'Unsaved changes', 'มีการเปลี่ยนแปลงที่ยังไม่บันทึก'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'stay'),
          child: Text(ct(context, 'Stay', 'อยู่หน้านี้')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'discard'),
          child: Text(ct(context, 'Discard', 'ละทิ้ง')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, 'save'),
          child: Text(ct(context, 'Save and continue', 'บันทึกและไปต่อ')),
        ),
      ],
    ),
  );
  return answer == 'discard' || (answer == 'save' && await save());
}
