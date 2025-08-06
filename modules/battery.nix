{
  hostname,
  config,
  ...
}: {
  services.upower = {
    # TODO only true in laptops
    enable = true;
  };
}
