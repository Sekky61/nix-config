# Careful about copy/pasting, Makefiles want tabs!
# But you're not copy/pasting, are you?
.PHONY: update
update:
	home-manager switch --flake .#michal@michalyoga

.PHONY: system
system:
	nixos-rebuild switch --flake .#michalyoga

.PHONY: clean
clean:
	nix-collect-garbage  --delete-old

