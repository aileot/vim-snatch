# vim-operator-copy

vim-operator-copy replaces `i_CTRL-E`/`i_CTRL-Y`.
Most of the `{motion}`s are available,
including those defined by `:nmap`/`:nnoremap`.

## Features

- Accept text-objects: `iw`, `a[`, ...
  (To be honest, since the feature uses TextYankPost,
  you have to type `yiw`, or `da[`, etc.)

- Provide no extra `:nmap`pings/`:omap`pings for {motion}.
  Thus, this plugin is hardly interfered with other mappings, but highly
  customizable with the existing fantastic plugins:

  - [easymotion/vim-easymotion](https://github.com/easymotion/vim-easymotion)
  - [deris/vim-shot-f](https://github.com/deris/vim-shot-f)
  - Text-objects of [machakann/vim-sandwich](https://github.com/machakann/vim-sandwich)
  - ...

- Let us select a line to copy until the cursor moves horizontally or
  `TextYankPost` is triggered.
  Thus, this plugin will be more convenient with a sort of easymotion.

## Installation

Install the plugin using your favorite package manager.

This is a sample configuration in TOML format
for [Dein](https://github.com/Shougo/dein.vim) users:

```toml
[[plugin]]
repo = 'kaile256/vim-operator-copy'
lazy = 1
on_event = ['InsertEnter']
# Or uncomment below.
# on_map = {i = [
#  '<Plug>(operator-copy-ctrl-e)',
#  '<Plug>(operator-copy-ctrl-y)',
# ]}
```

## Usage

### Mappings

```vim
" Default mappings
imap <C-y> <Plug>(operator-copy-ctrl-y)
imap <C-e> <Plug>(operator-copy-ctrl-e)
```

Or you can predefine the first `{motion}`.

```vim
let g:operator_copy#no_default_mappings = 1

imap <C-y> <Plug>(operator-copy-ctrl-y)<Plug>(easymotion-f)
imap <C-y> <Plug>(operator-copy-ctrl-y)<Plug>(shot-f)

" Use some tricks for non-recursive {motion}.
onoremap <SID>f f
imap <C-y> <Plug>(operator-copy-ctrl-y)<SID>f
```

We have another mapping, `<Plug>(operator-copy-here)`.
It may be useful with the motions that assumes twice a `{motion}` or more.

```vim
imap <C-y> <Plug>(operator-copy-here)<Plug>(easymotion-s)
```

### Options

```vim
" While the registers are used to copy, this plugin will never override the
" register.
" Default: '0'
let g:operator_copy#clean_registers = '0"abc'

```
