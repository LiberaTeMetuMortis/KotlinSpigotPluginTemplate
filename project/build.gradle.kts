import com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar
/*
 * This file was generated by the Gradle 'init' task.
 *
 * This generated file contains a sample Kotlin application project to get you started.
 * For more details take a look at the 'Building Java & JVM projects' chapter in the Gradle
 * User Manual available at https://docs.gradle.org/7.5/userguide/building_java_projects.html
 */
var pluginMainClass = ""
var pluginName = ""
var pluginAPIVersion = ""
File("${projectDir.absoluteFile}/src/main/resources/plugin.yml").forEachLine { line ->
    with(line){
        when {
            matches(Regex("^version: .+$")) -> project.version = replace(Regex("version: "), "").replace("\"", "").replace("'", "")
            matches(Regex("^name: .+$")) -> pluginName = replace(Regex("name: "), "").replace("\"", "").replace("'", "")
            matches(Regex("^main: .+$")) -> pluginMainClass = replace(Regex("main: "), "").replace("\"", "").replace("'", "")
            matches(Regex("^api-version: .+$")) -> pluginAPIVersion = replace(Regex("api-version: "), "").replace("\"", "").replace("'", "")
        }
    }
}

plugins {
    // Apply the org.jetbrains.kotlin.jvm Plugin to add support for Kotlin.
    id("com.github.johnrengelman.shadow") version "7.1.2"
    kotlin("jvm") version "1.7.20"

    // Apply the application plugin to add support for building a CLI application in Java.
    application
    java
}

apply(from="../script.gradle.kts")

repositories {
    // Use Maven Central for resolving dependencies.
    mavenCentral()
    maven("https://hub.spigotmc.org/nexus/content/repositories/public/")
    maven("https://repo.extendedclip.com/content/repositories/placeholderapi/")
}

dependencies {
    // Use the Kotlin standard library.
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.7.20")

    // You can add dependencies like this
    compileOnly(group="me.clip", name="placeholderapi", version="2.11.1")

    // Or like this
    compileOnly("org.spigotmc:spigot-api:$pluginAPIVersion-R0.1-SNAPSHOT")
}

application {
    // Define the main class for the application.
    mainClass.set(pluginMainClass)
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
        jvmTarget = javaVersion().replace("8", "1.8")
    }
}

java {
    sourceCompatibility = JavaVersion.valueOf("VERSION_${javaVersion().replace("8", "1_8")}")
    targetCompatibility = JavaVersion.valueOf("VERSION_${javaVersion().replace("8", "1_8")}")
}


tasks.withType<Jar> {
    archiveFileName.set("${pluginName}-${project.version}.jar")
    manifest {
        attributes["Main-Class"] = pluginMainClass
    }

}

tasks.withType<ShadowJar>{
    archiveFileName.set("${pluginName}-${project.version}-all.jar")
}

fun javaVersion() = "17"