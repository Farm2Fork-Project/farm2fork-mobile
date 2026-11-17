import java.util.Properties

plugins {
    id("com.android.application")
    // Firebase Google Services plugin (reads google-services.json).
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Distribution signing is supplied locally or by CI; never fall back to debug keys.
val releaseKeys = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
fun releaseKey(name: String, env: String): String =
    releaseKeys.getProperty(name) ?: System.getenv(env) ?: ""
val releaseStore = releaseKey("storeFile", "ANDROID_KEYSTORE_PATH")
val releaseStorePassword = releaseKey("storePassword", "ANDROID_KEYSTORE_PASSWORD")
val releaseAlias = releaseKey("keyAlias", "ANDROID_KEY_ALIAS")
val releaseKeyPassword = releaseKey("keyPassword", "ANDROID_KEY_PASSWORD")
gradle.taskGraph.whenReady {
    if (allTasks.any { it.project == project && it.name.contains("Release") }) {
        if (listOf(releaseStore, releaseStorePassword, releaseAlias, releaseKeyPassword).any { it.isBlank() }) {
            throw GradleException("Release signing is missing. Configure storeFile, storePassword, keyAlias and keyPassword in android/key.properties or ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD. Debug signing is never used for release.")
        }
        if (!rootProject.file(releaseStore).isFile) {
            throw GradleException("Release keystore file does not exist. Check storeFile / ANDROID_KEYSTORE_PATH.")
        }
    }
}

val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

// Same HTTPS host as NEXT_PUBLIC_SITE_URL and backend PUBLIC_TRACE_ORIGIN.
val traceLinkHost = localProperties.getProperty("TRACE_LINK_HOST")
    ?: System.getenv("TRACE_LINK_HOST") ?: "farm2fork.tech"
require(Regex("^[A-Za-z0-9.-]+$").matches(traceLinkHost)) {
    "TRACE_LINK_HOST must be a host name without scheme, path, or port"
}

android {
    namespace = "com.farm2fork.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.farm2fork.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["traceLinkHost"] = traceLinkHost
    }

    signingConfigs {
        create("release") {
            if (releaseStore.isNotBlank()) storeFile = rootProject.file(releaseStore)
            storePassword = releaseStorePassword
            keyAlias = releaseAlias
            keyPassword = releaseKeyPassword
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
