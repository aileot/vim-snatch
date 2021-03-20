# vim-snatch

Snatch texts, from Insert mode, by horizontal motion or by `TextYankPost`.

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
on_event = ['InsertEnter']
# Or uncomment below.
# on_map = {i = ['<Plug>(snatch-']}
# hook_add = '''
#   imap <C-y> <Plug>(snatch-reg-ctrl-y)
#   imap <C-e> <Plug>(snatch-reg-ctrl-e)
# '''
# hook_source = '''
#   let g:snatch#no_default_mappings = 1
# '''
```

## Usage

### Options

```vim
" As long as the registers are used to snatch, this plugin will never override the register.
" Default: '0'
let g:snatch#clean_registers = '0"abc'
```

### Mappings

This plugin provides several `<Plug>`-mappings.
Each mappings will snatch text by either motion or intercepting it from the
register.
Read `doc/snatch.txt` for more details.

```vim
" Default mappings
imap <C-y> <Plug>(snatch-reg-horizontal-ctrl-y)
imap <C-e> <Plug>(snatch-reg-horizontal-ctrl-e)
```

Or define mappings as your preference.

```vim
let g:snatch#no_default_mappings = 1

" Or you can predefine the first `{motion}`.
imap <C-y> <Plug>(snatch-reg-horizontal-ctrl-y)<Plug>(easymotion-f)
imap <C-y> <Plug>(snatch-horizontal-ctrl-y)<Plug>(shot-f)

" Use some tricks for non-recursive {motion}.
onoremap <SID>f f
imap <C-y> <Plug>(snatch-horizontal-ctrl-y)<SID>f

" We have another kind of mappings to start sneaking right at the spot.
" It may be useful with the motions that assumes twice a `{motion}` or more.
imap <C-y> <Plug>(snatch-reg-here)<Plug>(easymotion-s)
imap <C-y> <Plug>(snatch-reg-horizontal-here)<Plug>(easymotion-s)

" Suggestion:
" You might enjoy the trick that snatch texts as soon as cursor has moved.
imap <C-y> <Plug>(snatch-reg-ctrl-y)y
" Or name the mapping, using <SID>:
inoremap <SID>y y
imap <SID>(snatch-sensitive-ctrl-y) <Plug>(snatch-reg-ctrl-y)<SID>y
imap <C-y> <SID>(snatch-sensitive-ctrl-y)
```
