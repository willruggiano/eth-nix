{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.ethereum.mev-boost;
in {
  options.services.ethereum.mev-boost = {
    enable = mkEnableOption "mev-boost";
    package = mkOption {
      type = types.package;
      description = "The package to use";
      default = pkgs.mev-boost;
    };
    network = mkOption {
      type = types.enum ["mainnet" "goerli" "kiln" "ropsten" "sepolia"];
    };
    relays = mkOption {
      type = with types; listOf str;
      description = "Relay urls";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mev-boost = {
      enable = true;
      description = "mev-boost";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        # Hardening:
        PrivateTmp = true;
        ProtectSystem = "full";
        NoNewPrivileges = true;
        PrivateDevices = true;
        MemoryDenyWriteExecute = true;
      };
      script = ''
        ${cfg.package}/bin/mev-boost -${cfg.network} -relay-check -relays ${concatStringsSep "," cfg.relays}
      '';
    };
  };
}
