# vim-snatch

Snatch texts, from Insert/Command mode, by motion.

## Concept

- Unnecessary to set any extra `:nmap`pings/`:omap`pings for `{motion}`.

- Acceptive of text-objects: `iw`, `a[`, ...

  (To be honest, since the feature works with `TextYankPost`,
  you have to type `yiw`, or `da[`, etc.,
  but it won't mess up your register or clipboard.)

- Friendly with the existing mappings of the fantastic plugins:

  - [easymotion/vim-easymotion](https://github.com/easymotion/vim-easymotion)
  - [deris/vim-shot-f](https://github.com/deris/vim-shot-f)
  - Text-objects of [machakann/vim-sandwich](https://github.com/machakann/vim-sandwich)
  - ...

## Installation

Install the plugin using your favorite package manager.

This is a sample configuration in TOML format
for [Dein](https://github.com/Shougo/dein.vim) users:

```toml
[[plugin]]
repo = 'kaile256/vim-snatch'
lazy = 1
on_event = ['CmdlineEnter', 'InsertEnter']
# Or uncomment below.
# on_map = {civ = ['<Plug>(snatch-']}
# hook_add = '''
#   xmap z: <Plug>(snatch-into-cmdline)
#   cmap <C-o> <Plug>(snatch-operator)
#
#   imap <C-y> <Plug>(snatch-reg-ctrl-y)
#   imap <C-e> <Plug>(snatch-reg-ctrl-e)
#   smap <C-y> <Plug>(snatch-reg-ctrl-y)
#   smap <C-e> <Plug>(snatch-reg-ctrl-e)
# '''
# hook_source = '''
#   let g:snatch#no_default_mappings = 1
# '''
```

## Usage

(The following options, mappings, and so on, are not all the features this
plugin provides.
Type `:h snatch`,
[doc/snatch.txt](https://github.com/kaile256/vim-snatch/blob/main/doc/snatch.txt)
will tell you more features and their details.)

### Options

```vim
" As long as the registers are used to snatch, this plugin will never override the register.
" Default: '0'
let g:snatch#clean_registers = '0"abc'

" default
let g:snatch#cmd#position_marker = '┃'
```

### Mappings

This plugin provides several `<Plug>`-mappings.
Each mappings will snatch text by either motion or intercepting it from the
register.

```vim
" Default mappings
xmap z: <Plug>(snatch-into-cmdline)
cmap <C-o> <Plug>(snatch-operator)

smap <C-y> <Plug>(snatch-oneshot-hor-or-reg-ctrl-y)
smap <C-e> <Plug>(snatch-oneshot-hor-or-reg-ctrl-e)

" **Notice**
" * When pumvisible() returns 1, <C-y> and <C-e> should behave as you read at
"   each CTRL-Y and CTRL-E in `:h popupmenu-keys`; thus, <expr> will be needed.
" * The mapping examples after the default ones below will be written without
"   this <expr>-workaround for pumvisible as the workaround is understood.
" * `<SID>` lets you map both <C-y>/<C-e> non-recursively and
"   <Plug>(snatch-mapping) recursively to the same {rhs}. (Practically, you can
"   omit this <SID>-workaround here as {lhs} is the very same key of {rhs}.)
inoremap <SID>(C-y) <C-y>
inoremap <SID>(C-e) <C-e>
imap <expr> <C-y> pumvisible() ? '<SID>(C-y)' : '<Plug>(snatch-oneshot-hor-or-reg-ctrl-y)'
imap <expr> <C-e> pumvisible() ? '<SID>(C-e)' : '<Plug>(snatch-oneshot-hor-or-reg-ctrl-e)'
```

Or define mappings as your preference.

```vim
let g:snatch#no_default_mappings = 1

" Or you can predefine the first {motion}.
imap <C-y> <Plug>(snatch-oneshot-hor-or-reg-ctrl-y)<Plug>(easymotion-f)
imap <C-y> <Plug>(snatch-horizontal-ctrl-y)<Plug>(shot-f)

" Use some tricks for non-recursive {motion}.
onoremap <SID>f f
imap <C-y> <Plug>(snatch-horizontal-ctrl-y)<SID>f

" We have another kind of mappings to start sneaking right at the spot.
" It may be useful with the motions that assumes twice a {motion} or more.
imap <C-y> <Plug>(snatch-reg-here)<Plug>(easymotion-s)
imap <C-y> <Plug>(snatch-oneshot-hor-or-reg-here)<Plug>(easymotion-s)

" Suggestion:
" You might enjoy the trick to experience snatch-operator from Insert mode.
let g:snatch#clean_registers = '0' " (default)
imap <C-y> <Plug>(snatch-reg-ctrl-y)y
" Or use <SID> if your `y` could be mapped:
inoremap <SID>y y
imap <SID>(snatch-operator-ctrl-y) <Plug>(snatch-reg-ctrl-y)<SID>y
imap <C-y> <SID>(snatch-operator-ctrl-y)
```
