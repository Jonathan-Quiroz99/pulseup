# 1. IMAGEN BASE: Empezamos desde una imagen limpia de Ubuntu
FROM ubuntu:22.04

# 2. ARGUMENTOS: Definimos la versión de Flutter que queremos
ARG FLUTTER_VERSION=3.24.0

# 3. EVITAR PREGUNTAS INTERACTIVAS: Esto es para que la instalación sea automática
ENV DEBIAN_FRONTEND=noninteractive

# 4. INSTALAR DEPENDENCIAS DEL SISTEMA
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    xz-utils \
    zip \
    libglu1-mesa \
    libstdc++6 \
    openjdk-17-jdk-headless \
    clang \
    cmake \
    ninja-build \
    bash \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 5. INSTALAR FLUTTER SDK
RUN git clone https://github.com/flutter/flutter.git --depth 1 --branch ${FLUTTER_VERSION} /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"

# 6. CONFIGURACIÓN DE ANDROID SDK (VERSIÓN CORREGIDA)
# Crear directorio para Android SDK
RUN mkdir -p /opt/android-sdk/cmdline-tools
WORKDIR /opt/android-sdk/cmdline-tools

# Descargar Android Command Line Tools (versión más reciente y estable)
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip \
    && unzip -q tools.zip \
    && rm tools.zip \
    && mv cmdline-tools latest \
    && chmod +x latest/bin/*

# Configurar variables de entorno para Android
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${PATH}"

# Verificar que sdkmanager existe y es ejecutable
RUN ls -la ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/ || true

# Instalar componentes de Android (con manejo de errores)
RUN yes Y | sdkmanager --licenses --sdk_root=${ANDROID_SDK_ROOT} || true
RUN sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# 7. CONFIGURACIÓN FINAL DE FLUTTER
RUN flutter doctor --android-licenses --yes || true
RUN flutter precache

# 8. ESTABLECER DIRECTORIO DE TRABAJO
WORKDIR /app

# 9. COMANDO POR DEFECTO
CMD ["flutter", "doctor", "-v"]