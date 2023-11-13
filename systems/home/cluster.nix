{ darwin
, home-manager
, nixpkgs
, ...
} @ inputs:
let 
	nixpkgsOv = (import ../../overlays_) inputs;
in
{
	lxplus = home-manager.lib.homeManagerConfiguration (let
			user = "candidal";
			home = "/afs/cern.ch/user/c/candidal";
		in
	{
		pkgs = nixpkgs.legacyPackages."x86_64-linux";
		modules = [ 
			./home.nix
			# ((import ../../home) { inherit user; })  
			{ 
				home.homeDirectory = home ; 
				home.shellAliases.upgrade = ''
      home-manager switch --flake "$XDG_CONFIG_HOME/nixpkgs#lxplus" --show-trace
    '';
				_module.args = { inherit user home inputs; };
			}
        		{ nixpkgs = nixpkgsOv [ ]; }
		];

	});
}
