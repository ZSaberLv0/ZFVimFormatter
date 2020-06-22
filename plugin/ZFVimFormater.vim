
function! ZF_FormaterAuto()
    let msg = 'formated by '
    let success = 0
    let oldState = winsaveview()
    normal! gg=G

    if !success
        try
            silent! Neoformat
            let success += 1
            let msg .= 'Neoformat'
        endtry
    endif

    if !success
        try
            Autoformat
            let success += 1
            let msg .= 'Autoformat'
        endtry
    endif

    if !success
        let msg .= 'indent'
    endif
    call winrestview(oldState)
    redraw!
    echomsg msg
endfunction

" format xml files
" require
"     Plugin 'ZSaberLv0/ZFVimBeautifier'
"     Plugin 'ZSaberLv0/ZFVimBeautifierTemplate'
function! ZF_FormaterXml()
    set filetype=xml
    call ZFBeautifier('xml')
    normal! gg=G
endfunction

" format html files
function! ZF_FormaterHtml()
    call ZF_FormaterXml()
    set filetype=xhtml
    normal! gg=G
endfunction

" format json files
" require
"     Plugin 'ZSaberLv0/ZFVimBeautifier'
"     Plugin 'ZSaberLv0/ZFVimBeautifierTemplate'
"     Plugin 'elzr/vim-json'
"     let g:vim_json_syntax_conceal=0
function! ZF_FormaterJson()
    call ZFBeautifier('json')
    set filetype=json
    setlocal softtabstop=2
    setlocal tabstop=2
    setlocal shiftwidth=2
    normal! gg=G
endfunction

" format markdown
" use pandoc to convert, well formated, but need pandoc installed and in PATH
" note: additional format for WP Code Highlight for Wordpress
function! ZF_FormaterMarkdownToHtmlWithWPCodeHighlight()
    let output_file = s:tempname() . '.html'
    let input_file = s:tempname() . '.md'

    silent! %s/\v([^_]|^)_([^_]|$)/\1\{z-underline-z\}\2/g
    silent! %s/\v([^_]|^)_([^_]|$)/\1\{z-underline-z\}\2/g

    silent! %s/\v\&amp;/\{z-amp-z\}/g
    silent! %s/\v\&quot;/\{z-quot-z\}/g
    silent! %s/\v\&lt;/\{z-lt-z\}/g
    silent! %s/\v\&gt;/\{z-gt-z\}/g
    silent! %s/\v\&nbsp;/\{z-nbsp-z\}/g
    silent! %s/\v\&#39;/\{z-39-z\}/g

    let content=getline(1, '$')
    call writefile(content, input_file)
    silent! execute '!pandoc -f markdown -t html -o "' . output_file . '" "' . input_file . '"'
    new
    silent! execute 'read ' . output_file . ''
    normal! ggvG$y
    bd!

    normal! ggvG$p
    call delete(input_file)
    call delete(output_file)
    silent! %s/<pre\([^<>]*\)><code>/<pre\1>\r/g
    silent! %s/<\/code><\/pre>/\r<\/pre>/g

    " enable if used in wordpress with WP Code Highlight plugin
    " which would escape all chars automatically
    if 1
        silent! %s/\v^([ \t]*)$/\1\{z-endl-z\}/g
        silent! %s/ /\{z-space-z\}/g
        silent! g/<pre[^<>]*>\_.\{-}<\/pre>/,/<\/pre>/j

        silent! g/<pre[^<>]*>.*<\/pre>/s/&amp;/\&/ge
        silent! g/<pre[^<>]*>.*<\/pre>/s/\v\{z-amp-z\}/\&amp;/ge

        silent! g/<pre[^<>]*>.*<\/pre>/s/&quot;/"/ge
        silent! g/<pre[^<>]*>.*<\/pre>/s/\v\{z-quot-z\}/\&quot;/ge

        silent! g/<pre[^<>]*>.*<\/pre>/s/&lt;/</ge
        silent! g/<pre[^<>]*>.*<\/pre>/s/\v\{z-lt-z\}/\&lt;/ge

        silent! g/<pre[^<>]*>.*<\/pre>/s/&gt;/>/ge
        silent! g/<pre[^<>]*>.*<\/pre>/s/\v\{z-gt-z\}/\&gt;/ge

        silent! g/<pre[^<>]*>.*<\/pre>/s/&nbsp;/\{z-space-z\}/ge
        silent! g/<pre[^<>]*>.*<\/pre>/s/\v\{z-nbsp-z\}/\&nbsp;/ge

        silent! g/<pre[^<>]*>.*<\/pre>/s/&#39;/'/ge
        silent! g/<pre[^<>]*>.*<\/pre>/s/\v\{z-39-z\}/\&#39;/ge

        silent! g/<pre[^<>]*>.*<\/pre>/s/<br \/>//ge

        silent! g/<pre[^<>]*>.*<\/pre>/s/ /\r/ge
        silent! %s/\v\{z-space-z\}/ /g
        silent! %s/\v\{z-endl-z\}//g
    endif

    normal! gg
    silent! s/^/<tt>\r/
    normal! G
    silent! s/$/\r<\/tt>/

    normal! gg
    silent! s/^/<head><meta charset="UTF-8"><\/head>\r/

    silent! %s/\v\{z-space-z\}/ /g
    silent! %s/\v\{z-underline-z\}/_/g

    silent! %s/\v\{z-amp-z\}/\&amp;amp;/g
    silent! %s/\v\{z-quot-z\}/\&amp;quot;/g
    silent! %s/\v\{z-lt-z\}/\&amp;lt;/g
    silent! %s/\v\{z-gt-z\}/\&amp;gt;/g
    silent! %s/\v\{z-nbsp-z\}/\&amp;nbsp;/g
    silent! %s/\v\{z-39-z\}/\&amp;#39;/g

    silent! %s/\v(\<a href\="[^"]+")/\1 target="_blank"/g
    normal! ggvG$y
endfunction

" for normal md mkd files
" without WP Code Highlight, all code block must be escaped manually
function! ZF_FormaterMarkdownToHtml()
    let output_file = s:tempname() . '.html'
    let input_file = s:tempname() . '.md'

    let content=getline(1, '$')
    call writefile(content, input_file)
    silent! execute '!pandoc -f markdown -t html -o "' . output_file . '" "' . input_file . '"'
    new
    silent! execute 'read ' . output_file . ''
    normal! ggvG$y
    bd!

    normal! ggvG$p
    call delete(input_file)
    call delete(output_file)

    normal! gg
    silent! s/^/<head><meta charset="UTF-8"><\/head>\r/

    normal! ggvG$y
endfunc

" convert normal md mkd files to local html files
function! ZF_FormaterMarkdownToHtmlFile()
    let l:src = expand('%:p')
    let l:dst = expand('%:p:h') . '/' . expand('%:p:t:r') . '.html'
    normal! ggvG$y
    new
    normal! ggVG"_dp
    call ZF_FormaterMarkdownToHtml()
    execute ':w! ' . l:dst
    bd!
endfunction

" view as markdown
function! ZF_FormaterMarkdownPreview()
    normal! ggvG$y
    new
    normal! p
    call ZF_FormaterMarkdownToHtml()
    call ZF_FormaterHtmlPreview()
    bd!
endfunction

" insert predefined markdown TOC style
let s:_my_path = expand('<sfile>')
function! ZF_FormaterMarkdownInsertTocStyle()
    normal! ggO
    execute 'read ' . fnamemodify(s:_my_path, ":p:h") . '/../misc/markdown_toc.txt'
    normal! gg"_dd
    normal! G
endfunction

" view as markdown with TOC
function! ZF_FormaterMarkdownPreviewWithToc()
    normal! ggvG$y
    new
    call ZF_FormaterMarkdownInsertTocStyle()
    normal! G
    normal! p
    call ZF_FormaterMarkdownToHtml()
    call ZF_FormaterHtmlPreview()
    bd!
endfunction

" view as html
function! ZF_FormaterHtmlPreview()
    let tmp_file = s:tempname() . '.html'
    let content=getline(1, '$')
    call writefile(content, tmp_file)
    if has("win32") || has("win64")
        " windows
        silent! execute 'read! "' . tmp_file . '"'
        silent! sleep 200m
        call delete(tmp_file)
    elseif has("unix")
        silent! let s:uname=system("uname")
        if s:uname=="Darwin\n"
            " mac
            call system('open "' . tmp_file . '"')
        else
            " unix
            call system('xdg-open "' . tmp_file . '"')
        endif
    endif
endfunction

" format unicode punctuation to ansi punctuation
" require
"     Plugin 'ZSaberLv0/ZFVimBeautifier'
"     Plugin 'ZSaberLv0/ZFVimBeautifierTemplate'
function! ZF_FormaterUnicodePunctuation()
    call ZFBeautifier('t:replace_unicodePunctuation')
endfunction

let s:autoFormatMap={}
function! ZF_AutoFormatCheck()
    if !exists('s:autoFormatMap["' . &filetype . '"]')
        return
    endif
    if !s:isLargeFile(expand('%'))
        call ZF_FormaterAuto()
    endif
endfunction

" call ZF_AutoFormat([on/off], [filetype], [noEchoState])
function! ZF_AutoFormat(...)
    let filetype = get(a:, 2, &filetype)

    let autoFormat = exists('s:autoFormatMap["' . filetype . '"]') ? 1 : 0
    if get(a:, 1, '') == 'off'
        let t = 0
    elseif empty(get(a:, 1, ''))
        let t = 1 - autoFormat
    else
        let t = 1
    endif

    if t != autoFormat
        if t
            let s:autoFormatMap[filetype] = 1
            augroup ZF_AutoFormatToggle_augroup
                autocmd!
                autocmd BufWritePre * :call ZF_AutoFormatCheck()
            augroup END
        else
            silent! call remove(s:autoFormatMap, filetype)
            if empty(s:autoFormatMap)
                augroup ZF_AutoFormatToggle_augroup
                    autocmd!
                augroup END
            endif
        endif
    endif

    if get(a:, 3, '') != 'noEchoState'
        redraw!
        if t
            echo '[' . filetype . '] autoformat on'
        else
            echo '[' . filetype . '] autoformat off'
        endif
    endif
endfunction

" ZFAutoFormat [on/off] [filetype] [noEchoState]
command! -nargs=* ZFAutoFormat :call ZF_AutoFormat(<f-args>)
if exists('g:ZFAutoFormatFtList')
    for ft in g:ZFAutoFormatFtList
        execute 'ZFAutoFormat on ' . ft . ' noEchoState'
    endfor
endif

" util method
function! ZF_Formater()
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'auto (syntax aware)', 'command':'call ZF_FormaterAuto()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'toggle auto format', 'command':'call ZF_AutoFormat()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'xml (plain regexp replace)', 'command':'call ZF_FormaterXml()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'html (plain regexp replace)', 'command':'call ZF_FormaterHtml()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'json (plain regexp replace)', 'command':'call ZF_FormaterJson()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'markdown to html', 'command':'call ZF_FormaterMarkdownToHtml()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'markdown to html (with WP Code Highlight)', 'command':'call ZF_FormaterMarkdownToHtmlWithWPCodeHighlight()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'markdown to html file', 'command':'call ZF_FormaterMarkdownToHtmlFile()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'markdown insert TOC', 'command':'call ZF_FormaterMarkdownInsertTocStyle()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'markdown preview', 'command':'call ZF_FormaterMarkdownPreview()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'markdown preview (with TOC)', 'command':'call ZF_FormaterMarkdownPreviewWithToc()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'html preview', 'command':'call ZF_FormaterHtmlPreview()'})
    call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'remove unicode punctuation', 'command':'call ZF_FormaterUnicodePunctuation()'})

    call ZF_VimCmdMenuShow({'headerText':'format options:'})
endfunction

" ============================================================
function! s:isLargeFile(file)
    let largeFile = get(g:, 'ZFAutoFormat_largefile', 2 * 1024 * 1024)
    if largeFile > 0 && getfsize(a:file) > largeFile
        return 1
    endif
    return 0
endfunction

function! s:tempname()
    " cygwin's path may not work for some external command
    if has('win32unix') && executable('cygpath')
        return substitute(system('cygpath -m "' . tempname() . '"'), '[\r\n]', '', 'g')
    else
        return tempname()
    endif
endfunction

