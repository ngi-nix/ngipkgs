from enum import Enum


class URL(str):
    pass


class Deliverable(str, Enum):
    class Test(Enum):
        pass

    class Libraries(Enum):
        documentation = ""
        examples_usage = ""

    class Services(Enum):
        documentation = ""
        examples_usage = ""
        tests = list[str]

    class Programs(Enum):
        class Documentation(Enum):
            web = ""
            manpage = ""
            cli_output = ""

        documentation = Documentation
        examples_usage = ""
        tests = list[str]

    class DevelopmentEnv(Enum):
        class ProgrammingLanguage(Enum):
            dependency_management = ""
            frameworks = ""

        class BuildSystem:
            makefiles = list[str]

        class ContinuousIntegration(Enum):
            automatic_dependency_updates = ""

        class ContinuousDeployment(Enum):
            class Artefacts(Enum):
                docker_files = list[str]
                deb_files = list[str]
                nix_files = list[str]
                binaries = list[str]

            documentation_workflow = ""
            artefacts = Artefacts

        programming_languages = list[ProgrammingLanguage]
        documentation = list[URL]
        continuous_integration = ContinuousIntegration
        continuous_deployment = ContinuousDeployment

    services = Services
    executables = Programs
    libraries = Libraries
    tests = list[Test]
    development_environment = DevelopmentEnv
    plugins = "plugins"
