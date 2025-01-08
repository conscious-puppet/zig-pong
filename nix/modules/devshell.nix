{ inputs, ... }:
{
  perSystem = { config, self', pkgs, lib, ... }: {
    # devShells.default = pkgs.mkShell {
    #   name = "zig-hello-world-shell";
    #   inputsFrom = [
    #     config.treefmt.build.devShell
    #   ];
    #   packages = with pkgs; [
    #     just
    #     nixd
    #     zig
    #     zls
    #     pkg-config
    #   ] ++
    #   # lib.optionals
    #   #   pkgs.stdenv.isDarwin
    #     (with pkgs.darwin.apple_sdk.frameworks; [
    #       Foundation
    #       CoreServices
    #       CoreGraphics
    #       AppKit
    #       IOKit
    #
    #       # AudioUnit
    #       # CoreAudioKit
    #       # OpenAL
    #       pkgs.darwin.apple_sdk.Libsystem
    #     ]);
    #     LDFLAGS = ''
    #       -F${pkgs.darwin.apple_sdk.frameworks.OpenGL}/Library/Frameworks
    #       -F${pkgs.darwin.apple_sdk.frameworks.AGL}/Library/Frameworks
    #       -F${pkgs.darwin.apple_sdk.frameworks.Cocoa}/Library/Frameworks
    #       -F${pkgs.darwin.apple_sdk.frameworks.IOKit}/Library/Frameworks
    #       -F${pkgs.darwin.apple_sdk.frameworks.CoreFoundation}/Library/Frameworks
    #       -F${pkgs.darwin.apple_sdk.frameworks.CoreVideo}/Library/Frameworks
    #     '';
    # };
  };
}
