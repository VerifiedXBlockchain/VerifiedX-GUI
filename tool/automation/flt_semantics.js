// flt_semantics.js: Claude in Chrome helper for the Flutter web semantics tree.
//
// Self-contained, no build step. Paste it into DevTools or inject it through
// Claude in Chrome's javascript tool, then use window.fltA11y:
//
//   fltA11y.list()                  -> [{id, role, label, rect:{x,y,w,h}, hasInput, value?}]
//   fltA11y.click(label)            -> {ok, id, label, hint}   DOM click on the semantics node
//   fltA11y.tap(label)              -> {ok, id, label, x, y, hint}   synthetic pointer tap at the node's centre
//   await fltA11y.type(label, text) -> {ok, id, label, value, hint}   waits for the editing connection, then sets the value
//   fltA11y.root()                  -> the <flt-semantics-host> element, or null
//   fltA11y.mode()                  -> 'light' | 'shadow' | 'none'
//   fltA11y.status()                -> {mode, visible, hostFound, nodeCount, hint}
//   fltA11y.enable()                -> clicks the hidden "Enable accessibility" placeholder
//   fltA11y.find(label)             -> the matching flt-semantics DOM node, or null (for scripting)
//
// Visibility caveat. Chrome stops requestAnimationFrame for a hidden tab
// (document.visibilityState !== 'visible': another tab in front, or the window
// fully covered). Flutter then renders no frames, so a click or tap takes
// effect on screen, and in this tree, only when frames run again. A screenshot
// through Claude in Chrome forces a few frames even while the tab stays
// hidden, which is enough to flush what is pending. status() reports the flag
// and every action's hint mentions it when it is off.
//
// Coordinates. rect values are CSS viewport pixels from
// getBoundingClientRect(). The Claude in Chrome screenshot frame can use a
// different scale (compare its reported width with window.innerWidth and
// multiply), so prefer tap(label) over a coordinate click.
//
// Written against the Flutter 3.7.12 web engine (bin/cache/flutter_web_sdk/
// flutter_web_sdk/lib/_engine/engine/semantics/*.dart in the SDK).
//
// DOM shapes. The engine mounts everything under <flt-glass-pane>. By default
// that element gets a shadow root and the semantics tree lives inside it:
//   document.querySelector('flt-glass-pane').shadowRoot > ... > flt-semantics-host
// In an automation build opened with ?automation=1 the shim in web/index.html
// removes attachShadow from the glass pane, so the engine falls back to a
// light-DOM host and page readers can traverse it:
//   flt-glass-pane > flt-element-host-node > ... > flt-semantics-host
// Every function below looks in the shadow root when there is one and in the
// glass pane itself otherwise.
//
// Node shape:
//   <flt-semantics id="flt-semantic-node-N" role="button|text|group|heading" aria-label="...">
//     <flt-semantics-container> ...children... </flt-semantics-container>  (only with children)
//     <input|textarea data-semantics-role="text-field" aria-label="...">   (text fields only)
//   </flt-semantics>
// Buttons carry role="button" and the label on the node itself. Text fields
// carry the label on the input/textarea, not on the node. Plain text gets
// role="text", a labelled node with children gets role="group".
//
// Gesture-mode caveat (tappable.dart, semantics.dart). The engine forwards a
// DOM "click" on a semantics node to the framework only while it is in
// "browser gestures" mode. Any real pointer or keyboard event (pointermove,
// mousemove, mousedown, keydown, ...) switches it to "pointer events" mode,
// and it switches back only after 500 ms without such events. A synthetic
// click dispatched inside that window is dropped without any error. The mode
// is not observable from JavaScript, so click() returns ok:true as soon as it
// has dispatched the event, together with a hint. If nothing happened, keep
// the mouse off the page, wait about 600 ms and call it again, or use tap(),
// which sends a synthetic pointerdown/pointerup pair to the glass pane and so
// goes through Flutter's own hit testing in either mode. The same gate applies
// to focusing a text field (text_field.dart turns the focus event into a tap),
// which is why type() waits for the engine's editing connection instead of
// assuming the focus went through.

(function (global) {
  'use strict';

  var GESTURE_HINT =
    'Dispatched. The engine drops synthetic clicks for 500 ms after any real ' +
    'pointer or keyboard event; if nothing happened, keep the mouse off the ' +
    'page, wait ~600 ms and retry, or use fltA11y.tap(label).';

  function glassPane() {
    return document.querySelector('flt-glass-pane');
  }

  // The node every query starts from: the shadow root when the engine created
  // one, otherwise the glass pane itself (light DOM).
  function scope() {
    var pane = glassPane();
    if (!pane) {
      return null;
    }
    return pane.shadowRoot || pane;
  }

  function mode() {
    var pane = glassPane();
    if (!pane) {
      return 'none';
    }
    return pane.shadowRoot ? 'shadow' : 'light';
  }

  function root() {
    var s = scope();
    return s ? s.querySelector('flt-semantics-host') : null;
  }

  function visible() {
    return document.visibilityState === 'visible';
  }

  // Appended to every action's hint while the tab cannot render.
  function visibilityHint() {
    return visible()
      ? ''
      : ' The tab is hidden, so Flutter renders no frames: nothing changes on screen or in this tree until the tab is visible again.';
  }

  function status() {
    var host = root();
    var count = host ? host.querySelectorAll('flt-semantics').length : 0;
    var hint;
    if (!host) {
      hint = 'No flt-semantics-host yet; the engine has not started.';
    } else if (count === 0) {
      hint = 'Semantics are off; call fltA11y.enable() or open the app with ?automation=1 in an AUTOMATION build.';
    } else {
      hint = 'Ready.' + visibilityHint();
    }
    return {
      mode: mode(),
      visible: visible(),
      hostFound: !!host,
      nodeCount: count,
      hint: hint,
    };
  }

  // Turns semantics on when the app did not do it itself (a build without the
  // AUTOMATION define). The engine's MobileSemanticsEnabler (mobile user
  // agents) only accepts a click whose element-relative offset is within 1px
  // of the placeholder's viewport midpoint, so it compares offset against an
  // absolute point; aim clientX/Y at rect.left + midX to satisfy it.
  // DesktopSemanticsEnabler (Chrome on macOS) accepts any click targeted at
  // the placeholder, so the same event works there too.
  function enable() {
    var s = scope();
    var placeholder = s ? s.querySelector('flt-semantics-placeholder') : null;
    if (!placeholder) {
      return false;
    }
    var r = placeholder.getBoundingClientRect();
    var midX = r.left + r.width / 2;
    var midY = r.top + r.height / 2;
    placeholder.dispatchEvent(new MouseEvent('click', {
      bubbles: true,
      cancelable: true,
      view: window,
      clientX: Math.round(r.left + midX),
      clientY: Math.round(r.top + midY),
    }));
    return true;
  }

  function nodes() {
    var host = root();
    return host ? Array.prototype.slice.call(host.querySelectorAll('flt-semantics')) : [];
  }

  function editableOf(node) {
    return node.querySelector(':scope > input, :scope > textarea');
  }

  function labelOf(node) {
    var own = node.getAttribute('aria-label');
    if (own) {
      return own;
    }
    var editable = editableOf(node);
    return editable ? (editable.getAttribute('aria-label') || '') : '';
  }

  function describe(node) {
    var editable = editableOf(node);
    var r = node.getBoundingClientRect();
    var info = {
      id: node.id,
      role: node.getAttribute('role') || (editable ? 'textbox' : ''),
      label: labelOf(node),
      rect: {
        x: Math.round(r.left),
        y: Math.round(r.top),
        w: Math.round(r.width),
        h: Math.round(r.height),
      },
      hasInput: !!editable,
    };
    if (editable) {
      info.value = editable.value;
    }
    return info;
  }

  function list() {
    return nodes()
      .filter(function (node) {
        return labelOf(node) !== '' || node.hasAttribute('role');
      })
      .map(describe);
  }

  // Exact aria-label match first, then case-insensitive "contains". Within a
  // pass, a button or a text field wins over a plain text or group node with
  // the same label.
  function find(label) {
    var wanted = String(label);
    var all = nodes();
    var passes = [
      function (node) { return labelOf(node) === wanted; },
      function (node) {
        return labelOf(node).toLowerCase().indexOf(wanted.toLowerCase()) !== -1;
      },
    ];
    for (var i = 0; i < passes.length; i++) {
      var matches = all.filter(passes[i]);
      if (matches.length === 0) {
        continue;
      }
      var interactive = matches.filter(function (node) {
        return node.getAttribute('role') === 'button' || editableOf(node) !== null;
      });
      return interactive.length > 0 ? interactive[0] : matches[0];
    }
    return null;
  }

  function notFound(label) {
    return {
      ok: false,
      id: null,
      label: String(label),
      hint: 'No flt-semantics node with that aria-label; call fltA11y.list() to see the labels on screen.',
    };
  }

  // DOM click on the node. Buttons get the click through the engine's Tappable
  // listener (subject to the gesture-mode caveat above); text fields get the
  // input focused instead, because the engine excludes them from Tappable.
  function click(label) {
    var node = find(label);
    if (!node) {
      return notFound(label);
    }
    var editable = editableOf(node);
    if (editable) {
      editable.focus();
      return { ok: true, id: node.id, label: labelOf(node), hint: 'Text field focused.' + visibilityHint() };
    }
    node.dispatchEvent(new MouseEvent('click', {
      bubbles: true,
      cancelable: true,
      view: window,
    }));
    return { ok: true, id: node.id, label: labelOf(node), hint: GESTURE_HINT + visibilityHint() };
  }

  // Synthetic pointer tap at the node's centre, dispatched to the glass pane
  // where the engine's PointerBinding listens (pointerdown on the pane,
  // pointerup on window; both reach it because the events bubble). This goes
  // through Flutter's hit testing, so it does not depend on the gesture mode.
  function tap(label) {
    var node = find(label);
    if (!node) {
      return notFound(label);
    }
    var pane = glassPane();
    var r = node.getBoundingClientRect();
    var x = Math.round(r.left + r.width / 2);
    var y = Math.round(r.top + r.height / 2);
    var base = {
      bubbles: true,
      cancelable: true,
      composed: true,
      view: window,
      clientX: x,
      clientY: y,
      pointerId: 1,
      pointerType: 'mouse',
      isPrimary: true,
      button: 0,
    };
    pane.dispatchEvent(new PointerEvent('pointerdown', Object.assign({ buttons: 1, pressure: 0.5 }, base)));
    pane.dispatchEvent(new PointerEvent('pointerup', Object.assign({ buttons: 0, pressure: 0 }, base)));
    return {
      ok: true,
      id: node.id,
      label: labelOf(node),
      x: x,
      y: y,
      hint: 'Pointer tap dispatched at the node centre through Flutter hit testing.' + visibilityHint(),
    };
  }

  function sleep(ms) {
    return new Promise(function (resolve) { setTimeout(resolve, ms); });
  }

  // True once the engine's editing strategy has attached its listeners to the
  // editable element. That happens in the first semantics update after the
  // framework focused the field (text_field.dart activates
  // SemanticsTextEditingStrategy), and until then an "input" event goes
  // nowhere. The strategy installs a mousedown handler that calls
  // preventDefault (text_editing.dart, preventDefaultForMouseEvents), so a
  // cancelable synthetic mousedown that does not bubble reveals it without
  // side effects.
  function editingAttached(editable) {
    return !editable.dispatchEvent(new MouseEvent('mousedown', {
      cancelable: true,
      bubbles: false,
    }));
  }

  // Focuses the text field's input/textarea (the engine turns that focus into
  // a tap, so the framework focuses the field), waits until the engine has
  // attached its editing connection, then sets the value and fires "input"
  // so the engine sends the text to Flutter. Resolves ok:false when the
  // connection never came, which is what a hidden tab or a dropped focus
  // (gesture-mode caveat) looks like.
  async function type(label, text, timeoutMs) {
    var node = find(label);
    if (!node) {
      return notFound(label);
    }
    var editable = editableOf(node);
    if (!editable) {
      return {
        ok: false,
        id: node.id,
        label: labelOf(node),
        hint: 'That node is not a text field (no input/textarea child).',
      };
    }
    var timeout = timeoutMs === undefined ? 2000 : timeoutMs;
    var deadline = Date.now() + timeout;
    if (document.activeElement !== editable) {
      editable.focus();
    }
    while (!editingAttached(editable) && Date.now() < deadline) {
      await sleep(50);
    }
    if (!editingAttached(editable)) {
      return {
        ok: false,
        id: node.id,
        label: labelOf(node),
        value: editable.value,
        hint: 'The engine did not attach its editing connection within ' + timeout +
          ' ms. That needs one frame after the field gained focus, so either ' +
          'the tab is hidden or the focus was dropped (gesture-mode caveat); ' +
          'retry after ~600 ms without pointer activity.' + visibilityHint(),
      };
    }
    var value = String(text);
    editable.value = value;
    editable.setSelectionRange(value.length, value.length);
    editable.dispatchEvent(new Event('input', { bubbles: true }));
    return {
      ok: true,
      id: node.id,
      label: labelOf(node),
      value: editable.value,
      hint: 'Value sent through the engine editing connection.' + visibilityHint(),
    };
  }

  global.fltA11y = {
    list: list,
    click: click,
    tap: tap,
    type: type,
    root: root,
    mode: mode,
    status: status,
    enable: enable,
    find: find,
  };
})(window);
