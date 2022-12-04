import std/httpclient
import zip/zipfiles
import std/[os,pegs,strutils]
proc ctrlc() {.noconv.} =
  quit(0)
setControlCHook(ctrlc)
stdout.write("Enter your project's group ID: ")
let groupID = readLine(stdin)
stdout.write("Enter your artifact ID: ")
let artifactID = readLine(stdin)
let client = newHttpClient()
let content = client.getContent("https://github.com/LiberaTeMetuMortis/KotlinSpigotPluginTemplate/zipball/raw")
var zippedContent: ZipArchive
zippedContent.fromBuffer(content)
zippedContent.extractAll(".")
for file in walkDir("."):
  if match(file.path, peg"\.\/LiberaTeMetuMortis\-KotlinSpigotPluginTemplate\-.+"):
    try:
      moveDir(file.path, artifactID)
    except OSError:
      echo "You already have a directory named ", artifactID
let replacedGroupID = replace(groupID, '.', '/')
let projectDir = artifactID&"/project/src/main/kotlin/"&replacedGroupID
createDir(projectDir)
let contentOfMain = "package "&groupID&"""


import org.bukkit.plugin.java.JavaPlugin

class Main : JavaPlugin() {
    override fun onEnable() {
        TODO("Plugin startup logic")
    }

    override fun onDisable() {
        TODO("Plugin shutdown logic")
    }
}
"""
writeFile(projectDir&"/"&artifactID&".kt", contentOfMain)
var pluginConfig: File
if open(pluginConfig, artifactID&"/project/src/main/resources/plugin.yml", FileMode.fmAppend):
  writeLine(pluginConfig, "name: \""&artifactID&"\"")
  writeLine(pluginConfig, "main: \""&groupID&artifactID&"\"")
var gradleConfig: File
if open(gradleConfig, artifactID&"/settings.gradle.kts", FileMode.fmAppend):
  writeLine(gradleConfig, "rootProject.name = "&"\""&artifactID&"\"")
