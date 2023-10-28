grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"

grails.project.fork = [
    //  compile: [maxMemory: 256, minMemory: 64, debug: false, maxPerm: 256, daemon:true],
    test: [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256, forkReserve:false],
    run: [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256, forkReserve:false],
    war: [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256, forkReserve:false],
    console: [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256]
]

grails.project.dependency.resolver = "maven"
grails.project.dependency.resolution = {
    inherits("global") {}
    log "warn"
    legacyResolve false
    repositories {
        mavenLocal()
        grailsCentral()
        mavenCentral()
    }

    dependencies {
        // See https://jira.grails.org/browse/GPHIB-30
        test("javax.validation:validation-api:1.1.0.Final") { export = false }
        test("org.hibernate:hibernate-validator:5.0.3.Final") { export = false }
    }

    plugins {
        build(":release:3.1.2",
                ":rest-client-builder:2.1.1") {
            export = false
        }
        test(":hibernate4:4.3.6.1") {
            export = false
        }

        test(":codenarc:0.24.1") { export = false }
        test(":code-coverage:2.0.3-3") { export = false }

        compile ":decorator:1.1.1"
        compile ":user-tag:1.0.1"
        compile ":selection:0.9.9"

        compile ":crm-invoice:2.4.2"
        compile ":crm-security:2.4.5"
        compile ":crm-ui-bootstrap:2.4.4"
    }
}

codenarc.reports = {
    xmlReport('xml') {
        outputFile = 'target/CodeNarcReport.xml'
    }
    htmlReport('html') {
        outputFile = 'target/CodeNarcReport.html'
    }
}
