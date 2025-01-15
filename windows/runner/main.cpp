#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"
#include <uni_links_desktop/uni_links_desktop_plugin.h>

const char kQuitChannelName[] = "io.reserveblock.wallet/quit";

bool ShouldQuitApp(flutter::FlutterEngine* engine) {
  bool should_quit = false;

  // Set up the platform channel
  engine->SendPlatformMessage(
      kQuitChannelName,
      nullptr,
      [](const uint8_t* data, size_t size, void* user_data) {
        auto* result = reinterpret_cast<bool*>(user_data);
        *result = true;
      },
      &should_quit);

  return should_quit;
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
  if (message == WM_CLOSE) {
    auto controller = reinterpret_cast<flutter::FlutterViewController*>(GetWindowLongPtr(hwnd, GWLP_USERDATA));
    if (controller) {
      auto* messenger = controller->engine()->messenger();

      // Create a MethodChannel to communicate with Flutter
      flutter::MethodChannel<> channel(
          messenger, "com.example.app/quit",
          &flutter::StandardMethodCodec::GetInstance());

      bool should_quit = false;

      // Call Flutter method 'shouldQuit' and wait for the result
      channel.InvokeMethod("shouldQuit", nullptr,
          [&should_quit](const flutter::EncodableValue* result) {
            if (result && std::holds_alternative<bool>(*result)) {
              should_quit = std::get<bool>(*result);
            }
          });

      if (should_quit) {
        DestroyWindow(hwnd);
      } else {
        return 0;  // Cancel the close event
      }
    }
  }

  return DefWindowProc(hwnd, message, wparam, lparam);
}


int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  HWND hwnd = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"RBX Wallet");
  if (hwnd != NULL) {
    DispatchToUniLinksDesktop(hwnd);

    ::ShowWindow(hwnd, SW_NORMAL);
    ::SetForegroundWindow(hwnd);
    return EXIT_FAILURE;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments = GetCommandLineArguments();
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 910);
  if (!window.CreateAndShow(L"VFX Switchblade", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(false);  // Prevent immediate quit on close

  // Hook the custom window procedure
  SetWindowLongPtr(window.GetHandle(), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(WndProc));

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
