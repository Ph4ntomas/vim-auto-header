function s:AutoHeader_getShebang(ftype)
    let l:shebang_map = {
        \ "c":      0,
        \ "cpp":    0,
        \ "css":    0,
        \ "java":   0,
        \ "php":    "/usr/bin/env php <?php",
        \ "make":   0,
        \ "text":   0,
        \ "sh":     "/bin/sh\n",
        \ "ruby":   "/usr/bin/env ruby",
        \ "perl":   "/usr/bin/env perl",
        \ "ocaml":  "/usr/bin/env ocaml",
        \ "python": "/usr/bin/env python",
        \ "vim":    0,
        \ "tex":    0,
        \ "lisp":   0,
        \ "lex":    0,
        \ "pascal": 0,
        \ "haskell": 0,
    \ }

    return has_key(l:shebang_map, a:ftype) ? l:shebang_map[a:ftype] : 0
endfunction

function s:AutoHeader_getComment(ftype)
    let l:comment_map = {
        \ "c":      0,
        \ "cpp":    0,
        \ "css":    0,
        \ "java":   0,
        \ "php":    0,
        \ "make":   1,
        \ "text":   1,
        \ "sh":     1,
        \ "ruby":   1,
        \ "perl":   1,
        \ "ocaml":  2,
        \ "python": 1,
        \ "vim":    3,
        \ "tex":    4,
        \ "lisp":   5,
        \ "lex":    6,
        \ "pascal": 7,
        \ "haskell": 8,
    \ }

    let l:comment_arr = [
        \ ["/\*\*", "\*\*", "\*/"],
        \ ["###", "##", "##"],
        \ ["\(\*\*", "\*\*", "\*\)"],
        \ ["\"\"\"", "\"\"", "\"\""],
        \ ["\%%%", "%%", "\%%"],
        \ [";;;", ";;", ";;"],
        \ ["%{\n\*\*\*", "\*\*", "\*\*\n%}"],
        \ ["{", "\..", "}"],
        \ ["{-|", "---" , "|-}"]
    \ ]

    return has_key(l:comment_map, a:ftype) ? l:comment_arr[l:comment_map[a:ftype]] : []
endfunction

function! AutoHeader_create()
    if &ft == ""
        return
    endif

    let l:c_username = substitute(system("git config --get user.name"), "\n", "", "")
    let l:c_mail     = substitute(system("git config --get user.email"), "\n", "", "")

    let l:l_file = "\\file " . expand("%:t")
    let l:l_author = "\\author " . l:c_username . " <" . l:c_mail . ">"
    let l:l_cdate = "\\date Created on: " . strftime("%Y-%m-%d %H:%M")
    let l:l_update = "\\date Last update: " . strftime("%Y-%m-%d %H:%M")

    let l:comments = s:AutoHeader_getComment(&ft)
    let l:shebang = s:AutoHeader_getShebang(&ft)

    let l:s_fmt = &fo
    let l:s_autoindent = &autoindent
    let l:s_smartindent = &smartindent
    let l:s_cindent = &cindent

    setl noautoindent nosmartindent nocindent
    setl fo-=c fo-=r fo-=o

    if l:comments == 0
        return
    endif

    execute "normal! gg"

    if l:shebang != "0"
        execute "normal! O#!" . l:shebang
    endif

    execute "normal! i" . 
        \ comments[0] . "\n" . 
        \ comments[1] . " " . l:l_file . "\n" .
        \ comments[1] . "\n" .
        \ comments[1] . " " . l:l_author . "\n" .
        \ comments[1] . " " . l:l_cdate . "\n" .
        \ comments[1] . " " . l:l_update . "\n" .
        \ comments[2] . "\n\n"

    let &fo= l:s_fmt
    let &autoindent = l:s_autoindent
    let &smartindent = l:s_smartindent 
    let &cindent = l:s_cindent

endfunction

function! AutoHeader_update()
    if &ft == ""
        return
    endif

    let l:comments = s:AutoHeader_getComment(&ft)
    if l:comments == []
        return
    endif


    let l:search = "g/" . l:comments[1] .. " \date Last update:/"
    let l:replace = "s/Last update: .*/Last update: " . strftime("%Y-%m-%d %H:%M")

    execute "normal ma"
    silent! execute l:search .. l:replace
    execute "normal `a"
endfunction

command! AutoHeader call AutoHeader_create()
autocmd FileType c,cpp,css,java,php,make,text,sh,ruby,perl,ocaml,python,vim,tex,lisp,lex,pascal autocmd Bufwritepre,filewritepre * call AutoHeader_update()
