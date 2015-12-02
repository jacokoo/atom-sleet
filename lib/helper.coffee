sleet = require 'sleet'
handlebars = require 'sleet-handlebars'
path = require 'path'
fs = require 'fs'

exports.isSleet = (editor) -> editor.getGrammar().scopeName is 'source.sleet'

exports.haveCompiledFile = (file) ->
    dir = path.dirname file
    filename = path.basename file
    name = path.basename file, path.extname(file)
    for file in fs.readdirSync dir when file isnt filename
        ext = path.extname file
        return true if path.basename(file, ext) is name
    return false

exports.compileToFile = (editor) ->
    try
        compiled = compileIt editor
    catch e
        return e

    file = editor.getPath()
    target = path.join path.dirname(file), path.basename(file, path.extname(file)) + '.' + compiled.extension
    fs.writeFileSync target, compiled.content, 'utf-8'
    true

exports.compileToEditor = (source, dest) ->
    try
        compiled = compileIt source
    catch e
        compiled = content: e.stack

    dest.setText compiled.content
    if compiled.extension
        dest.setGrammar atom.grammars.selectGrammar("hello.#{compiled.extension}")

compileIt = (editor) ->
    text = editor.getText()
    file = editor.getPath()

    sleetCompile text, file

getPackageConfig = (file) ->
    root = path.resolve path.dirname(file)
    while path.dirname(root) isnt root
        pkg = path.join(root, 'package.json')
        if fs.existsSync(pkg)
            console.log require(pkg)
            return require(pkg)?.sleet
        root = path.dirname(root)
    null

sleetCompile = (input, file) ->
    options = getPackageConfig(file) or {}
    options.filename = file
    sleet.compile input, options
