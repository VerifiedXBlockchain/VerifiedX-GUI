import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_constants.dart';
import '../providers/web_session_provider.dart';
import '../dialogs.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/html_helpers.dart';
import '../storage.dart';
import '../singletons.dart';

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
    bool isLocking = false;

    autoLockTimer = Timer(const Duration(seconds: 15), () {
      if (!userResponded && !isLocking) {
        isLocking = true;
        Navigator.of(context, rootNavigator: true).pop();
        _savePendingRedirectAndLock();
      }
    });

    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmDialog.show(
      title: l10n.r3eSessionTimeoutWarning,
      body: l10n.r3eSessionTimeoutBody,
      confirmText: l10n.r3eStayLoggedIn,
      cancelText: l10n.r3eLockNow,
    );

    userResponded = true;
    autoLockTimer.cancel();

    if (confirmed == true) {
      _resetIdleTimer();
    } else if (!isLocking) {
      isLocking = true;
      _savePendingRedirectAndLock();
    }
  }

  void _savePendingRedirectAndLock() {
    final currentUrl = HtmlHelpers().getUrl();

    // Only save if we're on a dashboard route (not already on auth screen)
    if (currentUrl.contains('/#/dashboard') || currentUrl.contains('#/dashboard')) {
      // Extract just the hash portion of the URL
      final hashIndex = currentUrl.indexOf('#');
      if (hashIndex != -1) {
        final hashPath = currentUrl.substring(hashIndex + 1);
        singleton<Storage>().setString(Storage.PENDING_REDIRECT_URL, hashPath);
      }
    }

    // Soft lock: clear in-memory session state and navigate to auth screen
    // via Flutter router instead of doing a full page reload, which avoids
    // IndexedDB flush race conditions that could corrupt the password hash.
    ref.read(webSessionProvider.notifier).softLock();
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