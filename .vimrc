" .vimrc

let &statusline="%f%< %y[%{&fileencoding}/%{&encoding}/%{&termencoding}][%{&fileformat}](%n)%m%r%w %a%=%b 0x%B  L:%l/%L, C:%-7(%c%V%) %P"

map <F5> :w<CR>:make<CR>
map <F6> :make run<CR> 
map <F7> :make clean<CR>
map <F8> :make debug<CR>
map <F9> :cprev<CR>
map <F10> :cnext<CR>
map <F11> :clist<CR>

if has("autocmd")
	filetype plugin indent on
	" filetype dependent settings
	au Filetype vhdl call FT_vhdl()
	" filetype dependent templates
	au BufNewFile *.{vhd,py,tex,asm,sh,c,java,html} call Template_Load(expand("%"))
	" replace $template:date$ and $template:filename$
	au BufNewFile *.{vhd,py,tex,asm,html} call Template_Replace_Special()
else
	set autoindent
endif 

function FT_vhdl()
	setlocal tabstop=4
	setlocal shiftwidth=4
	if exists("+omnifunc")
		setlocal omnifunc=syntaxcomplete#Complete
	endif
	setlocal makeprg=gmake
	setlocal errorformat=**\ Error:\ %f(%l):\ %m
	let g:vhdl_indent_genportmap=0
	map <buffer> <F4> :execute ':!vsim -c -do "run -all;exit" '.expand("%:t:r")<CR>
	" for taglist
	let g:tlist_vhdl_settings   = 'vhdl;d:package declarations;b:package bodies;e:entities;a:architecture specifications;t:type declarations;p:processes;f:functions;r:procedures'
	" command mappings for perl scripts
	:command! -nargs=1 -complete=file VHDLcomp r! ~/.vhdl/vhdl_comp.pl <args>
	:command! -nargs=1 -complete=file VHDLinst r! ~/.vhdl/vhdl_inst.pl <args>
	" environments
	imap <buffer> <C-e>e <Esc>bdwientity <Esc>pa is<CR>end entity ;<Esc>POport (<CR>);<Esc>O
	imap <buffer> <C-e>a <Esc>b"zdwiarchitecture <Esc>pa of <Esc>mz?entity<CR>wyw`zpa is<CR>begin<CR>end architecture ;<Esc>"zPO
	imap <buffer> <C-e>p <Esc>bywA : process ()<CR>begin<CR>end process ;<Esc>PO<+process body+><Esc>?)<CR>i
	imap <buffer> <C-e>g <Esc>bdwipackage <Esc>pa is<CR><BS>end package ;<Esc>PO    
	imap <buffer> <C-e>c case  is<CR>when <+state1+> =><CR><+action1+><CR>when <+state2+> =><CR><+action2+><CR>when others => null;<CR>end case;<Esc>6k$2hi
	imap <buffer> <C-e>i if  then<CR><+do_something+>;<CR>elsif <+condition2+> then<CR><+do_something_else+>;<CR>else<CR><+do_something_else+>;<CR>end if;<Esc>6k$4hi
	" shortcuts
	imap <buffer> ,, <= 
	imap <buffer> .. => 
	imap <buffer> <C-s>i <Esc>:VHDLinst 
	imap <buffer> <C-s>c <Esc>:VHDLcomp
	" visual mappings
	vmap <C-a> :!~/.vhdl/vhdl_align.py<CR>
	vmap <C-d> :!~/.vhdl/vhdl_align_comments.py<CR>
	" alt key mappings
	imap <buffer> <M-i> <Esc>owhen 
	" abbreviations
	iabbr dt downto
	iabbr sig signal
	iabbr gen generate
	iabbr ot others
	iabbr sl std_logic
	iabbr slv std_logic_vector
	iabbr uns unsigned
	iabbr toi to_integer
	iabbr tos to_unsigned
	iabbr tou to_unsigned
	imap <buffer> I: I : in 
	imap <buffer> O: O : out 
	" emacs vhdl mode
	" warning: the following is dangerous, becase the file is written and then opened again, which means, the undo history is lost; if someting goes wrong, you may loose your file
	"command! EVMUpdateSensitivityList :w|:execute "!emacs --no-init-file --no-site-file -l ~/.vhdl/vhdl-mode.el -batch % --eval '(vhdl-update-sensitivity-list-buffer)' -f save-buffer" | :e
	"map <F12> :EVMUpdateSensitivityList<CR>
endfunction

" load templates
function Template_Load(filename)
	if a:filename =~ "\.vhd$"
		0r ~/.templates/vhdl
	endif
endfunction

" replacement for $template:xy$ in templates
function Template_Replace_Special()
	if exists("*strftime")
		try
			exe "%s+\\\$template:date\\\$+".strftime("%d.%m.%Y")
		catch
		endtry
		try
			exe "%s+\\\$template:year\\\$+".strftime("%Y")
		catch
		endtry
	endif
	try
		exe "%s/\\\$template:filename\\\$/".expand("%:t")
	catch
	endtry
	try
		exe "%s/\\\$template:classname\\\$/".toupper(strtrans(expand("%:t:r")))
	catch
	endtry
	try
		exe "%s/\\\$template:instancename\\\$/".strtrans(expand("%:t:r"))
	catch
	endtry
	1
endfunction

au BufEnter *.{c,cpp,cc,h,hpp,py,tex,vhd} call TagTitle()
function TagTitle()
	if exists(":TlistUpdate")       " show current tag in title
		TlistUpdate
		set titlestring=%<%f\ %([%{Tlist_Get_Tagname_By_Line()}]%)
	endif
endfunction







if has("syntax")
syntax on
endif

:colorscheme evening
"hi normal ctermfg=grey

set nu
"set nonu

syntax enable

set ts=2

vmap <tab> >

