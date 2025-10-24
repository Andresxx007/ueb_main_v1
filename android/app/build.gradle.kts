plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ubicatec_unificado"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.ubicatec_unificado"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ✅ Pasa el token leído del .env al Manifest
        manifestPlaceholders["MAPBOX_ACCESS_TOKEN"] = project.findProperty("MAPBOX_ACCESS_TOKEN") ?: ""
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ✅ Carga el token desde .env automáticamente
val dotenvFile = rootProject.file(".env")
if (dotenvFile.exists()) {
    dotenvFile.readLines().forEach { line ->
        if (line.startsWith("MAPBOX_ACCESS_TOKEN")) {
            val token = line.split("=")[1].trim()
            project.extensions.extraProperties["MAPBOX_ACCESS_TOKEN"] = token
        }
    }
}
