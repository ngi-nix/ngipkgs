# Terms

1. Good documentation (installation/building)
2. Continuous Delivery
3. 


# Project Acceptance Criteria for Nix Packages

This document outlines the criteria for accepting open-source projects into our Nix packaging repository. Adhering to these criteria ensures that the projects we support are of high quality, maintainable, and provide a good user experience.

## Criteria for Acceptance

### 1. Open Source License
The project must be released under an open-source license that is [recognized by the Open Source Initiative (OSI)](https://opensource.org/licenses). Examples include MIT, Apache 2.0, GPL, and BSD licenses.

### 2. Active Maintenance
Unless the project is finished it must show evidence of active development/maintenance. This can be demonstrated through recent commits, regular updates, and timely issue resolution.

### 3. Documentation
The project must have comprehensive and clear documentation. This includes:
- A README file that provides an overview of the project, installation instructions, and usage examples.
- Documentation for the API, configuration options, and other relevant details.

- Proper use of version control.

### 4. Continuous Delivery
The project must implement Continuous Delivery (CD) to ensure that it can be reliably released at any time. This involves:
- **Automated Build and Deployment**: The project should have automated processes for building and deploying the software.
- **Frequent Releases**: The project should be set up to release new versions frequently and consistently.
- **Automated Testing**: The CD pipeline should include automated tests to ensure that new changes do not introduce regressions or break existing functionality.
- **Monitoring and Rollback**: There should be mechanisms in place for monitoring the deployment and rolling back changes if issues are detected.

### 7. Community Engagement
The project should have an active and engaged community. This can be demonstrated through:
- Active discussion forums or mailing lists.
- Responsive maintainers who address issues and pull requests in a timely manner.
- A welcoming environment for new contributors.

### 8. Compatibility
The project should be compatible with the Nix ecosystem. This includes:
- Providing a `default.nix` file or similar for easy integration.
- Ensuring that all dependencies are also available as Nix packages or can be packaged.

### 9. Performance
The project should have acceptable performance characteristics. This includes:
- Efficient use of resources.
- Scalability to handle expected workloads.

### 10. Compliance
The project must comply with all relevant legal and regulatory requirements. This includes:
- Ensuring that all dependencies are properly licensed.
- Following data protection and privacy regulations where applicable.

## Submission Process

To submit a project for consideration, please open an issue in our repository with the following information:
- Project name and description.
- Link to the project repository.
- License information.
- Evidence of active maintenance.
- Documentation links.
- Details on continuous delivery implementation.
- Community engagement links.

Our team will review the submission and provide feedback or acceptance within a reasonable timeframe.

## Conclusion

By adhering to these criteria, we aim to ensure that the projects included in our Nix packaging repository are reliable, maintainable, and provide value to our users. Thank you for your contributions to the open-source community.

