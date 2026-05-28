plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sleep_tracker_app"

    // Рекомендуется использовать 35, пока 36 в статусе Preview,
    // но если плагины требуют 36, оставляем так:
    compileSdk = 36

    // ИСПРАВЛЕНИЕ: Устанавливаем стабильную версию NDK (LTS)
    // Версия 28.x часто вызывает 'Access violation' с CMake 3.22
    ndkVersion = "28.2.13676358"

    // ДОБАВЛЕНО: Указание версии CMake
    externalNativeBuild {
        cmake {
            version = "4.1.2" // Или "3.26.0", если вы скачали её в SDK Manager
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.sleep_tracker_app"
        minSdk = 24 // Рекомендуется указать явно вместо flutter.minSdkVersion для JNI
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
