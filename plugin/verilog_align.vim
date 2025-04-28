" ============================================================================
" File:        verilog_align.vim
" Description: Align ports, signals, insts.
" Author:      CannedGrape
" Note:
" License:     MIT License
" ============================================================================

" 定义可视模式下的命令
vnoremap <silent> <leader>pa :<C-U>call AlignPortsFunction(visualmode(), 1)<CR>
vnoremap <silent> <leader>sa :<C-U>call AlignSigsFunction(visualmode(), 1)<CR>
vnoremap <silent> <leader>ia :<C-U>call AlignInstsFunction(visualmode(), 1)<CR>


function! AlignPortsFunction(mode, visual)
" {{{
    if a:visual
        " 获取可视选择的起始和结束行号
        let [line1, col1] = getpos("'<")[1:2]
        let [line2, col2] = getpos("'>")[1:2]
        let lines = getline(line1, line2)
    else
        " 如果不是可视选择，处理整个缓冲区
        let lines = getline(1, '$')
    endif

    let new_lines = []

    let max_bracket_content_length = 0
    let max_signal_name_length     = 0
    for line in lines
        if line =~ '\v^\s*(input|output|inout)\s*(reg\ |wire\ )?\s*(\[.*\])?\s*\w+\s*(,)?\s*(.*)?'
            let line   = substitute(line, '^\s*', '', '')
            let groups = matchlist(line, '\v^\s*(input|output|inout)\s*(reg\ |wire\ )?\s*(\[.*\])?\s*(\w+)\s*(,)?\s*(.*)?')

            let bracket_content_length = len(groups[3])
            let signal_name_length     = len(groups[4])

            if bracket_content_length > max_bracket_content_length
                let max_bracket_content_length = bracket_content_length
            endif

            if signal_name_length > max_signal_name_length
                let max_signal_name_length = signal_name_length
            endif
        endif
    endfor

    for line in lines
        if line =~ '\v^\s*(input|output|inout)\s*(reg\ |wire\ )?\s*(\[.*\])?\s*\w+\s*(,)?\s*(.*)?'
            let line   = substitute(line, '^\s*', '', '')
            let groups = matchlist(line, '\v^\s*(input|output|inout)\s*(reg\ |wire\ )?\s*(\[.*\])?\s*(\w+)\s*(,)?\s*(.*)?')

            let line = '    '

            if groups[1] == 'input'
                let line = line . 'input  '
            elseif groups[1] == 'output'
                let line = line . 'output '
            elseif groups[1] == 'inout'
                let line = line . 'inout  '
            endif

            if groups[2] == 'reg '
                let line = line . 'reg  '
            elseif groups[2] == 'wire '
                let line = line . 'wire '
            else
                let line = line . '     '
            endif

            if groups[3] != ''
                let line = line . groups[3] . repeat(' ', max_bracket_content_length - len(groups[3])) . ' '
            else
                let line = line . repeat(' ', max_bracket_content_length) . ' '
            endif

            let line = line . groups[4] . repeat(' ', max_signal_name_length - len(groups[4]))

            let line = line . groups[5] . '  ' . trim(groups[6])
        endif

        call add(new_lines, line)
    endfor

    if a:visual
        call setline(line1, new_lines)
    else
        call setline(1, new_lines)
    endif
endfunction
" }}}


function! AlignSigsFunction(mode, visual)
" {{{
    if a:visual
        let [line1, col1] = getpos("'<")[1:2]
        let [line2, col2] = getpos("'>")[1:2]
        let lines = getline(line1, line2)
    else
        let lines = getline(1, '$')
    endif

    let new_lines = []

    let max_bracket_content_length = 0
    let max_signal_name_length     = 0
    for line in lines
        if line =~ '\v^\s*(reg|wire|input|output|inout)?\s*(\[.*\])?\s*\w+\s*(;)\s*(.*)?'
            let line   = substitute(line, '^\s*', '', '')
            let groups = matchlist(line, '\v^\s*(reg|wire|input|output|inout)?\s*(\[.*\])?\s*(\w+)\s*(;)\s*(.*)?')

            let bracket_content_length = len(groups[2])
            let signal_name_length     = len(groups[3])

            if bracket_content_length > max_bracket_content_length
                let max_bracket_content_length = bracket_content_length
            endif

            if signal_name_length > max_signal_name_length
                let max_signal_name_length = signal_name_length
            endif
        endif
    endfor

    for line in lines
        if line =~ '\v^\s*(reg|wire|input|output|inout)?\s*(\[.*\])?\s*\w+\s*(;)\s*(.*)?'
            let line   = substitute(line, '^\s*', '', '')
            let groups = matchlist(line, '\v^\s*(reg|wire|input|output|inout)?\s*(\[.*\])?\s*(\w+)\s*(;)\s*(.*)?')

            let line = ''

            if groups[1] == 'reg'
                let line = line . 'reg    '
            elseif groups[1] == 'wire'
                let line = line . 'wire   '
            elseif groups[1] == 'input'
                let line = line . 'input  '
            elseif groups[1] == 'output'
                let line = line . 'output '
            elseif groups[1] == 'inout'
                let line = line . 'inout  '
            else
                let line = line . '       '
            endif

            if groups[2] != ''
                let line = line . groups[2] . repeat(' ', max_bracket_content_length - len(groups[2])) . ' '
            else
                let line = line . repeat(' ', max_bracket_content_length) . ' '
            endif

            let line = line . groups[3] . repeat(' ', max_signal_name_length - len(groups[3]))

            let line = line . groups[4] . '  ' . trim(groups[5])
        endif

        call add(new_lines, line)
    endfor

    if a:visual
        call setline(line1, new_lines)
    else
        call setline(1, new_lines)
    endif
endfunction
" }}}


function! AlignInstsFunction(mode, visual)
" {{{
    if a:visual
        let [line1, col1] = getpos("'<")[1:2]
        let [line2, col2] = getpos("'>")[1:2]
        let lines = getline(line1, line2)
    else
        let lines = getline(1, '$')
    endif

    let new_lines = []

    let max_bracket_content_length = 0
    let max_signal_name_length     = 0
    for line in lines
        if line =~ '\v^\s*(.)\s*(\w+)\s*\((.*)\)\s*(,)?\s*(.*)?'
            let line   = substitute(line, '^\s*', '', '')
            let groups = matchlist(line, '\v^\s*(.)\s*(\w+)\s*\((.*)\)\s*(,)?\s*(.*)?')

            let bracket_content_length = len(groups[2])
            let signal_name_length     = len(trim(groups[3]))

            if bracket_content_length > max_bracket_content_length
                let max_bracket_content_length = bracket_content_length
            endif

            if signal_name_length > max_signal_name_length
                let max_signal_name_length = signal_name_length
            endif
        endif
    endfor

    for line in lines
        if line =~ '\v^\s*(.)\s*(\w+)\s*\((.*)\)\s*(,)?\s*(.*)?'
            let line   = substitute(line, '^\s*', '', '')
            let groups = matchlist(line, '\v^\s*(.)\s*(\w+)\s*\((.*)\)\s*(,)?\s*(.*)?')

            let line = '    .'

            let line = line . groups[2] . repeat(' ', max_bracket_content_length - len(groups[2])) . ' ( '

            let line = line . trim(groups[3]) . repeat(' ', max_signal_name_length - len(trim(groups[3]))) . ' )'

            let line = line . groups[4] . '  ' . trim(groups[5])
        endif

        call add(new_lines, line)
    endfor

    if a:visual
        call setline(line1, new_lines)
    else
        call setline(1, new_lines)
    endif
endfunction
" }}}

