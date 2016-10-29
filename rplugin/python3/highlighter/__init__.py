# FILE: highlighter.py
# AUTHOR: Keita Nakamura
# License: MIT license


import os
import re
import subprocess
import neovim


@neovim.plugin
class Highlighter:

    def __init__(self, vim):
        self.vim = vim
        self.is_started = False

    def init_members(self):
        self.vim.call('g:highlighter#initialize')
        self.is_started = True
        self.project_root_signs = self.vim.eval('g:highlighter#project_root_signs')
        self.ctags_options = self.vim.eval('g:highlighter#ctags_options')
        self.syntax = self.vim.eval('g:highlighter#syntax')

    @neovim.command("HighlighterUpdate", range='', nargs='*')
    def update(self, args, range):
        self.is_started or self.init_members()

        ftype = self.vim.eval('&filetype')
        if ftype == '' or not ftype in self.syntax:
            return

        # make ctags options
        proot = self.find_project_root()
        lang = 'c++' if ftype == 'cpp' else ftype
        lang = 'c#'  if ftype == 'cs'  else ftype
        ctags_options = self.ctags_options + ['--languages='+lang, proot]
        os.path.isdir(proot) and ctags_options.insert(0, '-R')

        commands = self.make_syntax_commands(ctags_options, ftype)
        clear_commands = self.make_syntax_clear_commands(ftype)
        self.vim.call("highlighter#update_highlight", [clear_commands+' | '+commands, proot, ftype])
        self.vim_echo("Highlighter: updated")

    @neovim.command("HighlighterClear", range='', nargs='*')
    def clear(self, args, range):
        ftype = self.vim.eval('&filetype')
        proot = self.find_project_root()
        clear_commands = self.make_syntax_clear_commands(ftype)
        self.vim.call("highlighter#update_highlight", [clear_commands, proot, ftype])
        self.vim_echo("Highlighter: cleared")

    def find_project_root(self):
        fname = self.vim.current.buffer.name
        if len(self.project_root_signs) != 0:
            proot = os.path.dirname(fname)
            for sign in self.project_root_signs:
                candidate = proot
                while candidate != '/':
                    if os.path.exists(candidate+'/'+sign):
                        return candidate
                    candidate = os.path.dirname(candidate)
        return fname

    def make_tags_data(self, ctags_options):
        cmd = ['ctags', '-f', '-', '--sort=no', '--excmd=number'] + ctags_options
        try:
            lines = subprocess.check_output(cmd).decode().split('\n')
            lines.pop()
        except:
            lines = []

        names = []
        kinds = []
        for line in lines:
            entries = line.split('\t')
            names.append(entries[0])
            kinds.append(entries[3])

        dict = {}
        for k in set(kinds):
            dict[k] = set(names[i] for i,x in enumerate(kinds) if x == k)
        return dict

    def make_syntax_commands(self, ctags_options, ftype):
        tags = self.make_tags_data(ctags_options)

        commands = []
        syntax = self.syntax[ftype]
        r = re.compile(r'[.*^$/\\~\[\]]')
        escape = lambda x: r.sub(r'\\\g<0>', x)
        for s in syntax:
            commands.append("syntax clear " + s['hlgroup'])
            for key in s['tagkinds']:
                if key in tags:
                    if s['syntax_type'] == 'keyword':
                        keywords = ' '.join(tags[key])
                        template = 'syntax keyword {} {} containedin=ALLBUT,{}'
                        cmd = template.format(s['hlgroup'], keywords, s['syntax_ignore'])
                    elif s['syntax_type'] == 'match':
                        escaped = map(escape, tags[key])
                        keywords = s['syntax_prefix'] + '\%(' + '\|'.join(escaped) + '\)' + s['syntax_suffix']
                        template = 'syntax match {} /{}/ containedin=ALLBUT,{}'
                        cmd = template.format(s['hlgroup'], keywords, s['syntax_ignore'])
                    commands.append(cmd)
        return ' | '.join(commands)

    def make_syntax_clear_commands(self, ftype):
        commands = []
        for s in self.syntax[ftype]:
            commands.append("syntax clear " + s['hlgroup'])
        return ' | '.join(commands)

    def vim_echo(self, message):
        self.vim.command("echo '{}'".format(message))
