{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: 
      let pkgs = nixpkgs.legacyPackages.${system}; in {
      packages.default = pkgs.buildDotnetModule {
        pname = "voxel-thing";
        version = "0.1.0";
        src = ./.;

        meta = with pkgs.lib; {
          description = "A work-in-progress clone of a really popular block game, now in C#!";
          homepage = "https://github.com/BlueStaggo/VoxelThing";
          license = licenses.mit;
          platforms = platforms.linux;
          mainProgram = "voxel-thing";
        };

        projectFile = "VoxelThing.Client/VoxelThing.Client.csproj";
        nugetDeps = ./deps.json;

        runtimeDeps = with pkgs; [
          libGL
          xorg.libX11
          wayland
        ];

        # wrapper script to set correct working directory for assets
        postFixup = ''
          mv $out/bin/VoxelThing.Client $out/bin/.VoxelThing.Client-unwrapped
          cat > $out/bin/voxel-thing << EOF
          #!/bin/sh
          cd $out/lib/voxel-thing
          exec $out/bin/.VoxelThing.Client-unwrapped "\$@"
          EOF
          chmod +x $out/bin/voxel-thing
        '';
      };
    });
}
