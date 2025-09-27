import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_constants.dart';
import '../providers/web_session_provider.dart';
import '../dialogs.dart';
import '../../utils/html_helpers.dart';

class IdleDetectorWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final Duration idleThreshold;
  
  const IdleDetectorWrapper({
    super.key,
    required this.child,
    this.idleThreshold = const Duration(minutes: IDLE_TIMEOUT_MINUTES),
  });

  @override
  ConsumerState<IdleDetectorWrapper> createState() => _IdleDetectorWrapperState();
}

class _IdleDetectorWrapperState extends ConsumerState<IdleDetectorWrapper> {
  Timer? _idleTimer;
  late FocusNode _focusNode;
  bool _isShowingWarning = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _resetIdleTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _isShowingWarning = false;
    
    _idleTimer = Timer(widget.idleThreshold, () async {
      final session = ref.read(webSessionProvider);
      if (session.isAuthenticated && !_isShowingWarning) {
        _isShowingWarning = true;
        await _showIdleWarning();
      }
    });
  }

  Future<void> _showIdleWarning() async {
    Timer? autoLockTimer;
    bool userResponded = false;

    autoLockTimer = Timer(const Duration(seconds: 15), () {
      if (!userResponded) {
        Navigator.of(context, rootNavigator: true).pop(); 
        HtmlHelpers().redirect("/");
      }
    });

    final confirmed = await ConfirmDialog.show(
      title: "Session Timeout Warning",
      body: "Your session will be locked due to inactivity. Do you want to stay logged in?\n\nThis dialog will auto-lock in 15 seconds.",
      confirmText: "Stay Logged In",
      cancelText: "Lock Now",
    );

    userResponded = true;
    autoLockTimer.cancel();

    if (confirmed == true) {
      _resetIdleTimer();
    } else {
      HtmlHelpers().redirect("/");
    }
  }

  void _onUserInteraction() {
    _resetIdleTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          _onUserInteraction();
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerDown: (_) => _onUserInteraction(),
        onPointerMove: (_) => _onUserInteraction(),
        onPointerUp: (_) => _onUserInteraction(),
        child: GestureDetector(
          onTap: () {
            _onUserInteraction();
            _focusNode.requestFocus();
          },
          onScaleUpdate: (_) => _onUserInteraction(),
          behavior: HitTestBehavior.translucent,
          child: widget.child,
        ),
      ),
    );
  }
} 