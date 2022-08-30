{
  description = "A set of NixOps configurations for Ethereum 2 nodes.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.utils.url = "github:gytis-ivaskevicius/flake-utils-plus";

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    overlay = final: prev: {
      ethdo = prev.callPackage ./packages/ethdo {};
      prysm = prev.callPackage ./packages/prysm {};
    };
    pkgs = import nixpkgs {
      inherit system;
      overlays = [overlay];
    };
  in {
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
      buildInputs = with pkgs; [morph nodejs];
    };

    nixosConfigurations = {
      node = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [];
      };
    };

    nixosModules = {
      geth = import ./modules/geth;
      prysm = import ./modules/prysm;
    };

    overlays.default = overlay;

    packages."${system}" = utils.lib.exportPackages self.overlays {inherit pkgs;};
  };
}
