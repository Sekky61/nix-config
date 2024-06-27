#!/bin/bash
# Assumes $PWD dotfiles

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
ldconfig # not sure if necessary, load program names used later in script

source $HOME/.cargo/env

# TODO
echo "Rust: add these lines to ~/.cargo/config.toml
[target.x86_64-unknown-linux-gnu]
linker = \"clang\"
rustflags = [\"-C\", \"link-arg=-fuse-ld=/path/to/mold\"]
"

rustup component add clippy
cargo install cargo-expand
cargo install cargo-watch
cargo install cleanall
