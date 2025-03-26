# OWASP Triage Report for NGIpkgs
# 1. Brief Introduction
The Open Web Application Security Project, recently renamed to the Open Worldwide Application Security Project [OWASP](https://owasp.org/about/) is a non-profit organization that works to improve the security of software. 

Security professionals all around the world use this globally open platform to share information, events, tools, and collaborate to ensure the security of the web.

## Official Sources

| Source       | URL                                      |
|--------------|------------------------------------------|
| Website      | [https://owasp.org](https://owasp.org)   |
| GitHub       | [https://github.com/OWASP](https://github.com/OWASP) |

# 2. **Framework and Dependency Management Tools**

 ## **Relevant OWASP project related to packaging includes**

[OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/) - A tool that detects vulnerable dependencies in software projects. 

[OWASP Dependency-Track](https://owasp.org/www-project-dependency-track/) - A software supply chain risk analysis tool.

[OWASP CycloneDX](https://owasp.org/www-project-cyclonedx/) - Software Bill Of Materials standard used to document all components in a software package.

[OWASP SCVS](https://owasp.org/www-project-software-component-verification-standard/) -A standard that provides guidelines for verifying the integrity and security of software components.

OWASP tools rely on different `frameworks` and `dependency management tools` based on their technology stack
| OWASP Tool             | Framework | Dependency Management Tools |
|------------------------|------------------|----------------------------|
| **Dependency-Check**   |Java  | Gradle, Maven |
| **Dependency-Track**  | Java | Maven |
| **CycloneDX**  | Java, Python, JS, Go | Maven, Gradle, pip, npm, Go Modules |
| **SCVS** | Python | Pip |

## **Existing Package Availability** 

| Package Name         | Nixpkgs        | Debian (APT)       | Arch (AUR)       | PyPI              | Homebrew         |
|----------------------|---------------|--------------------|------------------|------------------|------------------|
| **OWASP ZAP**       | ❌ Not found   | ✅ `owasp-zap`     | ✅ `owasp-zap`   | ✅ `owasp-zap`   | ✅ `owasp-zap`   |
| **Dependency-Check** | ❌ Not found   | ✅ `dependency-check` | ✅ `dependency-check` | ✅ `dependency-check` | ✅ `dependency-check` |
| **Dependency-Track** | ❌ Not found   | ❌ Not found       | ❌ Not found     | ❌ Not found     | ❌ Not found     |

## The Usage of Nix in OWASP Projects  

**Some OWASP repositories demonstrate the use of Nix for development and dependency management. For example:**  

- [www-project-machine-learning-security-top-10](https://github.com/OWASP/www-project-machine-learning-security-top-10):  
  - Contains a `flake.nix` file, indicating the use of Nix Flakes.  
  - Includes a `gemset.nix` file to manage Ruby dependencies, with a configuration that references a `Gemfile` and `Gemfile.lock`.  

- [AppSec-Browser-Bundle](https://github.com/OWASP/AppSec-Browser-Bundle) and [www-project-application-security-verification-standard]()https://github.com/OWASP/www-project-application-security-verification-standard:  
  - Includes various Nix files and configurations that indicates the adoption of Nix in certain aspects of their development workflows.

- This simply means **some OWASP projects already have Nix-based development environments**, which could further help in Nix packaging efforts

# 3. **Building OWASP Tools from Source in Nix** 

## **Challenges in Nix-based Packaging**  
A. **Java Dependencies**  
   - Many OWASP tools (e.g., **ZAP, Dependency-Check, Dependency-Track**) are **Java-based** and rely on **Maven** or **Gradle** for dependency management.  
   - **Issue**: Nix does not handle Maven's dependency resolution  outrightly, which requires `fetchMavenDeps` to package the dependencies manually.  

B. **Python & Ruby Dependencies**  
   - Some tools (like **CycloneDX Python & Ruby implementations**) use `pip` and `bundler`.  
   - **Solution**: Use `buildPythonPackage` and `bundlerEnv` in Nix expressions for clean dependency management.  

C. **Licensing Restrictions**  
   - Before adding a package to **Nixpkgs**, it’s **critical** to ensure license compatibility.  
   - **Example**: OWASP Dependency-Check relies on some third-party vulnerability feeds that have restrictive licensing.  
   - **Solution**: Clearly mark packages with `meta.license = licenses.unfree;` if necessary.  


# 4. **Recommendations & Next Steps for Packaging OWASP Tools in Nixpkgs**

A. **Community Contributions Needed** 
- Most OWASP tools are **not in Nixpkgs yet**. Community efforts can help package them properly by contributing derivations and improving compatibility.  

B.  **Use Overlays for Proprietary Dependencies**  
- Some tools (like **Dependency-Check**) pull data from sources requiring a **terms-of-use agreement**. Instead of including them directly in `pkgs/main`, using an **overlay** would provide more flexibility while respecting licensing restrictions.  

C. **Improve Java & Maven Support in Nix**  
- The current Nix support for **Java-based tools** is **limited**. Enhancing `fetchMavenDeps` workflows could **simplify Java package management**, making it easier to package OWASP tools that rely on **Maven** or **Gradle**.  

D. **Create a Flake for OWASP Security Tools**  
- A **dedicated Nix flake** for OWASP tools would improve integration, ensure **reproducible builds**, and make it easier for developers to use security tools in Nix environments.  


# 5. **References**  

## **Official OWASP Sources**  
- **OWASP Website:** [https://owasp.org](https://owasp.org)  
- **OWASP GitHub Repository:** [https://github.com/OWASP](https://github.com/OWASP)  
- **OWASP Projects Page:** [https://owasp.org/projects/](https://owasp.org/projects/)  

## **OWASP Tools & Standards**  
- **OWASP Dependency-Check:** [https://github.com/jeremylong/DependencyCheck](https://github.com/jeremylong/DependencyCheck)  
- **OWASP Dependency-Track:** [https://github.com/DependencyTrack/dependency-track](https://github.com/DependencyTrack/dependency-track)  
- **OWASP CycloneDX (SBOM Standard):** [https://github.com/CycloneDX](https://github.com/CycloneDX)  
- **OWASP SCVS (Software Component Verification Standard):** [https://github.com/OWASP/SCVS](https://github.com/OWASP/SCVS)  

## **Nix/Nixpkgs Resources**  
- **Nixpkgs Repository:** [https://github.com/NixOS/nixpkgs](https://github.com/NixOS/nixpkgs)  
- **Nixpkgs Contribution Guide:** [https://nixos.org/manual/nixpkgs/stable/](https://nixos.org/manual/nixpkgs/stable/)  
- **Nix Flakes Overview:** [https://nixos.wiki/wiki/Flakes](https://nixos.wiki/wiki/Flakes)  





