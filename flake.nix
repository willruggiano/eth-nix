rec {
  description = "A set of NixOps configurations for Ethereum 2 nodes.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils, ... }:
    let
      system = "x86_64-linux";
      overlay = final: prev: {
        ethdo = prev.callPackage ./packages/ethdo { };
        prysm = prev.callPackage ./packages/prysm { };
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          overlay
        ];
      };
    in
    {
      nixosModules = {
        geth = import ./modules/geth;
        prysm = import ./modules/prysm;
      };

      nixopsConfigurations = rec {
        execution = import ./nodes/execution;
        beacon = import ./nodes/beacon;
        validator = import ./nodes/validator;

        default = {
          inherit nixpkgs execution beacon validator;

          network = {
            inherit description;

            enableRollback = true;
            storage.legacy = {
              databasefile = "~/.nixops/deployments.nixops";
            };
          };

          defaults = {
            imports = [
              ./nodes/common.nix
            ];
          };
        };
      };

      apps."${system}" = {
        geth = utils.lib.mkApp {
          drv = pkgs.go-ethereum;
          name = "geth";
        };

        beacon-chain = utils.lib.mkApp {
          drv = pkgs.prysm;
          name = "beacon-chain";
        };
        client-stats = utils.lib.mkApp {
          drv = pkgs.prysm;
          name = "client-stats";
        };
        validator = utils.lib.mkApp {
          drv = pkgs.prysm;
          name = "validator";
        };

        ethdo = utils.lib.mkApp {
          drv = pkgs.ethdo;
        };
      };

      devShell."${system}" = pkgs.mkShell {
        name = "eth-nix";
        buildInputs = with pkgs; [ nixopsUnstable nodejs ];
      };

      inherit overlay;

      packages."${system}" = {
        inherit (pkgs) ethdo prysm;
      };
    };
}
