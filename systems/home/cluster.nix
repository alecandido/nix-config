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
			((import ../../home) { inherit user; })  
			{ 
				home.homeDirectory = home ; 
				_module.args = { inherit user home inputs; };
			}
        		{ nixpkgs = nixpkgsOv [ ]; }
		];

	});
}
