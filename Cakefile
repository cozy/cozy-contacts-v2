fs     = require 'fs'
{exec} = require 'child_process'
logger = require('printit')
            date: false
            prefix: 'cake'

option '-f' , '--file [FILE*]' , 'test file to run'
option ''   , '--dir [DIR*]'   , 'directory where to grab test files'
option '-j' , '--use-js', 'If enabled, tests will run with the built files'

options =  # defaults, will be overwritten by command line options
    file        : no
    dir         : no

# Grab test files of a directory
walk = (dir, fileList) ->
    list = fs.readdirSync(dir)
    if list
        for file in list
            if file
                filename = dir + '/' + file
                stat = fs.statSync(filename)
                if stat and stat.isDirectory()
                    walk(filename, fileList)
                else if filename.substr(-6) == "coffee"
                    fileList.push(filename)
    return fileList

task 'tests', 'run server tests, ./test is parsed by default, otherwise use -f or --dir', (opts) ->
    options   = opts
    testFiles = []
    if options.dir
        dirList   = options.dir
        testFiles = walk(dir, testFiles) for dir in dirList
    if options.file
        testFiles  = testFiles.concat(options.file)
    if not(options.dir or options.file)
        testFiles = walk("tests", [])
    runTests testFiles

task 'tests:client', 'run client tests through mocha', (opts) ->
    exec "mocha-phantomjs client/_specs/index.html", (err, stdout, stderr) ->
        if err
            console.log "Running mocha caught exception: \n" + err
        console.log stdout


runTests = (fileList) ->
    env = "NODE_ENV=test"
    env += " USE_JS=true" if options['use-js']? and options['use-js']

    command = "#{env} mocha " + fileList.join(" ") + " "
    command += " --globals setImmediate,clearImmediate"
    command += " --reporter spec --compilers coffee:coffee-script/register --colors"
    exec command, (err, stdout, stderr) ->
        console.log stdout if stdout? and stdout.length > 0
        #console.log stderr if stderr? and stderr.length > 0
        if err?
            console.log "Running mocha caught exception:\n"
            console.log err
            console.log stderr
            setTimeout (-> process.exit 1), 100
        else
            console.log "Tests succeeded!"
            setTimeout (-> process.exit 0), 100

buildJade = ->
    jade = require 'jade'
    path = require 'path'
    for file in fs.readdirSync './server/views/'
        return unless path.extname(file) is '.jade'
        filename = "./server/views/#{file}"
        template = fs.readFileSync filename, 'utf8'
        output = "var jade = require('jade/runtime');\n"
        output += "module.exports = " + jade.compileClient template, {filename}
        name = file.replace '.jade', '.js'
        fs.writeFileSync "./build/server/views/#{name}", output

# convert JSON lang files to JS
buildJsInLocales = ->
    path = require 'path'
    for file in fs.readdirSync './client/app/locales/'
        filename = './client/app/locales/' + file
        template = fs.readFileSync filename, 'utf8'
        exported = "module.exports = #{template};\n"
        name     = file.replace '.json', '.js'
        fs.writeFileSync "./build/client/app/locales/#{name}", exported


task 'build', 'Build CoffeeScript to Javascript', ->
    logger.options.prefix = 'cake:build'
    logger.info "Start compilation..."
    command = "coffee -cb --output build/server server && " + \
              "coffee -cb --output build/ server.coffee && " + \
              "rm -rf build/client && mkdir build/client && " + \
              "mkdir -p build/server/views && " + \
              "mkdir -p build/client/app/locales/ && " + \
              "rm -rf build/client/app/locales/* && " + \
              "rm -rf client/app/locales/*.coffee && " + \
              "cd client/ && brunch build --production && cd .. &&" + \
              "cp -R client/public build/client/"
    exec command, (err, stdout, stderr) ->
        if err
            logger.error "An error has occurred while compiling:\n" + err
            process.exit 1
        else
            buildJade()
            buildJsInLocales()
            logger.info "Compilation succeeded."
            process.exit 0
