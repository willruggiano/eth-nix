{ config, pkgs, ... }:
{
  services.geth = {
    enable = true;
    network = "goerli";
  };
}
