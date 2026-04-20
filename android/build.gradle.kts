allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Workaround: Flutter Gradle Plugin escapes spaces in Windows paths.
// Use Windows 8.3 short path to avoid the issue.
fun getShortPath(path: java.io.File): java.io.File {
    if (!System.getProperty("os.name").lowercase().contains("windows")) return path
    if (!path.absolutePath.contains(" ")) return path
    try {
        val process = Runtime.getRuntime().exec(
            arrayOf("cmd", "/c", "for %I in (\"${path.absolutePath}\") do @echo %~sI")
        )
        val result = process.inputStream.bufferedReader().readText().trim()
        process.waitFor()
        if (result.isNotEmpty() && !result.contains(" ")) {
            return java.io.File(result)
        }
    } catch (_: Exception) {}
    return path
}

val projectRoot = getShortPath(rootProject.projectDir.resolve("..").canonicalFile)
val newBuildDir = java.io.File(projectRoot, "build")
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    project.layout.buildDirectory.set(java.io.File(newBuildDir, project.name))
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
