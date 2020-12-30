{ config, pkgs, ... }:

{
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ./xmonad.hs;
  };

  # set wm for KDE
  xdg.configFile."plasma-workspace/env/set_window_manager.sh".text = ''
  export KDEWM=${config.xsession.windowManager.command}
  '';
}
