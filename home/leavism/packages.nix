{ pkgs, hostname ? "default" }:
let
  # === Nix Packages Categories ===
  # https://search.nixos.org/packages
  # Only put packages that support both nixos and darwin in these categories.
  # For packages that support only one or the other, install them via the host.
  dev-light = with pkgs; [
    eza
    oh-my-posh
    git
    vscode
    neovim
    nodenv
    pyenv
  ];

  dev-full = with pkgs; [
    docker_27
  ] ++ dev-light;

  work = with pkgs; [
    teams
    slack
  ];

  utilities = with pkgs; [
    obsidian
    transmission
  ];

  # === Base Packages ===
  # Packages that should be on all machines.
  # Default to system packages, unless you want something for just the user.
  baseSystemPackages = with pkgs; [
    mkalias
  ];

  baseUserPackages = with pkgs; [];

  # Fallback to homebrew only if nix doesn't have it or can't build for macOS.
  # ei. Firefox and 1password are nix packages but can't build for macOS, then
  # you should use homebrew instead.
  baseHomebrewPackages = {
    onActivation.cleanup = "zap";
    enable = true;
    casks = [
      "aerospace"
      "sensei"
      "1password" # Nix package is broken on macOS
    ];
    masApps = {
      # "Fantastical" = 975937182;
      # "Things" = 904280696;
      # "Microsoft OneNote" = 784801555;
      # "Craft" = 1487937127;
      # "OneDrive" = 823766827;
      # "Microsoft Excel" = 462058435;
      # "Microsoft Outlook" = 985367838;
      # "Microsoft Word" = 462054704;
      # "Microsoft PowerPoint" = 462062816;
    };
  };

  # === Host-Specific Packages ===
  hostSpecificPackages = {
    # === Muninn-specific packages ===
    # This is my MacBook Air, I should probably keep things light.
    muninn = {
      # Default to system packages, unless you want something for just the user.
      systemPackages = with pkgs; [
        # Muninn-specific system packages
      ];
      homebrewPackages = {
        casks = [];
        masApps = {};
      };
      userPackages = with pkgs; [

      ];
    };

    # Odin-specific packages
    # This is my spec'd up Mac Mini. Should be able to handle most workloads.
    odin = {
      # Default to system packages, unless you want something for just the user.
      systemPackages = with pkgs; [
        # Odin-specific system packages
      ];
      homebrewPackages = {
        casks = [];
        masApps = {
          "Final Cut Pro" = 424389933;
          "Compressor" = 424390742;
        };
      };
      userPackages = with pkgs; [];
    };

    # Default empty configuration
    default = {
      userPackages = [];
      systemPackages = [];
      homebrewPackages = {
        casks = [];
        masApps = {};
      };
    };
  };

  # Get host-specific packages or default if host not found
  hostPackages = hostSpecificPackages.${hostname} or hostSpecificPackages.default;
in
{
  # === Final Package Sets ===
  userPackages = baseUserPackages ++ hostPackages.userPackages;

  systemPackages = baseSystemPackages ++ hostPackages.systemPackages;

  homebrewPackages = baseHomebrewPackages // {
    casks = baseHomebrewPackages.casks ++ hostPackages.homebrewPackages.casks;
    masApps = baseHomebrewPackages.masApps // hostPackages.homebrewPackages.masApps;
  };
}
