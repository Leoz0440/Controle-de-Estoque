plugins {
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false // Use sua versão real
    id("com.google.gms.google-services") version "4.4.4" apply false // <-- CORREÇÃO AQUI!
}
//...
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
