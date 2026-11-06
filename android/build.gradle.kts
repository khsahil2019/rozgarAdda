allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://artifactory.payu.in/artifactory/libs-release-local") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
            if (android != null) {
                if (android.namespace == null) {
                    android.namespace = project.group.toString()
                }
                android.compileSdkVersion(36)
            }
        }
    }
}
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
