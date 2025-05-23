let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

# This completer will use carapace by default
let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -i 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        _ => $carapace_completer
    } | do $in $spans
}

$env.config = {
    completions: {
        external: {
            enable: true
            completer: $external_completer
        }
    }
    edit_mode: vi
}

export def pypath [
    version: string,
    --external: list<string> = ["pre-commit", "poethepoet"]
]: nothing -> string {
    let retain = [$"python(version)"] ++ $external

    $env.PYTHONPATH | split row ":"
                    | filter {$in =~ ($retain | str join "|")}
                    | str join ":"
}


# TODO: explicitly activate until the zoxide nushell init patch will be available
source ~/.cache/zoxide/init.nu
