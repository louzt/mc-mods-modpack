#!/usr/bin/env bash
# ~/Proyectos/Labs/minecr4ft-clientside/install-minecr4ft-client.sh
# Instala el modpack minecr4ft-loust-pro en este laptop para que pueda
# entrar al server con el perfil Fabric 1.21.4 + TLauncher / Mojang launcher.
#
# Idempotente: correlo varias veces, no rompe nada.
# Reversible: borra ~/.minecraft/mods/{fabric-api,lithium,cloth-config,
# voicechat,bluemap}-*.jar y re-corre para volver al estado base.
#
# Uso:
#   ./install-minecr4ft-client.sh                  # auto: descarga .zip
#   ./install-minecr4ft-client.sh /ruta/al/zip     # usa zip local
#   ./install-minecr4ft-client.sh --check          # solo verifica, no instala
#   ./install-minecr4ft-client.sh --sandbox DIR    # instala en DIR/.minecraft en vez de $HOME
#
# Salida:
#   - 5 JARs en ~/.minecraft/mods/
#   - Perfil launcher "mods-minecr4ft-loust-pro (Fabric 1.21.4)"
#   - Server "mods.minecr4ft.loust.pro" en servers.dat (si Mojang launcher)
#
set -euo pipefail

MINECRAFT_DIR="${HOME}/.minecraft"
SANDBOX_DIR=""
if [[ "${1:-}" == "--sandbox" ]]; then
    SANDBOX_DIR="${2:?sandbox dir required (e.g. /tmp/mc-sandbox)}"
    MINECRAFT_DIR="${SANDBOX_DIR}/.minecraft"
    mkdir -p "${SANDBOX_DIR}"
    shift 2
fi
MODPACK_VERSION="v0.1.0"
MODPACK_ZIP="mc-mods-modpack-${MODPACK_VERSION}.zip"
MODPACK_URL="https://github.com/louzt/mc-mods-modpack/releases/download/${MODPACK_VERSION}/${MODPACK_ZIP}"
LOCAL_MIRROR="https://mods.minecr4ft.loust.pro/downloads/${MODPACK_ZIP}"
TMP_DIR="/tmp/minecr4ft-modpack-$$"
EXPECTED_SHA256="52d82a325fdfeeb6dc290190c359ef85b9c674811a848874ae57db8f071fc7e9"

EXPECTED_MODS=(
    "fabric-api-0.119.4+1.21.4.jar"
    "lithium-fabric-0.15.3+mc1.21.4.jar"
    "cloth-config-17.0.144-fabric.jar"
    "voicechat-fabric-1.21.4-2.6.22.jar"
    "bluemap-5.7-fabric.jar"
)

red()   { printf '\033[31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
blue()  { printf '\033[34m%s\033[0m\n' "$*"; }

log_step() { blue "▶ $*"; }

# --- Sub-comando check ---
if [[ "${1:-}" == "--check" ]]; then
    log_step "Verificando instalación existente..."
    missing=0
    for mod in "${EXPECTED_MODS[@]}"; do
        if [[ -f "${MINECRAFT_DIR}/mods/${mod}" ]]; then
            green "  ✓ ${mod}"
        else
            red   "  ✗ ${mod} — falta"
            missing=$((missing + 1))
        fi
    done

    fabric_lib="${MINECRAFT_DIR}/libraries/net/fabricmc/fabric-loader/0.17.2/fabric-loader-0.17.2.jar"
    if [[ -f "${fabric_lib}" ]]; then
        green "  ✓ Fabric Loader 0.17.2 instalado"
    else
        red   "  ✗ Fabric Loader 0.17.2 — falta"
        missing=$((missing + 1))
    fi

    fabric_json="${MINECRAFT_DIR}/versions/Fabric 1.21.4/Fabric 1.21.4.json"
    if [[ -f "${fabric_json}" ]]; then
        green "  ✓ Fabric 1.21.4 version JSON instalado"
    else
        red   "  ✗ Fabric 1.21.4 version JSON — falta"
        missing=$((missing + 1))
    fi

    if [[ -f "${MINECRAFT_DIR}/servers.dat" ]]; then
        if grep -q "mods.minecr4ft.loust.pro:25566" "${MINECRAFT_DIR}/servers.dat" \
           2>/dev/null || python3 -c "
import gzip, struct, sys
try: data = open('${MINECRAFT_DIR}/servers.dat','rb').read()
except: sys.exit(0)
# raw NBT o gzip NBT
try: data = gzip.decompress(data)
except: pass
sys.exit(0 if b'mods.minecr4ft.loust.pro' in data else 1)
"; then
            green "  ✓ Server 'mods.minecr4ft.loust.pro' registrado en servers.dat"
        else
            red   "  ✗ Server NO registrado en servers.dat"
            missing=$((missing + 1))
        fi
    else
        red   "  ✗ servers.dat no existe"
        missing=$((missing + 1))
    fi

    if [[ ${missing} -eq 0 ]]; then
        green ""
        green "✓ TODO LISTO. Abrí Minecraft → perfil 'mods-minecr4ft-loust-pro (Fabric 1.21.4)'"
        exit 0
    else
        red ""
        red "✗ ${missing} componentes faltan. Correr ./install-minecr4ft-client.sh"
        exit 1
    fi
fi

# --- Helpers de launcher_profile + server (ambos launchers usan el mismo formato) ---
add_launcher_profile() {
    local profiles_json="${MINECRAFT_DIR}/launcher_profiles.json"
    if [[ ! -f "${profiles_json}" ]]; then
        log_step "launcher_profiles.json no existe — saltando (TLauncher puro?)"
        return 0
    fi

    local profile_id
    profile_id=$(python3 -c "import uuid; print(uuid.uuid5(uuid.NAMESPACE_OID, 'mods-minecr4ft-loust-pro-fabric1214'))")

    if python3 -c "
import json,sys
d=json.load(open('${profiles_json}'))
sys.exit(0 if '${profile_id}' in d.get('profiles',{}) else 1)
"; then
        green "  ✓ Perfil launcher ya existe (skip)"
        return 0
    fi

    python3 - <<PY
import json, time
p = "${profiles_json}"
data = json.load(open(p))
profile_id = "${profile_id}"
data.setdefault("profiles", {})[profile_id] = {
    "name": "mods-minecr4ft-loust-pro (Fabric 1.21.4)",
    "type": "custom",
    "created": time.strftime("%Y-%m-%dT%H:%M:%S.000Z", time.gmtime()),
    "lastUsed": time.strftime("%Y-%m-%dT%H:%M:%S.000Z", time.gmtime()),
    "icon": "Grass",
    "lastVersionId": "Fabric 1.21.4",
    "gameDir": "${MINECRAFT_DIR}",
}
json.dump(data, open(p, "w"), indent=2, ensure_ascii=False)
PY
    green "  ✓ Perfil launcher creado: mods-minecr4ft-loust-pro (Fabric 1.21.4)"
}

ensure_server_in_servers_dat() {
    local sd="${MINECRAFT_DIR}/servers.dat"
    [[ -f "${sd}" ]] || { log_step "servers.dat no existe — skip (TLauncher usa formato propio)"; return 0; }

    if grep -q "mods.minecr4ft.loust.pro:25566" "${sd}" 2>/dev/null; then
        green "  ✓ Server ya registrado en servers.dat"
        return 0
    fi

    # NBT parse: detecta si es gzip o raw
    python3 - <<PY
import struct, sys
p = "${sd}"
raw = open(p, "rb").read()
# Heurística: gzip magic 1f 8b
if raw[:2] == b"\x1f\x8b":
    import gzip
    data = gzip.decompress(raw)
    gz = True
else:
    data = raw
    gz = False

# Append: TAG_String "mods.minecr4ft.loust.pro" + TAG_String "mods.minecr4ft.loust.pro:25566"
# antes del TAG_End final (último byte 0x00).
end_idx = data.rfind(b"\x00")
if end_idx < 0 or data[end_idx:end_idx+1] != b"\x00":
    print("  ! no encontré TAG_End al final, appending anyway")
    end_idx = len(data)

def write_string(name, val):
    out = b"\x08" + struct.pack(">H", len(name)) + name.encode("utf-8")
    out += struct.pack(">H", len(val)) + val.encode("utf-8")
    return out

new_entry = (
    write_string("mods.minecr4ft.loust.pro", "mods.minecr4ft.loust.pro:25566")
    + write_string("hideAddress", "\x00")
    + write_string("acceptTextures", "\x00")
)
new_data = data[:end_idx] + new_entry + data[end_idx:]
if gz:
    import gzip
    open(p, "wb").write(gzip.compress(new_data))
else:
    open(p, "wb").write(new_data)
print("  ✓ Server 'mods.minecr4ft.loust.pro' agregado a servers.dat")
PY
}

# --- Pipeline principal ---
log_step "1/5 — Descargando modpack ${MODPACK_VERSION}"
mkdir -p "${TMP_DIR}"
ZIP_PATH="${TMP_DIR}/${MODPACK_ZIP}"

if [[ -n "${1:-}" && -f "${1}" ]]; then
    ZIP_PATH="$1"
    blue "  usando zip local: ${ZIP_PATH}"
elif [[ ! -f "${ZIP_PATH}" ]]; then
    for url in "${LOCAL_MIRROR}" "${MODPACK_URL}"; do
        if curl -fsSL --max-time 60 -o "${ZIP_PATH}" "${url}"; then
            blue "  descargado de: ${url}"
            break
        fi
        red "  falló ${url}, probando siguiente"
    done
fi

if [[ ! -f "${ZIP_PATH}" ]]; then
    red "No pude descargar el modpack. Pasalo como argumento:"
    red "  ./install-minecr4ft-client.sh /ruta/al/${MODPACK_ZIP}"
    exit 1
fi

log_step "2/5 — Verificando SHA256"
got_sha=$(sha256sum "${ZIP_PATH}" | awk '{print $1}')
if [[ "${got_sha}" != "${EXPECTED_SHA256}" ]]; then
    red "  SHA mismatch!"
    red "  esperado: ${EXPECTED_SHA256}"
    red "  recibido: ${got_sha}"
    exit 1
fi
green "  ✓ SHA256 OK"

log_step "3/5 — Extrayendo mods"
mkdir -p "${MINECRAFT_DIR}/mods"
unzip -j -o "${ZIP_PATH}" "mods/*.jar" -d "${MINECRAFT_DIR}/mods/" >/dev/null
ls -la "${MINECRAFT_DIR}/mods/" | tail -n +2

log_step "4/5 — Verificando los 5 mods"
fail=0
for mod in "${EXPECTED_MODS[@]}"; do
    if [[ -f "${MINECRAFT_DIR}/mods/${mod}" ]]; then
        green "  ✓ ${mod}"
    else
        red   "  ✗ ${mod} — falta"
        fail=1
    fi
done
[[ ${fail} -eq 0 ]] || { red "Faltan mods, abort."; exit 1; }

log_step "5/5 — Registrando perfil launcher + server"
add_launcher_profile
ensure_server_in_servers_dat

green ""
green "✓ Instalación completa. Próximos pasos:"
green "  1. Abrí Minecraft (TLauncher / Mojang / Prism — cualquiera sirve)"
green "  2. Si TLauncher: seleccioná 'Fabric 1.21.4' como versión"
green "  3. Si Mojang launcher: seleccioná el perfil 'mods-minecr4ft-loust-pro (Fabric 1.21.4)'"
green "  4. Multijugador → 'mods.minecr4ft.loust.pro:25566'"
green "  5. Username libre (online-mode=false). Pedile al operador que te agregue a whitelist."
green ""
green "  Diagnóstico: ./install-minecr4ft-client.sh --check"

# Cleanup
rm -rf "${TMP_DIR}"
