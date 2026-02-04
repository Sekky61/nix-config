# Plans for Generating Documentation for Custom Nix Flake Options

Your goal is to extract all custom options under the michal namespace from your NixOS/Home Manager flake and produce a documentation data (e.g. JSON or table of options with descriptions). Below are multiple approach specifications to implement this, increasing the chances that one will work:

## Approach 1: Evaluate Flake Modules with Nix and Generate JSON Docs

Leverage Nix’s module evaluation and built-in documentation generation:

Collect Your Modules: Identify all Nix module files that define options.michal.*. This likely includes every file under your flake’s modules/ (and possibly homes/ or hosts/) directory where you declare custom options. You can gather these file paths (manually or by globbing modules/**/*.nix). These will be passed to Nix for evaluation.

Use lib.evalModules: Write a Nix expression to evaluate just your modules’ option definitions. For example, create a temporary generate-docs.nix with the following structure:

{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib }:
let 
  # Evaluate modules (with check disabled to ignore undefined config parts)
  eval = lib.evalModules {
    modules = [
      ./modules/audio.nix
      ./modules/bitwarden.nix
      ./modules/borg.nix
      … (all other module files)
    ];
    check = false;  # allow missing base definitions:contentReference[oaicite:0]{index=0}
  }; 
  optionsSet = eval.options;
  docs = pkgs.nixosOptionsDoc { inherit optionsSet; };
in docs


Here, eval.options is the attrset of all option declarations from your modules. We pass that into pkgs.nixosOptionsDoc, which traverses all option definitions, extracting their names, types, defaults, and descriptions.

Setting check = false in evalModules (or adding _module.check = false in one module) prevents evaluation errors from missing upstream options, as noted in documentation. This is important if your modules reference NixOS/HM config that isn’t included in this standalone eval.

Generate Documentation Outputs: The nixosOptionsDoc function produces multiple formatted outputs of the options documentation. For example, it provides an option JSON and markdown/HTML docs:

Access the JSON output via docs.optionsJSON (or similar attribute). This is a path to a JSON file containing all options and their metadata.

Alternatively, use CommonMark/Markdown output via docs.optionsCommonMark for human-readable docs. You can choose JSON since you want a machine-usable spec.

Tip: The JSON will list each option (likely fully qualified like "michal.programs.borg.enable") with fields for description, type, default, example, etc., similar to NixOS’s options.json format.

Build or Eval to Get JSON: Invoke Nix to produce the docs. For example:

Using Nix flakes: add an output in your flake.nix like:

outputs = { self, nixpkgs, ... }: {
  packages.docsOptions = pkgs.callPackage ./generate-docs.nix {};
};


Then run nix build .#docsOptions.optionsJSON to build the JSON doc file. The result JSON (e.g. result/share/doc/nixos/options.json) will contain your custom options.

Or run a one-off command:

nix-build generate-docs.nix -A optionsJSON


if you adapt generate-docs.nix to output a derivation. For example, wrap it with runCommand to copy the JSON to $out.

Verify and Filter: The resulting JSON will include all options from the evaluated modules. Since you only included your custom modules (and used check=false to skip unmet references), it should primarily contain the michal.* options. If any extraneous or internal options (like _module attributes) appear, filter them out in post-processing or adjust the eval to exclude them. You can then use jq or similar to pretty-print or further process the JSON as needed.

References: This approach uses Nixpkgs’s built-in docs generator (pkgs.nixosOptionsDoc), which “traverses all those options declarations in your modules, extracts the names and descriptions and so on … and spits them out in a variety of different formats.” It’s the same mechanism that builds the NixOS manual and options search. By evaluating your modules with evalModules and feeding the options into nixosOptionsDoc, you can produce a JSON listing of your custom options (much like the official options.json). For example, a similar method is used to generate the full NixOS options JSON in the NixOS release expressions. If any evaluation issues arise from missing base module definitions, the check = false flag (or _module.check = false) will bypass those checks, allowing docs generation for just your modules.

## Approach 2: Static Code Analysis of Nix Files (Regex/Parsing)

As a fallback, you can directly parse your flake’s source code to find option definitions, which avoids needing to fully evaluate the Nix modules. This method is less robust (it won’t catch dynamically constructed options or evaluate conditional logic), but it can quickly gather straightforward option declarations:

Search for Option Declarations: Recursively scan all .nix files in your config for the pattern options.michal. This identifies lines where you define your custom options. For example, lines like options.michal.audio = { ... }; or options.michal.programs.borg = { ... }; will mark the start of an options set. Use tools like grep -R "options.michal" . to get candidate files and lines.

Parse Option Blocks: For each occurrence, parse the Nix set that defines the options:

Once you find a line like options.michal.foo = { ... };, you need to capture its contents until the matching closing brace }. This block may span multiple lines. One approach is to use a simple parser or bracket matching: read the file, find the { after the options.michal.foo =, and extract all text until its corresponding } (taking into account nested braces).

Within this block, each attribute defined is a sub-option. For example, if you have:

options.michal.audio = {
  enable = mkEnableOption "audio subsystem (PipeWire + utilities)";
  guiTools = mkOption {
    type = types.bool;
    default = true;
    description = "Install GUI audio tools (pavucontrol, qpwgraph, helvum)";
  };
};


you should record two options: michal.audio.enable with description “audio subsystem (PipeWire + utilities)”, and michal.audio.guiTools with description “Install GUI audio tools (pavucontrol, …)”, as well as type = boolean and default = true.

Extract Metadata: Identify the components of each option:

If an option uses mkEnableOption "Description" syntax, this implies a boolean option with default = false (unless otherwise specified) and the given description. Capture the string inside mkEnableOption as the description. (You can infer type=bool and default=false for these).

If an option uses a full mkOption { ... } declaration, parse the attributes inside. Look for a description = "..."; field, a type = ...; field, and possibly default = ...; or example = ...;. Extract these values. Be careful to handle Nix strings (they may span multiple lines or use escape sequences) – a regex like description\s*=\s*\"([^\"]*)\" can work for simple cases.

There might be nested option sets (though less likely in your custom namespace). If an option’s value is an attrset with more sub-keys (not a primitive type), you may treat those sub-keys as separate options (joining the names with dots).

Aggregate Results: Build a data structure (e.g. a Python dict or similar) of all found options. Each key is the full option name (like "michal.programs.borg.common-exclude-patterns") and the value is an object with fields such as description, type, and default. For consistency, you can mimic the format of NixOS’s options.json (keys for description, type, default, example, etc.). If certain metadata are not easily parsed (e.g. complex types or functions as default), you can leave them blank or as a string note.

Output as JSON: Finally, serialize this options mapping to JSON. This gives you a machine-readable file to further manipulate or inspect. For example, an entry in the JSON might look like:

{
  "michal.programs.borg.enable": {
    "type": "boolean",
    "default": false,
    "description": "borg backups to borgbase"
  },
  "michal.programs.borg.common-exclude-patterns": {
    "type": "list of strings",
    "default": [ "...patterns..." ],
    "description": "(list of default exclude patterns...)"
  },
  ...
}


(Based on your module, borg’s enable description is “borg backups to borgbase”, and common-exclude-patterns is a list of strings with a long default list defined in the module.)

Verify Coverage: Compare the gathered options against your code to ensure all options.michal.* are captured. This method should find straightforward definitions. However, be aware it might miss options defined in a more dynamic way (e.g. if your code constructs option names programmatically or uses abstractions). Given your config style (explicit options.michal.foo = blocks), this likely isn’t an issue.

Notes: This static approach does not actually run Nix, so it won’t resolve computed defaults or conditionals. It’s essentially a pattern-matching solution. It’s simpler but fragile; if your modules become more complex (e.g. using functions to define options or conditional option declarations), a pure text scrape might fail. Nonetheless, it’s a quick way to get a JSON of option names and descriptions. You could improve robustness by using an AST parser (see Approach 3) rather than regex, but regex with careful parsing can handle common cases.

## Approach 3: Use a Dedicated Tool or AST Parsing for Nix Options

There are tools and libraries specifically designed to extract module option documentation. You can leverage these for a potentially easier or more robust solution:

nix-options-doc (Rust CLI): A community tool called nix-options-doc can generate documentation for Nix modules in various formats (JSON, Markdown, HTML, CSV). This tool parses your Nix files using the Nix AST, which means it can handle interpolation and complex expressions more reliably than naive text search. To use it:

Install nix-options-doc (e.g. via nix profile install github:Thunderbottom/nix-options-doc, or use the provided flake if available).

Run it pointed at your flake directory or specific module path. For example:

nix-options-doc --path . --format json --out options.json

This should scan all Nix files in the current directory (your flake) for options definitions and produce options.json with all options (including your michal.* namespace) documented.

You can adjust scope and output: e.g., --path ./modules --format json to focus on the modules folder, and omit external modules. The tool also supports filtering out certain directories (like tests or templates) if needed.

The result JSON will contain each option with its description, type, default, and source location. This is very close to what you want, with minimal effort on your side.

AST Parsing in a Script: If you prefer not to use a pre-built binary, you could implement a similar logic in a script using a Nix parsing library:

The Rust rnix-parser (used by nix-options-doc) can be utilized via Rust or perhaps via Python bindings (if any exist) to parse Nix files into an AST and walk it. This would let you programmatically find options attributes and read their sub-nodes for descriptions/types.

A lighter approach: use nix-instantiate --eval --json with some clever expression to read option definitions. However, because option definitions are not normal values but rather module declarations, direct instantiation is tricky. Sticking to a true parser or the nix-options-doc tool is more straightforward for a custom script scenario.

Home Manager / JSON Schema Consideration: If some of your michal options are for Home Manager modules, note that Home Manager uses a similar module system. Home Manager’s manual can also produce an options.json (if enabled). There’s also a NixOS to JSON Schema converter project which extracts options into a schema (useful for generating forms or validating inputs). Such tools indicate it’s feasible to programmatically get a machine-readable spec of options. You might not need these specifically, but they highlight that generating a structured options list is a solved problem in the Nix ecosystem.

Run and Validate: Whichever tool or library you use, run it on your flake and inspect the output. Ensure that all michal... options appear with correct descriptions and default values. For instance, you should see entries like "michal.programs.walker.enable" with description "walker application launcher" (from your example module) and default false, etc. Because the AST-based tool evaluates the code structure, it will catch these even if they were composed or conditional in the source.

This approach abstracts away a lot of the manual work. The nix-options-doc utility in particular was created to generate docs for custom flakes and modules easily, similar to how NixOS and Home Manager document their options. It “walks through the AST of your Nix files, extracting option definitions and their metadata”. Using it (or a similar AST parsing method) can save time and handle edge cases, producing a JSON or Markdown reference of your options with minimal fuss.
