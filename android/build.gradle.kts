allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            try {
                val getNamespace = androidExt.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(androidExt) == null) {
                    val setNamespace = androidExt.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespace.invoke(androidExt, "com.example.${project.name.replace("-", "_")}")
                }
            } catch (e: Exception) {
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
