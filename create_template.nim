import std/httpclient
import zippy/ziparchives
import std/[os,pegs,strutils,terminal]
proc ctrlc() {.noconv.} =
  quit(0)
setControlCHook(ctrlc)

var groupID: string
var artifactID: string
var apiVersion: string

if existsEnv("DEFAULT_GROUP_ID"):
  groupID = getEnv("DEFAULT_GROUP_ID")
else:
  if existsEnv("GROUP_ID"):
    groupID = getEnv("GROUP_ID")
  else:
    stdout.write("Enter your project's group ID: ")
    groupID = readLine(stdin)

if existsEnv("ARTIFACT_ID"):
  artifactID = getEnv("ARTIFACT_ID")
else:
  stdout.write("Enter your artifact ID: ")
  artifactID = readLine(stdin)

if existsEnv("DEFAULT_GROUP_ID"):
  stdout.styledWriteLine(fgGreen, "Using default group ID: "&groupID&"."&toLower(artifactID))
  groupID = groupID&"."&toLower(artifactID)

if existsEnv("DEFAULT_API_VERSION"):
  apiVersion = getEnv("DEFAULT_API_VERSION")
else:
  if existsEnv("API_VERSION"):
    apiVersion = getEnv("API_VERSION")
  else:
    stdout.write("Enter your project's Minecraft (API) version: ")
    apiVersion = readLine(stdin)


# Get zip buffer from GitHub.
let client = newHttpClient()
let content = client.getContent("https://github.com/LiberaTeMetuMortis/KotlinSpigotPluginTemplate/zipball/raw")
stdout.styledWriteLine(fgGreen, "Downloaded zip file from GitHub.")

# Write zip buffer to file.
try:
  writeFile("content.zip", content)
  stdout.styledWriteLine(fgGreen, "Wrote zip file to content.zip.")
except:
  stdout.styledWriteLine(fgRed, "Failed to write zip buffer to content.zip.")
  quit(1)

# Extract zip file.
try:
  extractAll("content.zip", "unzipped")
  stdout.styledWriteLine(fgGreen, "Extracted content.zip to unzipped directory.")
except:
  stdout.styledWriteLine(fgRed, "Failed to extract content.zip to unzipped.")
  quit(1)

# Remove zip file.
try:
  removeFile("content.zip")
  stdout.styledWriteLine(fgGreen, "Removed content.zip file.")
except:
  stdout.styledWriteLine(fgRed, "Failed to remove content.zip.")
  quit(1)

# Find Template directory.
for file in walkDir("./unzipped"):
  if match(file.path, peg"unzipped[\/\\]LiberaTeMetuMortis\-KotlinSpigotPluginTemplate\-.+"):
    # Move Template directory to the main folder.
    try:
      moveDir(file.path, artifactID)
      stdout.styledWriteLine(fgGreen, "Moved Template directory to the main folder.")
  
    except OSError:
      stdout.styledWriteLine(fgRed, "You already have a directory named "&artifactID&".")
  
      quit(1)

# Remove unzipped folder.
try:
  removeDir("unzipped")
  stdout.styledWriteLine(fgGreen, "Removed unzipped folder.")
except:
  stdout.styledWriteLine(fgRed, "Couldn't remove unzipped directory.")
  quit(1)

# Create project's group directory.
let replacedGroupID = replace(groupID, '.', '/')
let projectDir = artifactID&"/project/src/main/kotlin/"&replacedGroupID
try:
  createDir(projectDir)
  stdout.styledWriteLine(fgGreen, "Created project's group directory.")
except:
  stdout.styledWriteLine(fgRed, "Couldn't create "&projectDir&" directory.")
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
  stdout.styledWriteLine(fgGreen, "Created main file of the project.")
except: 
  stdout.styledWriteLine(fgRed, "Couldn't write into "&projectDir&"/"&artifactID&".kt.")
  quit(1)

# Write artifact, group IDs and api-version into plugin.yml.
var pluginConfig: File
if open(pluginConfig, artifactID&"/project/src/main/resources/plugin.yml", FileMode.fmAppend):
  writeLine(pluginConfig, "name: \""&artifactID&"\"")
  writeLine(pluginConfig, "main: \""&groupID&artifactID&"\"")
  writeLine(pluginConfig, "api-version: \""&apiVersion&"\"")
  stdout.styledWriteLine(fgGreen, "Wrote artifact and group ID into plugin.yml.")
else:
  stdout.styledWriteLine(fgRed, "Couldn't open plugin.yml.")
  quit(1)

# Write artifact ID and root project name into settings.gradle.kts.
var gradleConfig: File
if open(gradleConfig, artifactID&"/settings.gradle.kts", FileMode.fmAppend):
  writeLine(gradleConfig, "rootProject.name = "&"\""&artifactID&"\"")
  stdout.styledWriteLine(fgGreen, "Wrote artifact ID and root project name into settings.gradle.kts.")
else:
  stdout.styledWriteLine(fgRed, "Couldn't open settings.gradle.kts.")
  quit(1)
