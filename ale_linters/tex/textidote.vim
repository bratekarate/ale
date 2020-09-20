" Author: Jordi Altayo <jordiag@kth.se>
" Description: support for textidote grammar and syntax checker

call ale#Set('tex_textidote_executable', 'textidote')
" TODO: read user provided global variable for args instead of hardcoding
" languagemodel, ignorelist and remove-macros
call ale#Set('tex_textidote_options', '--no-color --languagemodel ~/ngram --ignore sh:seclen --remove-macros parencite --read-all --output singleline')
call ale#Set('tex_textidote_check_lang', &spelllang)

function! ale_linters#tex#textidote#GetExecutable(buffer) abort
    let l:exe = ale#Var(a:buffer, 'tex_textidote_executable')
    let l:exe .= ' ' . ale#Var(a:buffer, 'tex_textidote_options')

    let l:check_lang = ale#Var(a:buffer, 'tex_textidote_check_lang')

    if !empty(l:check_lang)
        let l:langs = {
                    \ "en": "en",
                    \ "en_us": "en_US",
                    \ "en_gb": "en_UK",
                    \ "en_ca": "en_CA",
                    \ "fr": "fr",
                    \ "de": "de_DE",
                    \ "de_ch": "de_CH",
                    \ "de_at": "de_AT",
                    \ "nl": "nl",
                    \ "pt": "pt",
                    \ "pt_br": "pt_BR",
                    \ }
        
        let l:check_lang = get(l:langs, l:check_lang, 'en')

        let l:exe .= ' --check ' . l:check_lang
    endif

    echo l:exe

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


