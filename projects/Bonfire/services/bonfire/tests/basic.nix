{
  sources,
  ...
}:

{
  name = "Bonfire";

  nodes = {
    machine =
      { pkgs, lib, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.bonfire
          sources.examples.Bonfire."Enable bonfire"
        ];

        # Explanation: increased to avoid:
        # Kernel panic - not syncing: Out of memory
        # as soon as running the initial migration of the PostgreSQL schema.
        # ToDo(perf/resource/mem): see if it still works with less.
        virtualisation.memorySize = 4096;

        environment.systemPackages =
          let
            user = "admin";
            domain = "localhost.localdomain";
            url = "http://${domain}";
            email = "${user}@${domain}";
            password = "0123456789";
            selenium-test =
              pkgs.writers.writePython3Bin "selenium-test"
                {
                  libraries = with pkgs.python3Packages; [ selenium ];
                  flakeIgnore = [
                    "E501" # line too long
                  ];
                }
                ''
                  from selenium import webdriver
                  from selenium.webdriver.common.by import By
                  from selenium.webdriver.firefox.options import Options
                  from selenium.webdriver.support.ui import WebDriverWait
                  from selenium.webdriver.support import expected_conditions as EC


                  def log(msg):
                      from sys import stderr
                      print(f"[*] {msg}", file=stderr)


                  log("Initializing")

                  options = Options()
                  options.add_argument("--headless")

                  service = webdriver.FirefoxService(executable_path="${lib.getExe pkgs.geckodriver}")  # noqa: E501
                  driver = webdriver.Firefox(options=options, service=service)

                  driver.implicitly_wait(10)

                  log("Opening sign up page")
                  driver.get("${url}/signup")


                  def wait_elem(by, query, timeout=10):
                      wait = WebDriverWait(driver, timeout)
                      wait.until(EC.presence_of_element_located((by, query)))


                  def wait_title_contains(title, timeout=10):
                      wait = WebDriverWait(driver, timeout)
                      wait.until(EC.title_contains(title))


                  def find_element(by, query):
                      return driver.find_element(by, query)


                  def set_value(elem, value):
                      script = 'arguments[0].value = arguments[1]'
                      return driver.execute_script(script, elem, value)


                  log("Waiting for the sign up page to load")

                  wait_title_contains("Sign up")
                  wait_elem(By.CSS_SELECTOR, 'input#signup-form_email_0_email_address')

                  log("Sign up page loaded!")

                  log("Filling out email")
                  login_input = find_element(By.CSS_SELECTOR, 'input#signup-form_email_0_email_address')
                  set_value(login_input, "${email}")

                  log("Filling out password")
                  password_input = find_element(By.CSS_SELECTOR, 'input#signup-form_credential_0_password')
                  set_value(password_input, "${password}")
                  password_input = find_element(By.CSS_SELECTOR, 'input#signup-form_credential_0_password_confirmation')
                  set_value(password_input, "${password}")

                  log("Submitting credentials for login")
                  driver.find_element(By.CSS_SELECTOR, 'button[data-role=signup_submit]').click()

                  log("Waiting user creation page")
                  wait_title_contains("Create a new user profile")

                  driver.close()
                '';
          in
          [
            pkgs.firefox-unwrapped
            pkgs.geckodriver
            selenium-test
          ];

      };
  };

  interactive = {
    # HowTo(maint/debug):
    # nix -L shell .#checks.x86_64-linux.projects/Bonfire/nixos/tests/basic.driverInteractive -c nixos-test-driver
    # python> start_all()
    # ssh -o User=root vsock/3
    sshBackdoor.enable = true;

    nodes.machine =
      { pkgs, ... }:
      {
        networking.firewall.allowedTCPPorts = [ 80 ];
        virtualisation.forwardPorts = [
          # HowTo(maint/debug):
          # nix -L shell .#checks.x86_64-linux.projects/Bonfire/nixos/tests/basic.driverInteractive -c nixos-test-driver
          # python> start_all()
          # firefox http://localhost:4000
          {
            from = "host";
            host.port = 4000;
            guest.port = 80;
          }
        ];

      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("postgresql.target")
      machine.wait_for_unit("nginx.service")
      machine.wait_for_unit("bonfire.service")

      machine.wait_for_open_port(${toString nodes.machine.config.services.bonfire.settings.PUBLIC_PORT})
      machine.wait_for_open_port(${toString nodes.machine.config.services.bonfire.settings.SERVER_PORT})

      machine.succeed("PYTHONUNBUFFERED=1 selenium-test")
    '';
}
