{
  options,
  config,
  lib,
  host ? "",
  inputs ? { },
  ...
}:
with lib;
with lib.excalibur;
let
  cfg = config.excalibur.services.openssh;

  user = config.users.users.${config.excalibur.user.name};
  user-id = builtins.toString user.uid;

  name = host; # Use the provided hostname or default if not specified.

  default-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLbrIDbLSEpfOc4onBP8y6aKCNEN5rEe0J3h7klfKzG mcamp@butler";

  other-hosts = lib.filterAttrs (
    key: host: key != name && (host.config.excalibur.user.name or null) != null
  ) ((inputs.self.nixosConfigurations or { }) // (inputs.self.darwinConfigurations or { }));

  other-hosts-config = lib.concatMapStringsSep "\n" (
    name:
    let
      remote = other-hosts.${name};
      remote-user-name = remote.config.excalibur.user.name;
      remote-user-id = builtins.toString remote.config.users.users.${remote-user-name}.uid;

    in
    # forward-gpg = optionalString
    #   (config.programs.gnupg.agent.enable
    #     && remote.config.programs.gnupg.agent.enable) ''
    #   RemoteForward /run/user/${remote-user-id}/gnupg/S.gpg-agent /run/user/${user-id}/gnupg/S.gpg-agent.extra
    #   RemoteForward /run/user/${remote-user-id}/gnupg/S.gpg-agent.ssh /run/user/${user-id}/gnupg/S.gpg-agent.ssh
    # '';
    ''
      Host ${name}
        User ${remote-user-name}
        ForwardAgent yes
        Port ${builtins.toString cfg.port}
    ''
  ) (builtins.attrNames other-hosts);
in
{
  options.excalibur.services.openssh = with types; {
    enable = mkEnableOption "OpenSSH support";
    authorizedKeys = mkOption {
      type = listOf str;
      default = [ default-key ];
      description = "The public keys to apply.";
    };
    port = mkOption {
      type = port;
      default = 2222;
      description = "The port to listen on (in addition to 22).";
    };
    manage-other-hosts = mkOption {
      type = bool;
      default = true;
      description = "Whether to add other host configurations to SSH config.";
    };
    extraConfigs = mkOption {
      type = lines;
      default = "";
      description = "Additional SSH configurations.";
    };
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host *
          HostKeyAlgorithms +ssh-rsa

        ${optionalString cfg.manage-other-hosts other-hosts-config}
        ${cfg.extraConfigs}
      '';
    };

    home.activation.authorizedKeys = inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${config.home.homeDirectory}/.ssh"
      echo "${concatStringsSep "\n" cfg.authorizedKeys}" > "${config.home.homeDirectory}/.ssh/authorized_keys"
      chmod 600 "${config.home.homeDirectory}/.ssh/authorized_keys"
    '';

    programs.zsh.shellAliases = foldl (
      aliases: system: aliases // { "ssh-${system}" = "ssh ${system} -t tmux a"; }
    ) { } (builtins.attrNames other-hosts);
  };
}
