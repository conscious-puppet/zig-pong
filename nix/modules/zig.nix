{ inputs, ... }:
{
  perSystem = { config, self', pkgs, lib, system, ... }:
    let
      env = inputs.zig2nix.outputs.zig-env.${system} { };
      system-triple = env.lib.zigTripleFromString system;
    in
    with builtins; with env.lib; with env.pkgs.lib;{

      legacyPackages.target = genAttrs allTargetTriples (target: env.packageForTarget target ({
        src = cleanSource ./../..;

        nativeBuildInputs = with env.pkgs; [ ];

        buildInputs = with env.pkgsForTarget target;
          # (lib.optionals
          #   pkgs.stdenv.isDarwin
          #   (with pkgs.darwin.apple_sdk.frameworks; [
          #     # IOKit
          #     # AudioUnit
          #     # CoreAudioKit
          #     # OpenAL
          #     # pkgs.darwin.apple_sdk.Libsystem
          #
          #     # Foundation
          #     # CoreServices
          #     # CoreGraphics
          #     # AppKit
          #     # IOKit
          #   ])) ++
          (with pkgs.darwin.apple_sdk.frameworks;
          [
            pkg-config
            Foundation
            CoreServices
            CoreGraphics
            AppKit
            IOKit
            pkgs.darwin.apple_sdk.Libsystem
          ]);

        # Smaller binaries and avoids shipping glibc.
        zigPreferMusl = true;

        # This disables LD_LIBRARY_PATH mangling, binary patching etc...
        # The package won't be usable inside nix.
        zigDisableWrap = true;
      } // optionalAttrs (!pathExists ../../build.zig.zon) {
        pname = "my-zig-project";
        version = "0.0.0";
      }));

      # nix build .
      packages.default = self'.legacyPackages.target.${system-triple}.override {
        # Prefer nix friendly settings.
        zigPreferMusl = false;
        zigDisableWrap = false;
      };

      # For bundling with nix bundle for running outside of nix
      # example: https://github.com/ralismark/nix-appimage
      apps.bundle.target = genAttrs allTargetTriples (target:
        let
          pkg = packages.target.${target};
        in
        {
          type = "app";
          program = "${pkg}/bin/default";
        });


      # default bundle
      apps.bundle.default = self'.apps.bundle.target.${system-triple};

      # nix run .
      apps.default = env.app [ ] "zig build run -- \"$@\"";

      # nix run .#build
      apps.build = env.app [ ] "zig build \"$@\"";

      # nix run .#test
      apps.test = env.app [ ] "zig build test -- \"$@\"";

      # nix run .#docs
      apps.docs = env.app [ ] "zig build docs -- \"$@\"";

      # nix run .#deps
      apps.deps = env.showExternalDeps;

      # nix run .#zon2json
      apps.zon2json = env.app [ env.zon2json ] "zon2json \"$@\"";

      # nix run .#zon2json-lock
      apps.zon2json-lock = env.app [ env.zon2json-lock ] "zon2json-lock \"$@\"";

      # nix run .#zon2nix
      apps.zon2nix = env.app [ env.zon2nix ] "zon2nix \"$@\"";

      # nix develop
      devShells.default = env.mkShell {
        name = "zig-hello-world-shell";
        inputsFrom = [
          config.treefmt.build.devShell
        ];
        packages = with pkgs; [
          just
          nixd
          zig
          zls
        ];
        LDFLAGS = ''
          -F${pkgs.darwin.apple_sdk.frameworks.OpenGL}/Library/Frameworks
          -F${pkgs.darwin.apple_sdk.frameworks.AGL}/Library/Frameworks
          -F${pkgs.darwin.apple_sdk.frameworks.Cocoa}/Library/Frameworks
          -F${pkgs.darwin.apple_sdk.frameworks.IOKit}/Library/Frameworks
          -F${pkgs.darwin.apple_sdk.frameworks.CoreFoundation}/Library/Frameworks
          -F${pkgs.darwin.apple_sdk.frameworks.CoreVideo}/Library/Frameworks
        '';
      };

    };
}
