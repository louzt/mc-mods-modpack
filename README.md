# mc-mods-modpack

Modpack oficial para el servidor **mods.minecr4ft.loust.pro** (Fabric 1.21.4).

Distribución: este repo es la **fuente de verdad** del modpack. Se actualiza cada
vez que el operador agrega, quita o actualiza un mod en el cluster k3s.

## Contenido del .zip

```
mc-mods-modpack-v0.1.0.zip
├── mods/                              ← JARs para `~/.minecraft/mods/`
│   ├── fabric-api-0.119.4+1.21.4.jar
│   ├── lithium-fabric-0.15.3+mc1.21.4.jar
│   ├── cloth-config-17.0.144-fabric.jar
│   ├── voicechat-fabric-1.21.4-2.6.22.jar
│   └── bluemap-5.7-fabric.jar
├── config/                            ← configs tuned para el server
│   ├── lithium.properties
│   ├── bluemap/...
│   └── voicechat/...
├── fabric-server-launcher.jar         ← opcional, server-side
├── INSTALL.md                         ← instrucciones Linux + Windows
└── README.md                          ← este archivo
```

## Versión actual

`v0.1.0` — 2026-08-27. 5 mods + configs. Compatible con Minecraft Java Edition
1.21.4 + Fabric Loader 0.17.2.

## Mods incluidos

| Mod | Versión | Función |
|---|---|---|
| Fabric API | `0.119.4+1.21.4` | Runtime requerido por todos los mods Fabric |
| Lithium | `0.15.3` | Optimización de física y game logic (server + client) |
| Cloth Config | `17.0.144` | API de configuración para mods (requerido por Lithium/VoiceChat) |
| Simple Voice Chat | `2.6.22` | Voz en tiempo real dentro del juego (puerto UDP 24455) |
| BlueMap | `5.7` | Webapp de mapa 3D en vivo (accesible vía /map-mods/) |

## Cómo instalar (cliente)

### Vía script automático (recomendado)

```bash
curl -fsSL -o /tmp/install.sh \
  https://raw.githubusercontent.com/louzt/mc-mods-modpack/main/install.sh
bash /tmp/install.sh
```

El script:
- Descarga el .zip desde el mirror VPS (fallback a GitHub Release).
- Verifica SHA256.
- Extrae los 5 mods a `~/.minecraft/mods/`.
- Crea perfil launcher (Mojang launcher).
- Agrega server entry en `servers.dat`.

Diagnóstico sin instalar:

```bash
bash /tmp/install.sh --check
```

### Vía manual

Ver [`INSTALL.md`](./INSTALL.md) para instrucciones detalladas Linux vs Windows.

Resumen rápido:
1. Instala **Fabric Loader 0.17.2** para Minecraft 1.21.4 (descarga desde
   <https://fabricmc.net/use/installer/>).
2. Copia el contenido de `mods/` a tu carpeta `mods/` del cliente:
   - Linux: `~/.minecraft/mods/`
   - Windows: `%APPDATA%\.minecraft\mods\`
3. (Opcional) Si juegas en el server de `minecr4ft.loust.pro`, no necesitás
   los configs — el server ya los trae.

## Conexión al server

Una vez que tengas Fabric Loader + los mods instalados:
1. Abre Minecraft con el perfil **Fabric 1.21.4**.
2. Multijugador → Agregar server:
   - Dirección: `mods.minecr4ft.loust.pro`
   - Puerto: `25566`
3. Conecta. El primer jugador que entra despierta el server (cold-start ~60-90s).

> El server usa `online-mode=false`. Cualquier username es aceptado mientras
> esté en la whitelist del operador.

## Licencia

Los mods pertenecen a sus respectivos autores (todos open-source en Modrinth).
Este modpack es solo una compilación. Ver `LICENSE` para el repo wrapper.

- Fabric API — Apache 2.0 / MIT (FabricMC)
- Lithium — MIT (JellySquid)
- Cloth Config — Apache 2.0 (shedaniel)
- Simple Voice Chat — MIT (henkelmax)
- BlueMap — MIT (BlueMap contributors)

## Releases

Cada tag en este repo es un release estable del modpack. El operador publica un
nuevo release cuando cambia el contenido del server, y el .zip atado contiene
exactamente lo que está corriendo en producción.

Para reproducir localmente lo que está en el server:

```bash
gh release download v0.1.0
unzip mc-mods-modpack-v0.1.0.zip -d ~/.minecraft/
```
