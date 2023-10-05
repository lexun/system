{
  flake.templates = {
    livebook = {
      path = ./livebook;
      description = "Provides a development environment for Livebook";
    };
    phoenix = {
      path = ./phoenix;
      description = "Provides a development environment for Phoenix projects";
    };
  };
}
