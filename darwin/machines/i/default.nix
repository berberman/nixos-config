{ inputs, pkgs, ... }:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.berberman = ./home.nix;
  system.primaryUser = "berberman";
  environment.systemPackages = with pkgs; [
    vim
    tmux
    tree
    wget
    ripgrep
    fastfetch
    # fido
    openssh
  ];
  networking.hostName = "POTATO-I";
  users.users.berberman = {
    name = "berberman";
    home = "/Users/berberman";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.victor-mono
  ];

  system.defaults.finder._FXShowPosixPathInTitle = true;
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.AppleShowAllFiles = true;
  system.defaults.finder.ShowPathbar = true;
  system.defaults.finder.ShowStatusBar = true;
  system.defaults.finder.FXPreferredViewStyle = "clmv";
  system.defaults.finder.FXDefaultSearchScope = "SCcf";
  system.defaults.NSGlobalDomain.AppleShowScrollBars = "Always";
  system.defaults.NSGlobalDomain.AppleScrollerPagingBehavior = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;

  system.defaults.spaces.spans-displays = false;
  system.defaults.dock = {
    autohide = true;
    expose-group-apps = true;
    mru-spaces = false;
    show-recents = false;
    wvous-bl-corner = 1;
    wvous-br-corner = 1;
    # application windows
    wvous-tl-corner = 3;
    wvous-tr-corner = 1;
  };
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    brews = [ ];
    casks = [
      "element"
      "google-chrome"
      "raycast"
      "visual-studio-code"
      "vlc"
      "yubico-authenticator"
      "firefox"
      "zoom"
      "telegram-desktop"
      "nikitabobko/tap/aerospace"
      "the-unarchiver"
      "discord"
      "obs"
      "maccy"
      "stats"
      "slack"
      "zulip"
      "shottr"
      "thaw"
      "jetbrains-toolbox"
    ];
    masApps = {
      "Yubico Authenticator" = 1497506650;
      "Tailscale" = 1475387142;
    };
  };
  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
