plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.googlemaps"
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
        applicationId = "com.example.googlemaps"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21  // ⬅️ Diubah dari flutter.minSdkVersion ke 21 (minimal untuk google_maps_flutter)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // ⬇️ TAMBAHKAN KONFIGURASI INI untuk Google Maps
        manifestPlaceholders += [
            'appAuthRedirectScheme': 'com.example.googlemaps'
        ]
        
        // MultiDex untuk mendukung banyak library (opsional tapi direkomendasikan)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // ⬇️ OPSIONAL: Optimasi untuk release build
            minifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            // ⬇️ Enable untuk debugging yang lebih baik
            debuggable = true
        }
    }
    
    // ⬇️ TAMBAHKAN BAGIAN INI untuk packaging options
    packagingOptions {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "/META-INF/DEPENDENCIES"
            excludes += "/META-INF/LICENSE"
            excludes += "/META-INF/LICENSE.txt"
            excludes += "/META-INF/license.txt"
            excludes += "/META-INF/NOTICE"
            excludes += "/META-INF/NOTICE.txt"
            excludes += "/META-INF/notice.txt"
            excludes += "/META-INF/ASL2.0"
        }
    }
}

flutter {
    source = "../.."
}

// ⬇️ TAMBAHKAN DEPENDENCIES JIKA PERLU
dependencies {
    // Untuk MultiDex support
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Untuk Play Services (diperlukan untuk beberapa fitur Google Maps)
    implementation("com.google.android.gms:play-services-location:21.2.0")
}