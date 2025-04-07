{
  inputs.fenix.url = "github:nix-community/fenix";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.aws-nitro-enclaves-sdk-c-nix.url = "github:whs-dot-hk/aws-nitro-enclaves-sdk-c-nix";
  inputs.tmkms-light.url = "github:crypto-com/tmkms-light";

  inputs.tmkms-light.flake = false;

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
    in {
      packages.default = pkgs.rustPlatform.buildRustPackage {
        cargoBuildFlags = "-p tmkms-nitro-helper";
        cargoHash = "sha256-bgjqNZvcIsCQHEII6QrHQ76SseL7Iay+21oZaaHoBws=";
        pname = "tmkms-light";
        src = inputs.tmkms-light;
        version = "1.0.0";
      };
      packages.docker = let
        app = pkgs.rustPlatform.buildRustPackage {
          cargoBuildFlags = "-p tmkms-nitro-enclave";
          cargoHash = "sha256-bgjqNZvcIsCQHEII6QrHQ76SseL7Iay+21oZaaHoBws=";
          pname = "tmkms-nitro-enclave";
          src = inputs.tmkms-light;
          version = "1.0.0";
          buildInputs = [inputs.aws-nitro-enclaves-sdk-c-nix.packages.${system}.aws-nitro-enclaves-sdk-c];
          nativeBuildInputs = [pkgs.pkg-config];
        };
      in
        pkgs.dockerTools.buildImage {
          name = "tmkms-nitro-enclave";
          tag = "nix";
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [pkgs.dockerTools.caCertificates];
          };
          config = {
            Entrypoint = ["${app}/bin/tmkms-nitro-enclave"];
          };
        };
    });
}
