#!/usr/bin/env groovy

/**
 * Created by Clifton Craig on 12/29/15.
 * Copyright 12/29/15
 */

def destroyers = []

def makeDestroyersFor = { theType ->
    def output = "cf $theType".execute().text
//Delete all apps
    def foundName
    output.eachLine {
        if(! foundName) { foundName = it.startsWith("name"); return }
        def name = it.split()[0]
        if(!name.contains('uaa-service')) {
            def out = new StringBuffer(); def err = new StringBuffer()
            def process = ["bash", "-c", "YES | cf delete${theType == 'services' ? '-service' : ''} $name"].execute()
            process.consumeProcessOutput(out, err)
            destroyers << [name:name, process:process, out:out, err:err]
            println "Destroying $name " + destroyers.size()
        }
    }
}

makeDestroyersFor('apps')
makeDestroyersFor('services')
println("Destroying: " + destroyers.join(", "))
//wait for app destroyers
destroyers.each {
    println("Waiting for ${it.name}")
    try { it.process.waitFor() }
    catch (Exception e) { println("Exception $e") }
}
