#!/usr/bin/env python3
"""Local release preflight/build. Never prints configuration values or secrets."""
import argparse
import os
import re
from pathlib import Path
import subprocess
import sys
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]


def https(value, origin=False):
    try:
        url = urlsplit(value)
        host = url.hostname or ''
        return (url.scheme == 'https' and host and not url.username and not url.password
                and not url.query and not url.fragment
                and host not in {'localhost', '10.0.2.2', '127.0.0.1', '::1'}
                and not host.endswith(('.localhost', '.local'))
                and (not origin or url.path in {'', '/'}))
    except ValueError:
        return False


def preflight(platform, env):
    errors = []
    api = env.get('API_BASE_URL', '')
    trace = env.get('PUBLIC_TRACE_ORIGIN', '')
    host = env.get('TRACE_LINK_HOST', '')
    if not https(api):
        errors.append('API_BASE_URL: explicit non-local HTTPS URL required.')
    if not https(trace, origin=True):
        errors.append('PUBLIC_TRACE_ORIGIN: explicit HTTPS origin required.')
    try:
        if not host or host != urlsplit(trace).hostname:
            errors.append('TRACE_LINK_HOST: must match PUBLIC_TRACE_ORIGIN host.')
    except ValueError:
        errors.append('TRACE_LINK_HOST: invalid trace origin.')
    for name in ('USE_MOCKS', 'PAYMENT_SIMULATOR_ENABLED'):
        if env.get(name, 'false') != 'false':
            errors.append(name + ': must be false.')
    if platform == 'android':
        for name in ('MAPS_API_KEY', 'ANDROID_KEYSTORE_PATH', 'ANDROID_KEYSTORE_PASSWORD',
                     'ANDROID_KEY_ALIAS', 'ANDROID_KEY_PASSWORD'):
            if not env.get(name, '').strip():
                errors.append(name + ': required for Android release.')
        store = env.get('ANDROID_KEYSTORE_PATH', '')
        if store and not Path(store).is_absolute():
            errors.append('ANDROID_KEYSTORE_PATH: use an absolute path.')
        elif store and not Path(store).is_file():
            errors.append('ANDROID_KEYSTORE_PATH: keystore file does not exist.')
        # Gradle local.properties takes precedence over environment for these fields.
        local = ROOT / 'android/local.properties'
        if local.exists():
            for line in local.read_text().splitlines():
                match = re.match(r'^\s*TRACE_LINK_HOST\s*(?:=|:|\s)\s*(.*)$', line)
                if match and match.group(1).strip() != host:
                    errors.append('android/local.properties TRACE_LINK_HOST overrides the requested host.')
        if (ROOT / 'android/key.properties').exists():
            errors.append('android/key.properties exists: use it directly with Gradle or temporarily move it aside so this environment-only build cannot silently select different signing credentials.')
    else:
        # Release.xcconfig includes Secrets last. Honor its effective literal host/key.
        settings = {}
        for name in ('Release.xcconfig', 'Secrets.xcconfig'):
            path = ROOT / 'ios/Flutter' / name
            if path.exists():
                for line in path.read_text().splitlines():
                    if '=' in line and not line.lstrip().startswith('//'):
                        key, value = line.split('=', 1)
                        settings[key.strip()] = value.strip()
        if settings.get('TRACE_LINK_HOST') != host:
            errors.append('iOS TRACE_LINK_HOST in Release/Secrets.xcconfig must match requested host.')
        key = settings.get('MAPS_API_KEY', '')
        if not key or '$(' in key:
            errors.append('iOS Secrets.xcconfig must provide MAPS_API_KEY.')
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('platform', choices=['android', 'ios'])
    parser.add_argument('--preflight-only', action='store_true')
    args = parser.parse_args()
    errors = preflight(args.platform, os.environ)
    if errors:
        print('Release preflight failed:', file=sys.stderr)
        for error in errors:
            print('- ' + error, file=sys.stderr)
        return 2
    print('Release preflight passed. Signing/account authorization is verified by native build tools.')
    if args.preflight_only:
        return 0
    command = ['flutter', 'build', 'appbundle' if args.platform == 'android' else 'ipa', '--release']
    for name in ('API_BASE_URL', 'PUBLIC_TRACE_ORIGIN', 'TRACE_LINK_HOST'):
        command.append('--dart-define=' + name + '=' + os.environ[name])
    command.extend(['--dart-define=USE_MOCKS=false', '--dart-define=PAYMENT_SIMULATOR_ENABLED=false'])
    return subprocess.call(command, cwd=ROOT)


if __name__ == '__main__':
    sys.exit(main())
