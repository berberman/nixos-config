{ inputs, ... }: {
  imports = [ "${inputs.vscode-server}/modules/vscode-server/home.nix" ];

  services.vscode-server.enable = true;
  home.stateVersion = "24.05";
}
