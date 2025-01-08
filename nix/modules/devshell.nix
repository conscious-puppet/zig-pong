{ inputs, ... }:
{
  perSystem = { config, self', pkgs, lib, ... }: {
    devShells.default = pkgs.mkShell {
      name = "zig-hello-world-shell";
      inputsFrom = [
        config.treefmt.build.devShell
      ];
      packages = with pkgs; [
        just
        nixd
        zig
        zls
        pkg-config
      ];
      APPLE_SDK_ROOT =
        if
          pkgs.stdenv.hostPlatform.isDarwin
        then "${pkgs.apple-sdk.sdkroot}/System/Library/Frameworks"
        else "";
    };
  };
}
