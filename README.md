# vim-operator-copy

vim-operator-copy replaces `i_CTRL-E`/`i_CTRL-Y`.
Most of the `{motion}`s are available,
including those defined by `:omap`/`:onoremap`.

## Features

- Accept text-objects: `iw`, `a[`, ...
- No extra `:omap`pings, thus, available with other plugins:

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

```vim
" Default mappings
imap <C-y> <Plug>(operator-copy-ctrl-y)
imap <C-e> <Plug>(operator-copy-ctrl-e)

" Uncomment below if you want to disable the default mappings above.
" let g:operator_copy#no_default_mappings = 1
```
