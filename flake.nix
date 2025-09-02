{
  description = "Cross-OS dev setup (macOS + Ubuntu) using Nix flakes, Home Manager, nix-darwin";

  inputs = {
    # Stable & Unstable (for a few newer tools)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS (nix-darwin)
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets (optional; wired but unused until you add secrets)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self, nixpkgs, nixpkgs-unstable, home-manager, darwin, sops-nix, ...
  }:
  let
    # ========== Customize here ==========
    username = "your_username";

    macHosts = {
      "mac-m1" = {
        system = "aarch64-darwin";
        hostName = "YOUR_M1_HOSTNAME";
      };
      # "mac-intel" = {
      #   system = "x86_64-darwin";
      #   hostName = "YOUR_INTEL_HOSTNAME";
      # };
    };

    linuxHosts = {
      "ubuntu-xyz" = {
        system = "x86_64-linux";
        hostName = "YOUR_UBUNTU_HOSTNAME";
        distro = "ubuntu";
      };
      "arch-xyz" = {
        system = "x86_64-linux";
        hostName = "YOUR_ARCH_HOSTNAME";
        distro = "arch";
      };
      # "arm-ubuntu" = {
      #   system = "aarch64-linux";
      #   hostName = "YOUR_ARM_UBUNTU_HOSTNAME";
      #   distro = "ubuntu";
      # };
    };
    # ====================================

    mkPkgs = system: import nixpkgs {
      inherit system;
      overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable { inherit system; };
        })
      ];
      config.allowUnfree = true;
    };

    # Common HM user module stack (shared + per-OS + your HM modules)
    hmUserModulesCommon = [
      ./home/common.nix
      ./modules/programs/zsh.nix
      ./modules/programs/git.nix
      ./modules/programs/direnv.nix
      ./modules/programs/starship.nix
      ./modules/programs/wezterm.nix
      ./modules/programs/atuin.nix
      ./modules/programs/vscode.nix
      ./modules/services/gpg-agent.nix
      sops-nix.homeManagerModules.sops
    ];

    # Mac-only & Linux-only HM layers (kept separate in your repo)
    hmMacExtras   = [ ./home/macos.nix   ];
    hmLinuxExtras = [ ./home/linux.nix   ];

    # Helper to compute the home directory from a system triple
    userHomeDir = system:
      if builtins.match ".*darwin.*" system != null
      then "/Users/${username}"
      else "/home/${username}";

    # Build one darwin system (per host)
    mkDarwin = name: { system, hostName }:
      darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # Your macOS-host defaults/tweaks. You can keep this a directory module (./hosts/macos)
          # or split per-host files under ./hosts/macos/<name>.nix and import those instead.
          ./hosts/macos

          home-manager.darwinModules.home-manager
          {
            # System-level basics
            services.nix-daemon.enable = true;
            nix.package = (mkPkgs system).nix;
            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            # macOS hostname
            networking.hostName = hostName;

            # Optional: set zsh as login shell
            programs.zsh.enable = true;
            users.users.${username} = {
              home  = userHomeDir system;
              shell = (mkPkgs system).zsh;
            };

            # Home Manager user wiring
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = { pkgs, ... }: {
              # Bring in shared + macOS-only HM modules
              imports = hmUserModulesCommon ++ hmMacExtras;
              # HM state version
              home.stateVersion = "24.05";
              # Ensure $HOME is correct
              home.username = username;
              home.homeDirectory = userHomeDir system;
            };

            # sops-nix (available once you add secrets)
            imports = [ sops-nix.darwinModules.sops ];

            # Required by nix-darwin; bump if you rely on newer nix-darwin features
            system.stateVersion = 4;
          }
        ];
      };

    # Build one Home Manager user configuration for Linux
    mkLinuxHome = name: { system, hostName, distro }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        modules = [
          # Your Linux host glue (distro-specific)
          ./hosts/${distro}

          # HM shared + Linux-only modules
          {
            home.username     = username;
            home.homeDirectory = userHomeDir system;
            home.stateVersion  = "24.05";
            
            # Make host info available to modules
            _module.args.hostName = hostName;
            _module.args.distro = distro;
          }
        ] ++ hmUserModulesCommon ++ hmLinuxExtras;
      };

    # devShell helper (optional)
    mkDevShell = system:
      (mkPkgs system).mkShell {
        buildInputs = with (mkPkgs system); [ git just ];
      };

  in
  {
    # --- Build all the Mac hosts you defined above
    darwinConfigurations =
      builtins.listToAttrs (map
        (name: { name = name; value = mkDarwin name macHosts.${name}; })
        (builtins.attrNames macHosts));

    # --- Build one Linux HM profile per host you defined
    homeConfigurations =
      builtins.listToAttrs (map
        (name: {
          # The flake target becomes: .#${name}
          name  = name;
          value = mkLinuxHome name linuxHosts.${name};
        })
        (builtins.attrNames linuxHosts));

    # Optional: dev shells for common systems
    devShells = {
      aarch64-darwin.default = mkDevShell "aarch64-darwin";
      # x86_64-darwin.default  = mkDevShell "x86_64-darwin";
      x86_64-linux.default   = mkDevShell "x86_64-linux";
      # aarch64-linux.default  = mkDevShell "aarch64-linux";
    };
  };
}
