import std/httpclient
import zippy/ziparchives
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
writeFile("content.zip", content)
extractAll("content.zip", "unzipped")
removeFile("content.zip")
for file in walkDir("./unzipped"):
  echo file.path
  if match(file.path, peg"unzipped[\/\\]LiberaTeMetuMortis\-KotlinSpigotPluginTemplate\-.+"):
    echo "Dosya bulundu."
    try:
      moveDir(file.path, artifactID)
    except OSError:
      echo "You already have a directory named ", artifactID
removeDir("unzipped")
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
