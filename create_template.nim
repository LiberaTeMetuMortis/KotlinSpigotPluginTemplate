import std/httpclient
import zippy/ziparchives
import std/[os,pegs,strutils,terminal]
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
stdout.styledWriteLine(fgGreen, "Downloaded zip file from GitHub.")

# Write zip buffer to file.
try:
  writeFile("content.zip", content)
  stdout.styledWriteLine(fgGreen, "Wrote zip file to content.zip.")
  stdout.resetAttributes()
except:
  stdout.styledWriteLine(fgRed, "Failed to write zip buffer to content.zip.")
  stdout.resetAttributes()
  quit(1)

# Extract zip file.
try:
  extractAll("content.zip", "unzipped")
  stdout.styledWriteLine(fgGreen, "Extracted content.zip to unzipped directory.")
  stdout.resetAttributes()
except:
  stdout.styledWriteLine(fgRed, "Failed to extract content.zip to unzipped.")
  stdout.resetAttributes()
  quit(1)

# Remove zip file.
try:
  removeFile("content.zip")
  stdout.styledWriteLine(fgGreen, "Removed content.zip file.")
  stdout.resetAttributes()
except:
  stdout.styledWriteLine(fgRed, "Failed to remove content.zip.")
  stdout.resetAttributes()
  quit(1)

# Find Template directory.
for file in walkDir("./unzipped"):
  if match(file.path, peg"unzipped\/LiberaTeMetuMortis\-KotlinSpigotPluginTemplate\-.+"):
    # Move Template directory to the main folder.
    try:
      moveDir(file.path, artifactID)
      stdout.styledWriteLine(fgGreen, "Moved Template directory to the main folder.")
      stdout.resetAttributes()
    except OSError:
      stdout.styledWriteLine(fgRed, "You already have a directory named "&artifactID&".")
      stdout.resetAttributes()
      quit(1)

# Remove unzipped folder.
try:
  removeDir("unzipped")
  stdout.styledWriteLine(fgGreen, "Removed unzipped folder.")
  stdout.resetAttributes()
except:
  stdout.styledWriteLine(fgRed, "Couldn't remove unzipped directory.")
  stdout.resetAttributes()
  quit(1)

# Create project's group directory.
let replacedGroupID = replace(groupID, '.', '/')
let projectDir = artifactID&"/project/src/main/kotlin/"&replacedGroupID
try:
  createDir(projectDir)
  stdout.styledWriteLine(fgGreen, "Created project's group directory.")
  stdout.resetAttributes()
except:
  stdout.styledWriteLine(fgRed, "Couldn't create "&projectDir&" directory.")
  stdout.resetAttributes()
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
  stdout.resetAttributes()
except: 
  stdout.styledWriteLine(fgRed, "Couldn't write into "&projectDir&"/"&artifactID&".kt.")
  stdout.resetAttributes()
  quit(1)

# Write artifact and group ID into build.gradle.kts.
var pluginConfig: File
if open(pluginConfig, artifactID&"/project/src/main/resources/plugin.yml", FileMode.fmAppend):
  writeLine(pluginConfig, "name: \""&artifactID&"\"")
  writeLine(pluginConfig, "main: \""&groupID&artifactID&"\"")
  stdout.styledWriteLine(fgGreen, "Wrote artifact and group ID into plugin.yml.")
  stdout.resetAttributes()
else:
  stdout.styledWriteLine(fgRed, "Couldn't open plugin.yml.")
  stdout.resetAttributes()
  quit(1)

# Write artifact ID and root project name into settings.gradle.kts.
var gradleConfig: File
if open(gradleConfig, artifactID&"/settings.gradle.kts", FileMode.fmAppend):
  writeLine(gradleConfig, "rootProject.name = "&"\""&artifactID&"\"")
  stdout.styledWriteLine(fgGreen, "Wrote artifact ID and root project name into settings.gradle.kts.")
  stdout.resetAttributes()
else:
  stdout.styledWriteLine(fgRed, "Couldn't open settings.gradle.kts.")
  stdout.resetAttributes()
  quit(1)
