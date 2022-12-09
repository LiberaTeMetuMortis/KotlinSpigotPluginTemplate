import std/httpclient
import zippy/ziparchives
import std/[os,pegs,strutils,terminal]
proc ctrlc() {.noconv.} =
  quit(0)
setControlCHook(ctrlc)

var groupID: string
var artifactID: string
var apiVersion: string
var javaVersion: string

proc deleteMain() =
  try:
    removeDir(artifactID)
  except:
    stdout.styledWriteLine(fgRed, "Couldn't remove "&artifactID&" directory.")

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

if existsEnv("DEFAULT_JAVA_VERSION"):
  javaVersion = getEnv("DEFAULT_JAVA_VERSION")
else:
  if existsEnv("JAVA_VERSION"):
    javaVersion = getEnv("JAVA_VERSION")
  else:
    stdout.write("Enter your project's target Java version: ")
    javaVersion = readLine(stdin)


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
  try:
    removeFile("content.zip")
    removeDir("unzipped")
  except:
    stdout.styledWriteLine(fgRed, "Failed to remove content.zip and unzipped directory.")
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
      try:
        removeDir("unzipped")
      except:
        stdout.styledWriteLine(fgRed, "Failed to remove unzipped directory.")
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
  deleteMain()
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
  deleteMain()
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
  deleteMain()
  stdout.styledWriteLine(fgRed, "Couldn't open plugin.yml.")
  quit(1)

# Write artifact ID and root project name into settings.gradle.kts.
var gradleConfig: File
if open(gradleConfig, artifactID&"/settings.gradle.kts", FileMode.fmAppend):
  writeLine(gradleConfig, "rootProject.name = "&"\""&artifactID&"\"")
  stdout.styledWriteLine(fgGreen, "Wrote artifact ID and root project name into settings.gradle.kts.")
else:
  deleteMain()
  stdout.styledWriteLine(fgRed, "Couldn't open settings.gradle.kts.")
  quit(1)

# Write java version into build.gradle.kts.
var buildGradleConfig: File
if open(buildGradleConfig, artifactID&"/project/build.gradle.kts", FileMode.fmAppend):
  writeLine(buildGradleConfig, "fun javaVersion() = \""&javaVersion&"\"")
  stdout.styledWriteLine(fgGreen, "Wrote java version into build.gradle.kts.")
else:
  deleteMain()
  stdout.styledWriteLine(fgRed, "Couldn't open build.gradle.kts.")
  quit(1)