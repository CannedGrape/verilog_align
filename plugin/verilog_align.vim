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

    "   groups            1                      2                              3         4       5      6
    let pattern = '\v^\s*(input|output|inout)\s*(reg\ |wire\ |reg\[|wire\[)?\s*(.*\])?\s*(\w+)\s*(,)?\s*(.*)?'

    let new_lines = []

    let max_bracket_content_length = 0
    let max_signal_name_length     = 0
    for line in lines
        let temp_line = trim(line)
        if stridx(temp_line, '//') > 0
            let parts = split(temp_line, '//')
            let code_line = parts[0]
        else
            let code_line = temp_line
        endif

        if code_line =~ pattern
            let code_line = substitute(code_line, '^\s*', '', '')
            let groups    = matchlist(code_line, pattern)

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

    let max_signal_name_length = max_signal_name_length + 1

    for line in lines
        let temp_line    = trim(line)
        let comment_line = ''
        let comment_pos  = stridx(temp_line, '//')

        if comment_pos == 0
            let comment_line = trim(strpart(temp_line, comment_pos + 2))  " +2: '//' 2 chars
            let code_line    = ''
        elseif comment_pos > 0
            let parts        = split(temp_line, '//')
            let comment_line = trim(strpart(temp_line, comment_pos + 2))
            let code_line    = trim(parts[0])
        else
            let comment_line = ''
            let code_line    = temp_line
        endif

        if code_line =~ pattern
            let code_line = substitute(code_line, '^\s*', '', '')
            let groups    = matchlist(code_line, pattern)

            let code_line = '    '

            if groups[1] == 'input'
                let code_line = code_line . 'input  '
            elseif groups[1] == 'output'
                let code_line = code_line . 'output '
            elseif groups[1] == 'inout'
                let code_line = code_line . 'inout  '
            endif

            let groups3_dec = 0
            if groups[2] == 'reg '
                let code_line = code_line . 'reg  '
            elseif groups[2] == 'wire '
                let code_line = code_line . 'wire '
            elseif groups[2] == 'reg['
                let code_line = code_line . 'reg  ['
                let groups3_dec = 1
            elseif groups[2] == 'wire['
                let code_line = code_line . 'wire ['
                let groups3_dec = 1
            else
                let code_line = code_line . '     '
            endif

            if groups[3] != ''
                let code_line = code_line . groups[3] . repeat(' ', max_bracket_content_length - len(groups[3]) - groups3_dec) . ' '
            else
                let code_line = code_line . repeat(' ', max_bracket_content_length) . ' '
            endif

            let code_line = code_line . groups[4] . repeat(' ', max_signal_name_length - len(groups[4]))

            let code_line = code_line . groups[5]

            " let code_line = code_line . '  ' . trim(groups[6])
            if comment_line != ''
                let code_line = code_line . '  // ' . comment_line
            endif
        elseif code_line == '' && comment_line == ''
            let code_line = '    '
        elseif code_line == '' && comment_line != ''
            let code_line = '    ' . '// ' . comment_line
        else
            let code_line = temp_line
        endif

        call add(new_lines, code_line)
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

    "   groups            1                                2           3       4     5
    let pattern = '\v^\s*(reg|wire|input|output|inout)?\s*(\[.*\])?\s*(\w+)\s*(;)\s*(.*)?'

    let new_lines = []

    let max_bracket_content_length = 0
    let max_signal_name_length     = 0
    for line in lines
        let temp_line = trim(line)
        if stridx(temp_line, '//') > 0
            let parts = split(temp_line, '//')
            let code_line = parts[0]
        else
            let code_line = temp_line
        endif

        if code_line =~ pattern
            let code_line = substitute(code_line, '^\s*', '', '')
            let groups    = matchlist(code_line, pattern)

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

    let max_signal_name_length = max_signal_name_length + 1

    for line in lines
        let temp_line    = trim(line)
        let comment_line = ''
        let comment_pos  = stridx(temp_line, '//')

        if comment_pos == 0
            let comment_line = trim(strpart(temp_line, comment_pos + 2))  " +2: '//' 2 chars
            let code_line    = ''
        elseif comment_pos > 0
            let parts        = split(temp_line, '//')
            let comment_line = trim(strpart(temp_line, comment_pos + 2))
            let code_line    = trim(parts[0])
        else
            let comment_line = ''
            let code_line    = temp_line
        endif

        if code_line =~ pattern
            let code_line = substitute(code_line, '^\s*', '', '')
            let groups    = matchlist(code_line, pattern)

            let code_line = ''

            if groups[1] == 'reg'
                let code_line = code_line . 'reg    '
            elseif groups[1] == 'wire'
                let code_line = code_line . 'wire   '
            elseif groups[1] == 'input'
                let code_line = code_line . 'input  '
            elseif groups[1] == 'output'
                let code_line = code_line . 'output '
            elseif groups[1] == 'inout'
                let code_line = code_line . 'inout  '
            else
                let code_line = code_line . '       '
            endif

            if groups[2] != ''
                let code_line = code_line . groups[2] . repeat(' ', max_bracket_content_length - len(groups[2])) . ' '
            else
                let code_line = code_line . repeat(' ', max_bracket_content_length) . ' '
            endif

            let code_line = code_line . groups[3] . repeat(' ', max_signal_name_length - len(groups[3]))

            let code_line = code_line . groups[4]

            " let code_line = code_line . '  ' . trim(groups[5])
            if comment_line != ''
                let code_line = code_line . '  // ' . comment_line
            endif
        elseif code_line == '' && comment_line == ''
            let code_line = ''
        elseif code_line == '' && comment_line != ''
            let code_line = '// ' . comment_line
        else
            let code_line = temp_line
        endif

        call add(new_lines, code_line)
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

    "   groups            1     2        3         4      5
    let pattern = '\v^\s*(.)\s*(\w+)\s*\((.*)\)\s*(,)?\s*(.*)?'

    let new_lines = []

    let max_bracket_content_length = 0
    let max_signal_name_length     = 0
    for line in lines
        let temp_line = trim(line)
        if stridx(temp_line, '//') > 0
            let parts = split(temp_line, '//')
            let code_line = parts[0]
        else
            let code_line = temp_line
        endif

        if code_line =~ pattern
            let line   = substitute(code_line, '^\s*', '', '')
            let groups = matchlist(code_line, pattern)

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
        let temp_line    = trim(line)
        let comment_line = ''
        let comment_pos  = stridx(temp_line, '//')

        if comment_pos == 0
            let comment_line = trim(strpart(temp_line, comment_pos + 2))  " +2: '//' 2 chars
            let code_line    = ''
        elseif comment_pos > 0
            let parts        = split(temp_line, '//')
            let comment_line = trim(strpart(temp_line, comment_pos + 2))
            let code_line    = trim(parts[0])
        else
            let comment_line = ''
            let code_line    = temp_line
        endif

        if code_line =~ pattern
            let code_line = substitute(code_line, '^\s*', '', '')
            let groups    = matchlist(code_line, pattern)

            let code_line = '    .'

            let code_line = code_line . groups[2] . repeat(' ', max_bracket_content_length - len(groups[2])) . ' ( '

            let code_line = code_line . trim(groups[3]) . repeat(' ', max_signal_name_length - len(trim(groups[3]))) . ' )'

            let code_line = code_line . groups[4]

            " let code_line = code_line . '  ' . trim(groups[5])
            if comment_line != ''
                let code_line = code_line . '  // ' . comment_line
            endif
        elseif code_line == '' && comment_line == ''
            let code_line = ''
        elseif code_line == '' && comment_line != ''
            let code_line = '    // ' . comment_line
        else
            let code_line = temp_line
        endif

        call add(new_lines, code_line)
    endfor

    if a:visual
        call setline(line1, new_lines)
    else
        call setline(1, new_lines)
    endif
endfunction
" }}}

