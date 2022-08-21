{
  description = "A template that shows all standard flake outputs";

  # Inputs
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs
  inputs = {
    nixpkgs.url = "nixpkgs";
    papermod = {
        type = "github";
        owner = "adityatelange";
        repo = "hugo-PaperMod";
        flake = false;
    };
  };

  outputs = all@{ self, nixpkgs, papermod }: {

    # Utilized by `nix flake check`
    # checks.x86_64-linux.test = c-hello.checks.x86_64-linux.test;

    # Utilized by `nix build .`
    # defaultPackage.x86_64-linux = c-hello.defaultPackage.x86_64-linux;

    # Utilized by `nix build`
    packages.x86_64-linux.hugo = with nixpkgs.legacyPackages.x86_64-linux; stdenvNoCC.mkDerivation {
        name = "hugo-wrapped";
        version = hugo.version;

        nativeBuildInputs = [ makeWrapper ];

        phases = [ "buildPhase" ];

        buildPhase = ''
            mkdir -p $out/bin
            makeWrapper "${hugo}/bin/hugo" $out/bin/hugo --run "[ -f "flake.nix" ] && mkdir -p themes && rm -f themes/papermod && ln -f -s ${papermod} themes/papermod";
        '';
    };

    apps.x86_64-linux.default = self.apps.x86_64-linux.hugo;

    # Utilized by `nix run .#<name>`
    apps.x86_64-linux.hugo = {
      type = "app";
      program = "${self.packages.x86_64-linux.hugo}/bin/hugo";
    };

    # Utilized by `nix develop`
    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
        buildInputs = [
            self.packages.x86_64-linux.hugo
        ];
    };

    # Utilized by Hydra build jobs
    hydraJobs.example.x86_64-linux = self.defaultPackage.x86_64-linux;
  };
}
