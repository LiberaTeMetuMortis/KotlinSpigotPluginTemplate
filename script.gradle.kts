open class MultiVersionPlugin : DefaultTask() {
    override fun getGroup() =  "application"
    override fun getDescription() = "Creates copies of project for diffrent Spigot versions"

    @Optional
    @get:Input
    @set:Option(
        option = "versions",
        description = "Configures versions that will built."
    )
    var versions: String? = null

    @TaskAction
    fun create() {
        val seperator = File.separator
        val dir = project.projectDir
        val rootDir = project.rootDir
        if(versions == null) versions = "all"
        val allVersions = arrayListOf(
            "1.19", "1.18", "1.17", "1.16.4", "1.15", "1.14",
            "1.13", "1.12", "1.11", "1.10", "1.9", "1.8"
        )
        var selectedVersions = versions!!.split(",")
        if(versions == "all") selectedVersions = allVersions
        val versionsToBuild = allVersions.filter { selectedVersions.contains(it) }
        for(version in versionsToBuild){
            //createVersionFolder(version)
            for(file in dir.listFiles()!!){
                if(file.name != "build.gradle.kts" && file.name != "build"){
                    val newFile = File("${rootDir}${seperator}project-${version}${seperator}${file.name}")
                    if(!newFile.exists()){
                        file.copyRecursively(newFile)
                        if(file.isDirectory && file.name == "src") {
                            val pluginFile = File(file.absolutePath + "${seperator}main${seperator}resources${seperator}plugin.yml")
                            if(pluginFile.exists()){
                                val newPluginFile = File("${rootDir}${seperator}project-${version}${seperator}${file.name}${seperator}main${seperator}resources${seperator}plugin.yml")
                                val content = pluginFile.readText().replace(Regex("(api-version: +)[\"'][0-9.]+[\"']"), "$1\"${version}\"")
                                newPluginFile.writeText(content)
                            }
                        }

                    }
                }

                else if(file.name == "build.gradle.kts"){
                    val newFile = File("${rootDir}${seperator}project-${version}${seperator}${file.name}")
                    if(!newFile.exists()){
                        file.copyRecursively(newFile)
                    }
                    val content = newFile.readText()
                    var newContent: String
                    if(version == "1.18" || version == "1.19"){
                        newContent = content.replace(Regex("(fun javaVersion\\(\\) *= *)\"[0-9]+\""), "$1 \"17\"")
                    }
                    else if(version == "1.17"){
                        newContent = content.replace(Regex("(fun javaVersion\\(\\) *= *)\"[0-9]+\""), "$1 \"16\"")
                    }
                    else if(version == "1.16"){
                        newContent = content.replace(Regex("(fun javaVersion\\(\\) *= *)\"[0-9]+\""), "$1 \"11\"")
                    }
                    else{
                        newContent = content.replace(Regex("(fun javaVersion\\(\\) *= *)\"[0-9]+\""), "$1 \"8\"")
                    }
                    /* 
                    if(version != "1.16") {
                        newContent = newContent.replace(Regex("\"org.spigotmc:spigot-api:.+-R0.1-SNAPSHOT\""), "\"org.spigotmc:spigot-api:$version-R0.1-SNAPSHOT\"")
                    }
                    else {
                        newContent = newContent.replace(Regex("\"org.spigotmc:spigot-api:.+-R0.1-SNAPSHOT\""), "\"org.spigotmc:spigot-api:1.16.4-R0.1-SNAPSHOT\"")
                    }
                    */
                    newFile.writeText(newContent)
                }
            }
        }
    }

    fun createVersionFolder(version: String){
        val rootDir = project.rootDir
        val folder = File(rootDir.path,"project-$version")
        if(!folder.exists()) folder.mkdirs()
    }
}
tasks.register<MultiVersionPlugin>("multiVersionPlugin")

open class moveBuilds : DefaultTask() {
    override fun getGroup() = "application"
    override fun getDescription() = "Moves all builds from all versions of project to root project's build folder"
    @TaskAction
    fun move(){
        val seperator = File.separator
        val rootDir = project.rootDir
        project.projectDir
        if(!File(rootDir.absolutePath,"builds").exists()) File(rootDir.absolutePath,"builds").mkdirs()
        rootDir.listFiles()!!.filter { it.name.matches(Regex("project-[0-9.]+")) }.forEach {
            val version = it.name.replace("project-", "")
            try{
                File(it.absolutePath+"${seperator}build${seperator}libs${seperator}").listFiles()?.find { x -> x.name.contains("-all.jar") }!!.copyTo(File(rootDir.absolutePath+"${seperator}build${seperator}$version.jar"))
            }catch (ignored: Exception){}
        }
    }
}

tasks.register<moveBuilds>("moveBuilds")
