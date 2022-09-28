{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.ethereum;
in {
  imports = [./consensus ./execution ./monitoring];

  options.services.ethereum = {
    jwt-secret = {
      enable = mkOption {
        type = types.bool;
        description = "Authenticate communication between execution and consensus clients via a JWT secret.";
        default = true;
      };
      generate = mkOption {
        type = types.bool;
        description = "Automatically generate the JWT secret.";
        default = true;
      };
      path = mkOption {
        type = types.path;
        description = "The path to the JWT secret file. If JWT generation is enabled (the default), this will be the location of the JWT secret file after it has been generated.";
        default = null;
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.jwt-secret.enable && cfg.jwt-secret.generate) {
      services.ethereum.jwt-secret.path = let
        jwt-secret =
          pkgs.runCommand "jwt-secret" {
            buildInputs = with pkgs; [coreutils openssl];
          } ''
            mkdir $out
            openssl rand -hex 32 | tr -d "\n" > $out/jwt.hex
          '';
      in "${jwt-secret}/jwt.hex";
    })
  ];
}
