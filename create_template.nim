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

# Get zip buffer from GitHub.
let client = newHttpClient()
let content = client.getContent("https://github.com/LiberaTeMetuMortis/KotlinSpigotPluginTemplate/zipball/raw")

# Write zip buffer to file.
try:
  writeFile("content.zip", content)
except:
  echo "Failed to write zip buffer to content.zip"
  quit(1)

# Extract zip file.
try:
  extractAll("content.zip", "unzipped")
except:
  echo "Failed to extract zip file content.zip to unzipped"
  quit(1)

# Remove zip file.
try:
  removeFile("content.zip")
except:
  echo "Failed to remove content.zip"
  quit(1)

# Find Template directory.
for file in walkDir("./unzipped"):
  if match(file.path, peg"unzipped\/LiberaTeMetuMortis\-KotlinSpigotPluginTemplate\-.+"):
    # Move Template directory to the main folder.
    try:
      moveDir(file.path, artifactID)
    except OSError:
      echo "You already have a directory named ", artifactID
      quit(1)

# Remove unzipped folder.
try:
  removeDir("unzipped")
except:
  echo "Couldn't remove unzipped directory."
  quit(1)

# Create project's group directory.
let replacedGroupID = replace(groupID, '.', '/')
let projectDir = artifactID&"/project/src/main/kotlin/"&replacedGroupID
try:
  createDir(projectDir)
except:
  echo "Couldn't create "&projectDir
  quit(1)

# Create main file of the project.
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

try: 
  writeFile(projectDir&"/"&artifactID&".kt", contentOfMain)
except: 
  echo "Couldn't write into "&projectDir&"/"&artifactID&".kt"
  quit(1)

# Write artifact and group ID into build.gradle.kts.
var pluginConfig: File
if open(pluginConfig, artifactID&"/project/src/main/resources/plugin.yml", FileMode.fmAppend):
  writeLine(pluginConfig, "name: \""&artifactID&"\"")
  writeLine(pluginConfig, "main: \""&groupID&artifactID&"\"")
else:
  echo "Couldn't open plugin.yml"
  quit(1)

# Write artifact ID and root project name into settings.gradle.kts.
var gradleConfig: File
if open(gradleConfig, artifactID&"/settings.gradle.kts", FileMode.fmAppend):
  writeLine(gradleConfig, "rootProject.name = "&"\""&artifactID&"\"")
else:
  echo "Couldn't open settings.gradle.kts"
  quit(1)
