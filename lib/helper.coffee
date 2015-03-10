sleet = require 'sleet'
handlebars = require 'sleet-handlebars'
path = require 'path'
fs = require 'fs'

config = exports.sleetConfig = (key) -> atom.config.get "atom-sleet.#{key}"

exports.isSleet = (editor) -> editor.getGrammar().scopeName is 'source.sleet'

exports.haveCompiledFile = (file) ->
    dir = path.dirname file
    filename = path.basename file
    name = path.basename file, path.extname(file)
    for file in fs.readdirSync dir when file isnt filename
        ext = path.extname file
        return true if path.basename(file, ext) is name and (ext is '.html' or ext is '.js')
    return false

exports.compileToFile = (editor) ->
    compiled = compileIt editor
    file = editor.getPath()
    target = path.join path.dirname(file), path.basename(file, path.extname(file)) + '.' + compiled.ext
    fs.writeFileSync target, compiled.result, 'utf-8'

exports.compileToEditor = (source, dest) ->
    try
        compiled = compileIt source
    catch e
        compiled = result: e.stack

    dest.setText compiled.result
    if compiled.ext
        dest.setGrammar atom.grammars.selectGrammar("hello.#{compiled.ext}")

compileIt = (editor) ->
    text = editor.getText()
    file = editor.getPath()

    if config('compileUse') is 'sleet-handlebars'
        handlebarsCompile text, file
    else
        sleetCompile text, file

sleetCompile = (input, file) ->
    result: sleet.compile input, filename: file
    ext: 'html'

handlebarsCompile = (input, file) ->
    precompile = config 'handlebarsPrecompile'
    amd = config 'handlebarsPrecompileUseAmd'
    commonjs = config 'handlebarsPrecompileUseCommonJs'

    options =
        filename: file
        blocks: config 'handlebarsBlockHelpers'
        inlineBlocks: config 'handlebarsInlineHelpers'

    if precompile
        options.precompile =
            amd: amd
            commonjs: if commonjs then 'handlebars' else false
            name: path.basename file

    result: handlebars.compile input, options
    ext: if precompile then 'js' else 'html'
