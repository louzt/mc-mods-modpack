# INSTALL — Cómo instalar mc-mods-modpack en cliente

Esta guía cubre **Linux** y **Windows**. Si tu launcher es TLauncher,
Prism Launcher o el oficial de Mojang, los pasos son los mismos (el modpack
es del cliente, no del launcher).

## Pre-requisitos

1. **Java 21** instalado. Verifica con `java -version`:
   - Linux: usualmente `openjdk-21-jre` (Debian/Ubuntu) o equivalente.
   - Windows: descarga de <https://adoptium.net/> (Temurin 21 LTS).
2. **Minecraft Java Edition 1.21.4** instalado.
3. **Fabric Loader 0.17.2** para 1.21.4 — descárgalo desde
   <https://fabricmc.net/use/installer/>.

## Diagrama de rutas

```
                          ┌─────────────────────────────────┐
                          │  Tu Minecraft installation     │
                          │  (carpeta .minecraft)           │
                          └────────────────┬────────────────┘
                                           │
            ┌──────────────────────────────┼──────────────────────────────┐
            │                              │                              │
            ▼                              ▼                              ▼
    ┌──────────────┐              ┌──────────────┐               ┌──────────────┐
    │  mods/       │              │  config/     │               │  versions/   │
    │  (5 JARs)    │              │  (opcional)  │               │  fabric-…    │
    └──────────────┘              └──────────────┘               └──────────────┘
```

Solo necesitás los JARs de `mods/` para jugar. Los configs son del **server**
y no necesitás copiarlos localmente a menos que vayas a hostear tu propio
server con la misma config.

---

## Linux / macOS

### Rutas

| Item | Ruta |
|---|---|
| Minecraft root | `~/.minecraft/` |
| Mods | `~/.minecraft/mods/` |
| Logs | `~/.minecraft/logs/` |
| Configs | `~/.minecraft/config/` |

### Pasos

1. Descarga el `.zip` desde
   <https://github.com/louzt/mc-mods-modpack/releases/latest>.
2. Descomprime:

   ```bash
   cd ~/Downloads
   unzip mc-mods-modpack-v0.1.0.zip -d modpack-staging/
   ```

3. Copia los mods:

   ```bash
   mkdir -p ~/.minecraft/mods
   cp modpack-staging/mods/*.jar ~/.minecraft/mods/
   ```

4. (Opcional) Copia los configs si vas a hostear local:

   ```bash
   cp -r modpack-staging/config/* ~/.minecraft/config/
   ```

5. Abre Minecraft → selecciona el perfil **fabric-loader-0.17.2-1.21.4**.

### Verificación rápida

```bash
ls -la ~/.minecraft/mods/ | grep -E "fabric-api|lithium|cloth-config|voicechat|bluemap"
```

Deberías ver los 5 JARs listados.

---

## Windows

### Rutas

| Item | Ruta |
|---|---|
| Minecraft root | `%APPDATA%\.minecraft\` |
| Mods | `%APPDATA%\.minecraft\mods\` |
| Logs | `%APPDATA%\.minecraft\logs\` |
| Configs | `%APPDATA%\.minecraft\config\` |

`%APPDATA%` típicamente resuelve a `C:\Users\<tu-usuario>\AppData\Roaming\`.

### Pasos

1. Descarga el `.zip` desde
   <https://github.com/louzt/mc-mods-modpack/releases/latest>.
2. Click derecho → "Extraer todo…" a una carpeta temporal (ej. `Downloads\modpack-staging`).
3. Abrí el Explorador de Windows y navegá a `%APPDATA%\.minecraft\`.
   Truco rápido: presioná `Win+R`, escribí `%APPDATA%\.minecraft` y Enter.
4. Si la carpeta `mods` no existe, creala.
5. Copiá los 5 JARs desde `Downloads\modpack-staging\mods\` a `%APPDATA%\.minecraft\mods\`.
6. (Opcional) Copiá el contenido de `config\` a `%APPDATA%\.minecraft\config\`.
7. Abrí Minecraft → perfil **fabric-loader-0.17.2-1.21.4**.

### PowerShell verification rápida

```powershell
Get-ChildItem $env:APPDATA\.minecraft\mods | Where-Object { $_.Name -match "fabric-api|lithium|cloth-config|voicechat|bluemap" }
```

Deberías ver los 5 JARs.

---

## Solución de problemas

### "El juego crashea al cargar"

Probablemente falta Fabric Loader o Java 21. Verifica:

- `java -version` debe reportar 17 o superior.
- En el launcher, el perfil seleccionado debe ser **fabric-loader-0.17.2-1.21.4**,
  NO el perfil default de Minecraft.

### "El server me dice que tengo una versión incorrecta"

El server corre Fabric 1.21.4. Verificá que tu perfil de Fabric corresponda a
esa versión, no 1.21.5 o 1.21.3.

### "No puedo conectar / connection refused"

1. ¿Tu launcher soporta **multiplayer clasico** sin Microsoft Account?
   - **TLauncher** ✓ (usado por defecto en minecr4ft).
   - **Prism Launcher** ✓ (en modo offline).
   - **Minecraft Official** requiere Microsoft Account.
2. El server usa `online-mode=false`, así que cualquier username es aceptado
   siempre que esté en la whitelist del server.

### "El chat de voz no funciona"

Simple Voice Chat requiere que el puerto UDP **24455** esté abierto en tu
firewall/router. La mayoría de redes hogareñas lo permite por defecto, pero
algunas redes corporativas lo bloquean.

---

## Desinstalar

Borrá los 5 JARs de la carpeta `mods/` y reiniciá Minecraft. Los configs del
server no afectan tu cliente.
