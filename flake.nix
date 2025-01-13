{
  inputs.fenix.url = "github:nix-community/fenix";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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
        cargoHash = "sha256-HmjR6/2oQsv8vP/eSvHf4L4x3Nwl69zTY6d3P2eh3YM=";
        pname = "tmkms-light";
        src = inputs.tmkms-light;
        version = "1.0.0";
      };
    });
}
