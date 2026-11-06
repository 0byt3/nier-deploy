; extends

; nvim-treesitter marks builtin command heads as @function.builtin (aqua).
; Helix colours every command name as @function, including user defs like
; `installed-pacman-neovim-packages` and builtins like `http`.
(command
    head: [
        (cmd_identifier) @function
        (#any-of? @function
            "all" "ansi" "any" "append" "ast" "bits" "bytes" "cal" "cd" "char" "chunk-by" "chunks"
            "clear" "collect" "columns" "compact" "complete" "config" "cp" "date" "debug" "decode"
            "default" "detect" "drop" "du" "each" "encode" "enumerate" "every" "exec" "exit"
            "explain" "explore" "fill" "filter" "find" "first" "flatten" "format" "from" "generate"
            "get" "glob" "grid" "group-by" "hash" "headers" "histogram" "history" "http" "input"
            "insert" "inspect" "interleave" "into" "is-empty" "is-not-empty" "is-terminal" "items"
            "job" "join" "keybindings" "kill" "last" "length" "let-env" "lines" "load-env" "ls"
            "math" "merge" "metadata" "mkdir" "mktemp" "move" "mv" "nu-check" "nu-highlight" "open"
            "panic" "par-each" "parse" "path" "plugin" "port" "prepend" "print" "ps" "query"
            "random" "reduce" "reject" "rename" "reverse" "rm" "roll" "rotate" "run-external"
            "save" "schema" "select" "seq" "shuffle" "skip" "sleep" "slice" "sort" "sort-by"
            "split" "start" "stor" "str" "sys" "table" "take" "tee" "term" "timeit" "to" "touch"
            "transpose" "tutor" "ulimit" "uname" "uniq" "uniq-by" "update" "upsert" "url" "values"
            "version" "view" "watch" "which" "whoami" "window" "with-env" "wrap" "zip")
    ]
    (#set! "priority" 110))

; Multi-word commands like `http get` parse the subcommand as a string.
; Recolour the first argument of known command families as a function.
(command
    head: (cmd_identifier) @_command @function
    .
    arg_str: (val_string) @function
    (#any-of? @_command
        "abbr" "ansi" "attr" "bits" "bytes" "commandline" "config" "date"
        "debug" "decode" "detect" "dns" "drop" "each" "encode" "error"
        "explore" "export" "format" "from" "hash" "help" "history" "http"
        "idx" "input" "into" "job" "keybindings" "math" "matrix" "merge"
        "metadata" "overlay" "path" "plugin" "query" "random" "roll" "scope"
        "semver" "seq" "skip" "split" "stor" "str" "sys" "take" "term" "to"
        "update" "url" "version" "view")
    (#set! "priority" 110))
