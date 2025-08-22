{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages.default = nixpkgs.legacyPackages.${system}.buildDotnetModule {
        pname = "voxel-thing";
        version = "0.1.0";
        src = ./.;

        projectFile = "VoxelThing.Client/VoxelThing.Client.csproj";
        nugetDeps = ./deps.json;

        runtimeDeps = with nixpkgs.legacyPackages.${system}; [
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
