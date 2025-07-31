{
  services.peertube-runner = {
    enable = true;
    instancesToRegister = {
      # All instances must be registered here. They can't be registered using the CLI.
      # personal = {
      #   url = "https://mypeertubeinstance.com";
      #   # See how to generate registration tokens at https://docs.joinpeertube.org/admin/remote-runners#manage-remote-runners.
      #   registrationTokenFile = "/run/secrets/my-peertube-instance-registration-token";
      #   runnerName = "Main";
      # };
    };
  };
}
