import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.amobi.drinkwater.drink_water"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.dsp.smartdrinkai"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val debugKeystorePropertiesFile = rootProject.file("debug_keystore.properties")
    val debugKeystoreProperties = Properties()
    debugKeystoreProperties.load(FileInputStream(debugKeystorePropertiesFile))
    val keystorePropertiesFile = rootProject.file(debugKeystoreProperties["productKeyPath"] as String)

    signingConfigs {
        getByName("debug") {
            keyAlias = debugKeystoreProperties["keyAlias"] as String
            keyPassword = debugKeystoreProperties["keyPassword"] as String
            storeFile = file(debugKeystoreProperties["storeFile"] as String)
            storePassword = debugKeystoreProperties["storePassword"] as String
        }
        create("release") {
            keyAlias = debugKeystoreProperties["keyAlias"] as String
            keyPassword = debugKeystoreProperties["keyPassword"] as String
            storeFile = file(debugKeystoreProperties["storeFile"] as String)
            storePassword = debugKeystoreProperties["storePassword"] as String
        }
        create("productRelease") {
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            } else {
                keyAlias = debugKeystoreProperties["keyAlias"] as String
                keyPassword = debugKeystoreProperties["keyPassword"] as String
                storeFile = file(debugKeystoreProperties["storeFile"] as String)
                storePassword = debugKeystoreProperties["storePassword"] as String
            }
        }
    }

    flavorDimensions += "environment"

    productFlavors {
        create("alpha") {
            dimension = "environment"
            applicationIdSuffix = ""
            resValue("string", "app_name", "Drink Water Alpha")
            ndk {
                abiFilters += listOf("arm64-v8a")
            }
        }
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ""
            resValue("string", "app_name", "Drink Water Dev")
            ndk {
                abiFilters += listOf("arm64-v8a")
            }
        }
        create("product") {
            dimension = "environment"
            resValue("string", "app_name", "Drink Water")
            signingConfig = signingConfigs.getByName("productRelease")
        }
        create("claude") {
            dimension = "environment"
            applicationIdSuffix = ""
            resValue("string", "app_name", "Drink Water Claude")
            signingConfig = signingConfigs.getByName("release")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-firestore")
}
