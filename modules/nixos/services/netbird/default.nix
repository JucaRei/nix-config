{ lib, config, pkgs, ... }:
with lib;
with lib.excalibur;
let cfg = config.excalibur.services.netbird;
in {
  options.excalibur.services.netbird = with types; {
    enable = mkBoolOpt false "Enable Netbird;";
    domain = mkOpt str "netbird.aiexcalibur.com" "Domain for Netbird to use";
  };

  config = mkIf cfg.enable {

    # services.netbird.server = {
    #   enable = true;
    #   domain = cfg.domain;
    #   enableNginx = true;
    #   coturn.enable = false;
    #   signal.logLevel = "INFO";
    #   # dashboard.settings = {
    #   #   AUTH_AUTHORITY = issuer;
    #   #   AUTH_CLIENT_ID = client-id;
    #   #   AUTH_SUPPORTED_SCOPES = scopes;
    #   # };
    #   management = {
    #     disableAnonymousMetrics = lib.mkForce true;
    #     logLevel = "INFO";
    #     dnsDomain = "netbird.lan";
    #     singleAccountModeDomain = "netbird.lan";
    #     oidcConfigEndpoint = "${issuer}/.well-known/openid-configuration";
    #
    #     turnDomain = config.services.coturn.realm;
    #     turnPort = config.services.coturn.listening-port;
    #     settings = {
    #       # DataStoreEncryptionKey._secret = store-key;
    #       DeviceAuthorizationFlow = {
    #         Provider = "hosted";
    #         ProviderConfig = {
    #           # Audience = client-id;
    #           # ClientID = client-id;
    #           # DeviceAuthEndpoint =
    #           #   "https://auth.ataraxiadev.com/application/o/device/";
    #           RedirectURLs = null;
    #           Scope = "openid";
    #           # TokenEndpoint =
    #           #   "https://auth.ataraxiadev.com/application/o/token/";
    #           UseIDToken = false;
    #         };
    #       };
    #       HttpConfig = {
    #         # AuthAudience = client-id;
    #         # AuthIssuer = "https://auth.ataraxiadev.com/application/o/netbird/";
    #         # AuthKeysLocation =
    #         #   "https://auth.ataraxiadev.com/application/o/netbird/jwks/";
    #         # AuthUserIDClaim = "";
    #         IdpSignKeyRefreshEnabled = false;
    #       };
    #       IdpManagerConfig = {
    #         ManagerType = "authentik";
    #         ClientConfig = {
    #           ClientID = client-id;
    #           GrantType = "client_credentials";
    #           # Issuer = "https://auth.ataraxiadev.com/application/o/netbird/";
    #           # TokenEndpoint =
    #           #   "https://auth.ataraxiadev.com/application/o/token/";
    #         };
    #         ExtraConfig = {
    #           # Password._secret = svc-pass;
    #           Username = "Netbird";
    #         };
    #       };
    #       PKCEAuthorizationFlow = {
    #         ProviderConfig = {
    #           # Audience = client-id;
    #           # AuthorizationEndpoint =
    #           #   "https://auth.ataraxiadev.com/application/o/authorize/";
    #           # ClientID = client-id;
    #           # Scope = scopes;
    #           # TokenEndpoint =
    #           #   "https://auth.ataraxiadev.com/application/o/token/";
    #           UseIDToken = false;
    #         };
    #       };
    #       TURNConfig = {
    #         Secret._secret = "TBD";
    #         TimeBasedCredentials = true;
    #         # Not used, supress nix warnind about world-readable password
    #         # Password._secret = config.sops.secrets.auth-secret.path;
    #       };
    #     };
    #   };
    # };

    # persist.state.directories = [ "/var/lib/netbird-mgmt" ];

  };
}
