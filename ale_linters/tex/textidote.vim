" Author: Jordi Altayo <jordiag@kth.se>
" Description: support for textidote grammar and syntax checker

call ale#Set('tex_textidote_executable', 'textidote')
" No non-overwritable defaults for options. --output and
" --no-color must not be overriden by user defined global variables as it will
"  break linting.
call ale#Set('tex_textidote_options', '')
call ale#Set('tex_textidote_read_all', 0)

let s:langs = {
            \ 'en': 'en',
            \ 'en_us': 'en_US',
            \ 'en_gb': 'en_UK',
            \ 'en_ca': 'en_CA',
            \ 'fr': 'fr',
            \ 'de': 'de_DE',
            \ 'de_ch': 'de_CH',
            \ 'de_at': 'de_AT',
            \ 'nl': 'nl',
            \ 'pt': 'pt',
            \ 'pt_br': 'pt_BR',
            \ }

function! ale_linters#tex#textidote#GetExecutable(buffer) abort
    let l:exe = ale#Var(a:buffer, 'tex_textidote_executable')
    let l:opts = '--output singleline --no-color ' . ale#Var(a:buffer, 'tex_textidote_options')

    if ale#Var(a:buffer, 'tex_textidote_read_all')
        let l:opts .= ' --read-all'
    endif

    let l:check_lang_opt = get(g:, 'ale_tex_textidote_check_lang', &spelllang)
    let l:check_lang = get(s:langs, l:check_lang_opt, 'en')
    let opts .= ' --check ' . l:check_lang

    let l:exe .= ' ' . l:opts

    return l:exe . ' ' . expand('#' . a:buffer . ':t')
endfunction

function! ale_linters#tex#textidote#Handle(buffer, lines) abort
    let l:pattern = '.*' . expand('#' . a:buffer . ':t:r') . '\.tex(L\(\d\+\)C\(\d\+\)-L\d\+C\d\+): \(.*\)".*"'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col' : l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': 'E',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('tex', {
\   'name': 'textidote',
\   'output_stream': 'stdout',
\   'executable': {b -> ale#Var(b, 'tex_textidote_executable')},
\   'command': function('ale_linters#tex#textidote#GetExecutable'),
\   'callback': 'ale_linters#tex#textidote#Handle',
\})


