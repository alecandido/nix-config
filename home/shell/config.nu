let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

let zoxide_completer = {|spans: list<string>|
    $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
    | if ($in | is-not-empty) { $in } else { null }
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
        # use zoxide completions for zoxide commands
        __zoxide_z | __zoxide_zi => $zoxide_completer
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
