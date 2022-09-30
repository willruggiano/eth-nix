{
  description = "A set of NixOps configurations for Ethereum 2 nodes.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.utils.url = "github:gytis-ivaskevicius/flake-utils-plus";

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  } @ inputs:
    (utils.lib.mkFlake {
      inherit self inputs;
      supportedSystems = ["aarch64-linux" "x86_64-linux"];

      channelsConfig = {allowBroken = true;};

      sharedOverlays = [self.overlays.default];

      hostDefaults.modules = [./modules/ethereum];

      outputsBuilder = channels: {
        apps = let
          pkgs = channels.nixpkgs;
        in {
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
          mev-boost = utils.lib.mkApp {
            drv = pkgs.mev-boost;
          };
          validator = utils.lib.mkApp {
            drv = pkgs.prysm;
            name = "validator";
          };

          ethdo = utils.lib.mkApp {
            drv = pkgs.ethdo;
          };
          prysmctl = utils.lib.mkApp {
            drv = pkgs.prysm;
            name = "prysmctl";
          };
        };

        devShells.default = channels.nixpkgs.mkShell {
          name = "eth-nix";
          buildInputs = with channels.nixpkgs; [morph nodejs];
        };

        packages = utils.lib.exportPackages self.overlays channels;
      };
    })
    // {
      nixosModules = {
        ethereum = import ./modules/ethereum;
      };

      overlays.default = final: prev: {
        ethdo = prev.callPackage ./packages/ethdo {};
        mev-boost = prev.callPackage ./packages/mev-boost {};
        prysm = prev.callPackage ./packages/prysm {};
      };
    };
}
