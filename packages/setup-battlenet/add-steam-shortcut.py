"""Manage Battle.net as a non-Steam game shortcut in Steam."""
import os
import sys
import glob
import struct
import binascii

STEAM_DIR = os.path.expanduser("~/.local/share/Steam")
BATTLENET_APPID = 3735928559  # 0xDEADBEEF

def encode_string(key, value):
    return b"\x01" + key.encode() + b"\x00" + value.encode() + b"\x00"

def encode_dword(key, value):
    return b"\x02" + key.encode() + b"\x00" + struct.pack("<I", value)

def encode_section_start(key):
    return b"\x00" + key.encode() + b"\x00"

def encode_section_end():
    return b"\x08"

def build_shortcut(index, app_name, exe, start_dir, launch_options="", appid=None):
    if appid is None:
        unique = exe + app_name
        appid = binascii.crc32(unique.encode("utf-8")) | 0x80000000
    data = encode_section_start(str(index))
    data += encode_dword("appid", appid)
    data += encode_string("AppName", app_name)
    data += encode_string("Exe", exe)
    data += encode_string("StartDir", start_dir)
    data += encode_string("icon", "")
    data += encode_string("ShortcutPath", "")
    data += encode_string("LaunchOptions", launch_options)
    data += encode_dword("IsHidden", 0)
    data += encode_dword("AllowDesktopConfig", 1)
    data += encode_dword("AllowOverlay", 1)
    data += encode_dword("OpenVR", 0)
    data += encode_dword("Devkit", 0)
    data += encode_string("DevkitGameID", "")
    data += encode_dword("DevkitOverrideAppID", 0)
    data += encode_dword("LastPlayTime", 0)
    data += encode_string("FlatpakAppID", "")
    data += encode_section_start("tags")
    data += encode_section_end()
    data += encode_section_end()
    return data

def build_shortcuts_vdf(entries):
    data = encode_section_start("shortcuts")
    for i, entry in enumerate(entries):
        data += build_shortcut(i, **entry)
    data += encode_section_end()
    return data

def find_steam_user_dir():
    pattern = os.path.join(STEAM_DIR, "userdata", "*", "config")
    configs = glob.glob(pattern)
    if not configs:
        print("Error: No Steam user directories found. Log into Steam first.", file=sys.stderr)
        sys.exit(1)
    return max(configs, key=os.path.getmtime)

def find_proton_tool():
    """Find the best available GE-Proton tool name."""
    compat_dir = os.path.join(STEAM_DIR, "compatibilitytools.d")
    if os.path.isdir(compat_dir):
        tools = sorted(
            [d for d in os.listdir(compat_dir) if d.startswith("GE-Proton")],
            reverse=True,
        )
        if tools:
            return tools[0]
    return None

def set_compat_tool(appid, tool_name=None):
    if tool_name is None:
        tool_name = find_proton_tool()
    if tool_name is None:
        print("Warning: No GE-Proton found. Set Proton compatibility manually in Steam.", file=sys.stderr)
        return
    config_file = os.path.join(STEAM_DIR, "config", "config.vdf")
    if not os.path.exists(config_file):
        print(f"Warning: {config_file} not found. Set Proton manually in Steam.", file=sys.stderr)
        return
    with open(config_file, "r") as f:
        content = f.read()
    if '"CompatToolMapping"' not in content:
        print("Warning: CompatToolMapping not found. Set Proton manually in Steam.", file=sys.stderr)
        return
    if f'"{appid}"' in content:
        return
    entry = f'\n\t\t\t\t"{appid}"\n\t\t\t\t{{\n\t\t\t\t\t"name"\t\t"{tool_name}"\n\t\t\t\t\t"config"\t\t""\n\t\t\t\t\t"priority"\t\t"250"\n\t\t\t\t}}'
    idx = content.find('"CompatToolMapping"')
    brace = content.find("{", idx)
    content = content[:brace+1] + entry + content[brace+1:]
    with open(config_file, "w") as f:
        f.write(content)
    print(f"Set Proton compatibility to {tool_name}.")

def cmd_install():
    """Add Battle.net installer to Steam."""
    installer = os.path.expanduser("~/Games/battlenet/Battle.net-Setup.exe")
    if not os.path.exists(installer):
        print(f"Error: Installer not found at {installer}", file=sys.stderr)
        sys.exit(1)

    config_dir = find_steam_user_dir()
    shortcuts_file = os.path.join(config_dir, "shortcuts.vdf")

    if os.path.exists(shortcuts_file):
        print(f"Steam shortcuts already configured. Delete {shortcuts_file} to recreate.")
        sys.exit(1)

    data = build_shortcuts_vdf([{
        "app_name": "Battle.net",
        "exe": f'"{installer}"',
        "start_dir": f'"{os.path.dirname(installer)}"',
        "appid": BATTLENET_APPID,
    }])

    os.makedirs(os.path.dirname(shortcuts_file), exist_ok=True)
    with open(shortcuts_file, "wb") as f:
        f.write(data)

    set_compat_tool(BATTLENET_APPID)
    print("Added Battle.net installer to Steam.")

def cmd_finish():
    """Update shortcut from installer to launcher."""
    compat_dir = os.path.join(STEAM_DIR, "steamapps", "compatdata", str(BATTLENET_APPID), "pfx")
    launcher = os.path.join(compat_dir, "drive_c", "Program Files (x86)", "Battle.net", "Battle.net Launcher.exe")

    if not os.path.exists(launcher):
        print(f"Error: Battle.net Launcher not found at expected path.", file=sys.stderr)
        print(f"Expected: {launcher}", file=sys.stderr)
        print("Make sure you ran the installer through Steam first.", file=sys.stderr)
        sys.exit(1)

    config_dir = find_steam_user_dir()
    shortcuts_file = os.path.join(config_dir, "shortcuts.vdf")

    start_dir = os.path.dirname(launcher)
    data = build_shortcuts_vdf([{
        "app_name": "Battle.net",
        "exe": f'"{launcher}"',
        "start_dir": f'"{start_dir}"',
        "appid": BATTLENET_APPID,
    }])

    with open(shortcuts_file, "wb") as f:
        f.write(data)

    print("Updated Battle.net shortcut to use the launcher.")
    print("Restart Steam. Battle.net is ready.")

if __name__ == "__main__":
    commands = {"install": cmd_install, "finish": cmd_finish}
    if len(sys.argv) < 2 or sys.argv[1] not in commands:
        print("Usage: add-steam-shortcut [install|finish]")
        sys.exit(1)
    commands[sys.argv[1]]()
