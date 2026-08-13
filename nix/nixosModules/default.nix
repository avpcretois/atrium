{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.services.atrium;
  pkg = cfg.package;
in
{
  options.services.atrium = {
    enable = mkEnableOption "Atrium display manager";

    package = mkOption {
      type = types.package;
      default = pkgs.atrium;
      defaultText = lib.literalExpression "pkgs.atrium";
      description = "Atrium package to use.";
    };

    greeter = mkOption {
      type = types.path;
      default = "${pkg}/libexec/atrium-gtk-greeter";
      defaultText = lib.literalExpression "\${cfg.package}/libexec/atrium-gtk-greeter";
      description = "GTK greeter executable path.";
    };

    cageArgs = mkOption {
      type = types.listOf types.str;
      default = [ "-s" ];
      example = [
        "-s"
        "--damage-blink"
      ];
      description = "Extra arguments passed to cage for the greeter session.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra lines appended to /etc/atrium.conf.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkg ];

    # Required for XDG_DATA_DIRS to correctly set
    services.displayManager.enable = mkDefault true;

    users.users.atriumdm = {
      isSystemUser = true;
      description = "Atrium greeter user";
      home = "/var/lib/atrium";
      createHome = true;
      group = "atriumdm";
      shell = "/usr/sbin/nologin";
    };

    users.groups.atriumdm = { };

    security.pam.services.atrium = {
      startSession = true;
      unixAuth = true;
      rules.auth = lib.mkBefore {
        atrium-no-passwd-login = {
          order = 100;
          control = "sufficient";
          modulePath = "pam_succeed_if.so";
          args = [
            "user"
            "ingroup"
            "nopasswdlogin"
          ];
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/atrium 0700 atriumdm atriumdm -"
    ];

    systemd.services.atrium = {
      description = "Atrium Display Manager";
      after = [ "systemd-logind.service" ];
      requires = [ "systemd-logind.service" ];
      conflicts = [ "getty@tty1.service" ];
      before = [ "getty@tty1.service" ];
      wantedBy = [ "graphical.target" ];
      aliases = [ "display-manager.service" ];
      environment = {
        # The daemon is a system service, so XDG_DATA_DIRS has to be set manually
        XDG_DATA_DIRS = mkDefault "${config.services.displayManager.sessionData.desktops}/share";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkg}";
        ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -USR1 $MAINPID";
        Restart = "on-failure";
        RestartSec = "5s";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    environment.etc."atrium.conf".text = ''
      # Managed by NixOS — manual changes will be lost on rebuild.
      greeter = ${lib.getExe pkgs.cage} ${lib.concatStringsSep " " cfg.cageArgs} -- ${cfg.greeter}
      crash-restart-delay = 1000
      crash-count-limit = 5
      crash-window = 60
      drm-backoff = 500
      allow-duplicate-login = false
      ${cfg.extraConfig}
    '';

    environment.etc."atrium-greeter.conf".text = ''
      # Managed by NixOS
      blank-timeout = 300
      base-font-size = 28
      login-label = Log in
      cursor-theme = Adwaita
      cursor-size = 36
    '';
  };
}
