{...}: {
  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
  };
}
