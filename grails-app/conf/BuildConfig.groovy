grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"

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

    plugins {
        build ":tomcat:7.0.55"
        build ":release:3.0.1"
        runtime(":hibernate4:4.3.6.1") {
            excludes "net.sf.ehcache:ehcache-core"
            // remove this when http://jira.grails.org/browse/GPHIB-18 is resolved
            export = false
        }

        test(":codenarc:0.22") { export = false }

        compile ":decorator:1.1"
        compile ":user-tag:0.6"
        compile ":selection:0.9.8"

        compile ":crm-invoice:2.4.0-SNAPSHOT"
        compile ":crm-security:2.4.1"
        compile ":crm-ui-bootstrap:2.4.0"
    }
}
