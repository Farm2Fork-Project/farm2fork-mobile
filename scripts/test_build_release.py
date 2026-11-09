import tempfile
from pathlib import Path
import unittest
from unittest.mock import patch
import build_release


class ReleasePreflightTests(unittest.TestCase):
    def test_missing_config_fails_without_echoing_values(self):
        errors = build_release.preflight('android', {})
        self.assertTrue(any('API_BASE_URL' in error for error in errors))
        self.assertTrue(any('ANDROID_KEYSTORE_PATH' in error for error in errors))

    def test_urls_and_boolean_validation(self):
        for url in ('http://example.com', 'https://localhost', 'https://u:secret@example.com', 'https://example.com?a=1'):
            self.assertFalse(build_release.https(url))
        self.assertFalse(build_release.https('https://example.com/path', origin=True))

    def test_android_valid_config_and_host_override(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'android').mkdir()
            store = root / 'release.jks'
            store.touch()  # Presence only; native signing verifies contents.
            env = {'API_BASE_URL': 'https://api.example.com/api', 'PUBLIC_TRACE_ORIGIN': 'https://example.com',
                   'TRACE_LINK_HOST': 'example.com',
                   'ANDROID_KEYSTORE_PATH': str(store), 'ANDROID_KEYSTORE_PASSWORD': 'test-secret',
                   'ANDROID_KEY_ALIAS': 'test-alias', 'ANDROID_KEY_PASSWORD': 'test-secret'}
            with patch.object(build_release, 'ROOT', root):
                self.assertEqual(build_release.preflight('android', env), [])
                self.assertTrue(build_release.preflight('android', {**env, 'USE_MOCKS': 'true'}))
                (root / 'android/local.properties').write_text('TRACE_LINK_HOST = wrong.example.com\n')
                errors = build_release.preflight('android', env)
                self.assertTrue(errors)
                self.assertNotIn('test-secret', str(errors))

    def test_ios_native_host_required(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            folder = root / 'ios/Flutter'
            folder.mkdir(parents=True)
            env = {'API_BASE_URL': 'https://api.example.com/api', 'PUBLIC_TRACE_ORIGIN': 'https://example.com', 'TRACE_LINK_HOST': 'example.com'}
            with patch.object(build_release, 'ROOT', root):
                self.assertTrue(build_release.preflight('ios', env))
                (folder / 'Release.xcconfig').write_text('TRACE_LINK_HOST = example.com\n')
                self.assertEqual(build_release.preflight('ios', env), [])


if __name__ == '__main__':
    unittest.main()
