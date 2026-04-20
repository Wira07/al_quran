allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// =============================================================================
// PERMANENT FIX: Flutter Gradle Plugin spaces-in-path bug (Windows)
// The plugin escapes spaces as "\ " (Unix-style) which fails on Windows.
// Solution: redirect build output to a drive-root path (no spaces),
// then copy APK back to the expected location for Flutter CLI.
// =============================================================================
val projectPath = rootProject.projectDir.absolutePath
val hasSpacesInPath = projectPath.contains(" ")

if (hasSpacesInPath) {
    val driveRoot = projectPath.substring(0, 3)
    val safeBuildDir = File(driveRoot, ".flutter_builds/al_quran")
    rootProject.layout.buildDirectory.set(safeBuildDir)
    subprojects {
        project.layout.buildDirectory.set(File(safeBuildDir, project.name))
    }
}

// After assembleDebug/Release, copy APK to where Flutter CLI expects it
if (hasSpacesInPath) {
    gradle.projectsEvaluated {
        val appProject = subprojects.find { it.name == "app" }
        appProject?.tasks?.configureEach {
            if (name.startsWith("assemble")) {
                doLast {
                    val actualApkDir = File(
                        project.layout.buildDirectory.get().asFile,
                        "outputs/flutter-apk"
                    )
                    val expectedApkDir = File(
                        rootProject.projectDir.resolve("..").canonicalFile,
                        "build/app/outputs/flutter-apk"
                    )
                    if (actualApkDir.exists() && actualApkDir.absolutePath != expectedApkDir.absolutePath) {
                        expectedApkDir.mkdirs()
                        actualApkDir.listFiles()?.filter { it.extension == "apk" }?.forEach {
                            it.copyTo(File(expectedApkDir, it.name), overwrite = true)
                        }
                    }
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
