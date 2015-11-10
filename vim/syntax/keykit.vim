" Vim syntax file
" Language:	Keykit
" Filenames: 	*.k 
" Maintainer:	None
" Author:	Olaf Schulz <funwithkinect@googlemail.com>
"
" Last Change:	2015 Nov 5
" Note:		This file based on the default python.vim 
"		from 2013 Feb 26.
"		Creits for this source goes to
"		Zvezdan Petkovic <zpetkovic@acm.org>
"		Neil Schemenauer <nas@python.ca>
"		Dmitry Vasiliev
"		
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" We need nocompatible mode in order to continue lines with backslashes.
" Original setting will be restored.
let s:cpo_save = &cpo
set cpo&vim

"syn keyword pythonStatement	False, None, True
"syn keyword pythonStatement	as assert break continue del exec global
syn keyword pythonStatement	function print return method task
syn keyword pythonStatement	class nextgroup=pythonFunction skipwhite
syn keyword pythonConditional	else if
syn keyword pythonRepeat	for while
syn keyword pythonOperator	in is 
"syn keyword pythonException	try except finally raise try
syn keyword pythonException	break continue
syn keyword pythonInclude	from import 
syn keyword keykitSpecial	Now Root MIXED NOTE NOTEOFF NOTEON PRESSURE CONTROLLER PITCHBEND PROGRAM CHANPRESSURE MIDIBYTES
syn keyword keykitSpecial	SYSEX POSITION SONG STARTSTOPCONT CLOCK
syn keyword keykitSpecial	readonly undefine global
"syn keyword keykitSpecial	include library define
"
" Types for cut(phrase, type, ...)
syn keyword keykitSpecial	CUT_TIME CUT_CHANNEL CUT_TYPE CUT_NOTTYPE CUT_FLAGS NORMAL TRUNCATE INCLUSIVE

" Decorators (new in Python 2.4)
syn match   pythonDecorator	"@" display nextgroup=pythonFunction skipwhite
" The zero-length non-grouping match before the function name is
" extremely important in pythonFunction.  Without it, everything is
" interpreted as a function inside the contained environment of
" doctests.
" A dot must be allowed because of @MyClass.myfunc decorators.
syn match   pythonFunction
      \ "\%(\%(def\s\|class\s\|@\)\s*\)\@<=\h\%(\w\|\.\)*" contained

syn match   pythonComment	"#.*$" contains=pythonTodo,@Spell
syn keyword pythonTodo		FIXME NOTE NOTES TODO XXX contained

syn keyword keykitDollar	$

" Triple-quoted strings can contain doctests.
syn region  keykitPhrase
      \ start=+[uU]\=\z([']\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=pythonEscape,@Spell
syn region  pythonString
      \ start=+[uU]\=\z(["]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=pythonEscape,@Spell
syn region  pythonString
      \ start=+[uU]\=\z('''\|"""\)+ end="\z1" keepend
      \ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
syn region  pythonRawString
      \ start=+[uU]\=[rR]\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=@Spell
syn region  pythonRawString
      \ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
      \ contains=pythonSpaceError,pythonDoctest,@Spell
syn region shCommandSub start="[$]\{1,2}[.]\="  end=""  contains=keykitDollar

syn match   pythonEscape	+\\[abfnrtv'"\\]+ contained
syn match   pythonEscape	"\\\o\{1,3}" contained
syn match   pythonEscape	"\\x\x\{2}" contained
syn match   pythonEscape	"\%(\\u\x\{4}\|\\U\x\{8}\)" contained
" Python allows case-insensitive Unicode IDs: http://www.unicode.org/charts/
syn match   pythonEscape	"\\N{\a\+\%(\s\a\+\)*}" contained
syn match   pythonEscape	"\\$"

if exists("python_highlight_all")
  if exists("python_no_builtin_highlight")
    unlet python_no_builtin_highlight
  endif
  if exists("python_no_doctest_code_highlight")
    unlet python_no_doctest_code_highlight
  endif
  if exists("python_no_doctest_highlight")
    unlet python_no_doctest_highlight
  endif
  if exists("python_no_exception_highlight")
    unlet python_no_exception_highlight
  endif
  if exists("python_no_number_highlight")
    unlet python_no_number_highlight
  endif
  let python_space_error_highlight = 1
endif

if !exists("python_no_number_highlight")
" Valid Keykit numbers are as subset of Python ones plus '[num]b'.
  syn match   pythonNumber	"\<0[x]\x\+[b]\=\>"
  syn match   pythonNumber	"\<0\=\o\+[b]\=\>"
  syn match   pythonNumber	"\<\%([1-9]\d*\|0\)[b]\=\>"
  syn match   pythonNumber	"\<\d\+[e][+-]\=\d\+\>"
  syn match   pythonNumber
	\ "\<\d\+\.\%([e][+-]\=\d\+\)\=\%(\W\|$\)\@="
endif

syn keyword keykitPhraseProp dur type time chan pitch vol length

if !exists("python_no_builtin_highlight")
  " built-in functions
  syn keyword pythonBuiltin	abs round 
  syn keyword pythonBuiltin	max min object open print
  syn keyword pythonBuiltin	inherited midibytes delete deleteobject lock unlock rand focus
  " Keykit keywords from bltin.c
  syn keyword pythonBuiltin	typeof sizeof oldnargs argv midibytes substr subbytes rand 
	\ error printf readphr exit oldtypeof split cut string integer phrase
	\ float system chdir tempo milliclock currtime filetime garbcollect funkey ascii 
	\ midifile reboot refunc debug nullfunc pathsearch symbolnamed limitsof sin cos 
	\ tan asin acos atan sqrt pow exp log log10 realtime 
	\ finishoff sprintf get put open fifosize flush close taskinfo kill 
	\ priority onexit onerror sleeptill wait lock unlock object objectlist
	\ windowobject screen setmouse mousewarp browsefiles color colormix sync oldxy Redrawfunc
	\ Resizefunc Colorfunc popup help rekeylib Exitfunc Errorfunc Rebootfunc Intrfunc coreleft
	\ prstack phdump lsdir attribarray fifoctl mdep midi bitmap objectinfo
  " Keykit subset of all library function names
  syn keyword pythonBuiltin	strbits alphafun char2bits bits2phrase alpha_back arpeggio legato attime 
	\ nexttime closest closestmap closestt flip highest lastbunch latest lowest lowestnt
	\ highestnt minvolume maxvolume minduration makenote mono quantize quantizefirst quantizedur repeat
	\ repleng reverse revpitch scaleng scatimes scadur scavol step strip transpose
	\ ano allsusoff onlynotes nonnotes delay chaninfo eventime swapnote shuffle apply
	\ applynear dupsof dedup dedupdur findroot makerootevery addrootevery pitchlimit transposeseqrepeat transposeseqinplace
	\ scadjustseqinplace firsthalf secondhalf allchords chord chordnamed echo spread preecho echomaster
	\ floor round gvolchange chanvolchange gexpressionchange chanexpressionchange gmastervol progchange patchchange controller
	\ pannote pitchbend nrpn rpnmsg datamsg bankselect sussect syncphr resetall gmresetall
	\ alloff anoall realgmreset startmsg continuemsg stopmsg simulinfo nsimul fractal octavefence
	\ repfade noise oldcontrolthin thinit thincontrol lastnotechord pitchbendnotes controllernotes sustainnotes expressionnotes
	\ modulationnotes volumenotes pannotes progchangenotes crescendo setbendrange temponote mergeonoff applyfunc step_8
	\ step_16 step_32 scadjust_last tonerow_old tonerow scalevertical evolve chordmel expandvol autopan
	\ changeprogchange ornament debank derest cmd_inverti cmd_invertidir cmd_crescendo cmd_decrescendo cmd_slowdown cmd_leavechan
	\ cmd_removechan cmd_leavetype cmd_removetype cmd_leaveonbeat cmd_removeonbeat cmd_leavenearbeat cmd_removenearbeat cmd_leaverand cmd_removerand cmd_leaventh
	\ cmd_removenth cmd_leavedur cmd_removedur cmd_leavevol cmd_removevol cmd_addroot cmd_arpeggio cmd_legato cmd_transposeseq cmd_transpose
	\ cmd_scalast cmd_chordize cmd_scadjust cmd_scafilt cmd_mono cmd_null cmd_applynear cmd_applyseq cmd_average cmd_dedup
	\ cmd_debank cmd_dedupdur cmd_echo cmd_preecho cmd_spread cmd_bs cmd_permute cmd_expandvol cmd_evolve cmd_autopan
	\ cmd_flip cmd_tonerow cmd_replace cmd_thin cmd_thincontrol cmd_fractal cmd_shuffle cmd_eventime cmd_quantize cmd_quantizefirst
	\ cmd_quantizedur cmd_setduration cmd_step cmd_timescale cmd_durscale cmd_volscale cmd_stutter cmd_stutterrand cmd_repeat cmd_repeatquant
	\ cmd_setchan cmd_adjvol cmd_swapnotes cmd_shift cmd_reverse cmd_fade cmd_noise cmd_ornament gs_strangemap gs_chksum
	\ gs_reset gs_turnon gs_turnoff gs_scaletune gs_finetune gs_coarsetune gs_nrpnvibrato gs_nrpncombi gs_nrpnctrl gs_nrpncutoff
	\ gs_nrpnreso gs_nrpnattack gs_nrpndecay gs_nrpnrelease rpn_finetune rpn_coarsetune rpn_bendrange gs_mastertune gs_toneselect gs_partmode
	\ gs_mfxtype gs_mfxpart gs_mfxpara bd_round draw_uparrow draw_downarrow keyrc addprerc addpostrc dokeylocal
	\ prelocaldefaults rcdefaults rcpostboot rcdefaults_mdep bootvars consoleprintf normboot addbootfunc normintr kvalbutton_mkmenu
	\ launchrand task_launchrand launchpad_init launchpad_reset launchpad_flash launchpad_on launchpad_off launchpad_realtime layout_vertical layout_horizontal
	\ listen consloop consoutloop interploop mouseloop mouserec mousewritefile mousereadfile dodemo mousedemo
	\ mouseplay mouseplaytask mousedo midiloop deletemidiin closemidi consloop consoutloop interploop mouseloop
	\ mouserec mousewritefile mousereadfile dodemo mousedemo mouseplay mouseplaytask mousedo midiloop deletemidiin
	\ closemidi fileWatch scriptWatch midirouter midirouter_cleanup task_midirouter addrecorded zoomoutandredraw readandsend printit
	\ tooltypesall tooltypes add2tooltypes winvis m_top volmonitor osc_listen osc_send osc_sendto osc_sean
	\ oscgroup_send oscgroup_listen linux_send linux_listen page_new page_switchto newpagename page_switch page_label page_write
	\ page_readnew page_post page_readmerge snapshot restartconfig task_slidermon slidermon picnic picnicmedley picnic2
	\ picnic_reset sendNoteOffs playchords playChordstask proc_list { picknote pickphr randdur randpitch
	\ randvol readkey readfile readraw filetopitches readrawplay readmf readmid readmfchan suffixof
	\ browsephrase browsesyx realmidi realmiditask realslow noticecontrollers noticeprogram realexpr realexprtask tick
	\ testgenerateclock generateclock getsysexdump loophack collectsysexdump txpatches txperfs getanote task_loop mergeonly
	\ recfilteron task_monitor test_monitor virusreq1 virustest waitforstart synctostart relayscan relays relay
	\ remotecons remotecons_task remotecons_loop rootmon task_rootmon chadjust chfilter scadjust scafilt allscales
	\ scale_ionian scale_dorian scale_phrygian scale_lydian scale_mixolydian scale_aeolian scale_locrian scale_newage scale_fifths scale_harminor
	\ scale_melminor scale_chromatic scalenamed scale_last makescale completescale transform_preecho2 transform_null transform_slow transform_none
	\ transform_step transform_step2 transform_fractal transform_stutter transform_arpeggio transform_tonerow transform_thin transform_spread transform_reverse test_listen
	\ test_loop test_connect http_client sock_client sock_server sock_test udp_listen udp_listen2 udp_test_send keykithostname
	\ smtptest updatelib readeveryfile rereadlib argvlist arraycopy arraysortonindex arraysort arraylist arrayprint
	\ constant setdefaults findtask fileisreadable togglemet isonbeat isnearbeat isinarea isinscale millisleep
	\ lookup writephr writemf uniqnum nextquant prevquant registop stop incpriority decpriority
	\ regicontrol unregicontrol definecontrol broadcastcontrol querycontrol regiprogram unregiprogram defineprogram broadcastprogram queryprogram
	\ status getastr numquant abs xystr fileexists filecat gettid definelocks domethod
	\ waitnput waitncall waitnmethod waitneval tail head methodforward2first methodbroadcast mouseforward beatinfo
	\ textfunc normredraw normexit normresize canonic milliclicks seconds millisince killtids deleteobject
	\ rereadlibs fulltrace dprint print fib tension fullinfo iserasechar iserasechar readedit
	\ readedit2 chansplit spliteven splitonstarts_orig splitonstarts setsnarf nullfunction efunction noiseval gauss
	\ testrand testgauss test1f testnoiseval oneovrf fakebrowsefiles linesout docmd logit globalvalue
	\ rectresize haschannel fakekeyboardinput eval_number strindex debugfile controllerlist toolnotes makeholdernote note2holder
	\ permutations permutations_visit listports inport outport mapport portsopened lookforandopen lookforport bpm
	\ gcd2 lcm gcd pathescape evalstring limitval fxy setdefaultchancolormap chancolortestphrase wgenepool_mon
	\ wgrabbag_mon toolize waitup waitdown waitnsweep xymid wselect whelp drawx fillspace
	\ wresize wmax wdelete wswap wcopy wsnarf wsnarftool wpastetool wmove sweeptool
	\ wshowdump wbroadcast wdump wrestore grabmouse ungrabmouse grabmousefifo ungrabmousefifo fit2root areacontains
	\ closenkill kerror kserver konnectinterp
  
endif

if !exists("python_no_exception_highlight")
  " builtin base exceptions (only used as base classes for other exceptions)
  syn keyword pythonExceptions	BaseException Exception
endif

if exists("python_space_error_highlight")
  " trailing whitespace
  syn match   pythonSpaceError	display excludenl "\s\+$"
  " mixed tabs and spaces
  syn match   pythonSpaceError	display " \+\t"
  syn match   pythonSpaceError	display "\t\+ "
endif

" Do not spell doctests inside strings.
" Notice that the end of a string, either ''', or """, will end the contained
" doctest too.  Thus, we do *not* need to have it as an end pattern.
if !exists("python_no_doctest_highlight")
  if !exists("python_no_doctest_code_highlight")
    syn region pythonDoctest
	  \ start="^\s*>>>\s" end="^\s*$"
	  \ contained contains=ALLBUT,pythonDoctest,@Spell
    syn region pythonDoctestValue
	  \ start=+^\s*\%(>>>\s\|\.\.\.\s\|"""\|'''\)\@!\S\++ end="$"
	  \ contained
  else
    syn region pythonDoctest
	  \ start="^\s*>>>" end="^\s*$"
	  \ contained contains=@NoSpell
  endif
endif

" Sync at the beginning of class, function, or method definition.
syn sync match pythonSync grouphere NONE "^\s*\%(def\|class\)\s\+\h\w*\s*("

if version >= 508 || !exists("did_python_syn_inits")
  if version <= 508
    let did_python_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default highlight links.  Can be overridden later.
  HiLink pythonStatement	Statement
  HiLink pythonConditional	Conditional
  HiLink pythonRepeat		Repeat
  HiLink pythonOperator		Operator
  HiLink pythonException	Exception
  HiLink pythonInclude		Include
  HiLink pythonDecorator	Define
  HiLink pythonFunction		Function
  HiLink pythonComment		Comment
  HiLink pythonTodo		Todo
  HiLink pythonString		String
  HiLink keykitPhrase		Operator
  HiLink shCommandSub		Special
  HiLink pythonRawString	String
  HiLink pythonEscape		Special
  HiLink keykitSpecial		Include
  HiLink keykitPhraseProp	Special
  if !exists("python_no_number_highlight")
    HiLink pythonNumber		Number
  endif
  if !exists("python_no_builtin_highlight")
    HiLink pythonBuiltin	Function
  endif
  if !exists("python_no_exception_highlight")
    HiLink pythonExceptions	Structure
  endif
  if exists("python_space_error_highlight")
    HiLink pythonSpaceError	Error
  endif
  if !exists("python_no_doctest_highlight")
    HiLink pythonDoctest	Special
    HiLink pythonDoctestValue	Define
  endif

  delcommand HiLink
endif

"let b:current_syntax = "python"
let b:current_syntax = "keykit"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2 ts=8 noet:
