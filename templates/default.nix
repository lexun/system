{
  flake.templates = {
    livebook = {
      path = ./livebook;
      description = "Provides a development environment for Livebook";
    };
    phoenix = {
      path = ./phoenix;
      description = "Provides a development environment for Phoenix projects";
      welcomeText = ''
        # The dev command must be allowed to execute

        ```sh
          chmod +x scripts/bin/dev
        ```

        # Merge .gitignore files or run the following command if there is a conflict

        ```sh
          echo -e "\n# Dev environment local state\n/.devenv/\n/.direnv/\n/.local/" >> .gitignore
        ```
      '';
    };
  };
}
