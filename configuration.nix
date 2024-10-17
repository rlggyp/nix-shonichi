{ config, pkgs, lib, ... }:

{
  # Import hardware configuration
  imports = [ ./hardware-configuration.nix ];

  # Bootloader Configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];

  # Handling of power keys
	# don’t shutdown when power button is short-pressed
	services.logind.extraConfig = ''
  	HandlePowerKey=ignore
	'';

  # Hostname
  networking.hostName = "nixos";

  # Enable NetworkManager for networking
  networking.networkmanager.enable = true;

  # Timezone and Locale Settings
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  # X11 Configuration and Window Manager
  services.xserver.enable = true;
	programs.xwayland.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "rlggyp";

  services.xserver.excludePackages = [
    pkgs.xterm
  ];

  services.xserver.windowManager.awesome = {
    enable = true;
    luaModules = with pkgs.luaPackages; [
      luarocks    # Lua package manager
      vicious     # Awesome WM widget library
      luadbi-mysql # Database abstraction layer for MySQL
    ];
  };
  services.xserver.videoDrivers = [ "intel" ];

  # X11 Device Configuration
  services.xserver.deviceSection = ''
    Option "DRI" "3"
    Option "TearFree"        "false"
    Option "TripleBuffer"    "false"
    Option "SwapbuffersWait" "false"
  '';

  # Enable touchpad and input settings via libinput
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
    mouse.disableWhileTyping = true;
    touchpad.disableWhileTyping = true;
    touchpad.tappingButtonMap = "lrm";
  };

  # Compositor Configuration (Picom)
	services.picom = {
    enable = true;
		settings =  {
		  backend = "glx";
		  vSync = true;
			blur = false;
			blurExclude = [ ];
    };
		backend = "glx";
		vSync = true;
    fade = true;
    fadeDelta = 4;
    shadow = false;
    shadowExclude = [ ];
    inactiveOpacity = 1;
  };

  # Hardware Acceleration and Firmware
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [ intel-media-driver ];
  hardware.enableAllFirmware = true;

  # Sound with Pipewire
  sound.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		jack.enable = true;
		extraConfig.pipewire."99-silent-bell.conf" = { 
			"context.properties"= {
      	"module.x11.bell" = false;
    	};
		};
	};
  security.rtkit.enable = true;

  # User Configuration
  users.users.rlggyp = {
    isNormalUser = true;
    description = "erlangga";
    extraGroups = [ "users" "networkmanager" "wheel" "docker" "audio" "video" "dialout" ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Zsh
  programs.zsh.enable = true;

  # System Packages
  environment.systemPackages = with pkgs; [
    neovim
    firefox
    chromium
		obs-studio
		python3
    git
    picom
    eza
    ripgrep
    btop
    nodejs
    bat
    pcmanfm
    guvcview
    mpv
    gnumake
    cmake
    gcc
    wezterm
    tmux
    zsh
    dmenu
    brightnessctl
    lxappearance
    breeze-gtk
    v4l-utils
    zip
    unzip
    unrar
    xclip
    breeze-icons
    pavucontrol
    pamixer
    sxiv
    xdg-utils
    feh
    yazi
    rofimoji
  ];

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      nerdfonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono NF" ];
      };
    };
  };

  # XDG-MIME, manage default application for specific file format
  xdg.mimeApps = {
	  enable = true;
    defaultApplications = {
			"application/pdf" = [ "firefox.desktop" ];
			"text/html" = [ "firefox.desktop" ];
			"video/mp4" = [ "mpv.desktop" ];
			"video/x-matroska" = [ "mpv.desktop" ];
			"image/gif" = [ "sxiv.desktop" ];
			"image/jpeg" = [ "sxiv.desktop" ];
			"image/png" = [ "sxiv.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
  };

	# Set environment variables
	environment.variables = {
		EDITOR = "nvim";
		VISUAL = "nvim";
		# LIBVA_DRIVER_NAME = "iHD";
		# VDPAU_DRIVER = "va_gl";
		# COGL_ATLAS_DEFAULT_BLIT_MODE = "framebuffer";
	};

	environment.etc."containers/policy.json".text = lib.mkAfter ''
	{
			"default": [
					{
							"type": "insecureAcceptAnything"
					}
			],
			"transports":
					{
							"docker-daemon":
									{
											"": [{"type":"insecureAcceptAnything"}]
									}
					}
	}
  '';

  # System State Version
  system.stateVersion = "24.05";

	nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
