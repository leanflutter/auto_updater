import hashlib
import json
import re
import sys
import tarfile
import urllib.error
import urllib.request
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

import yaml

archives = Path(sys.argv[1])


class Registry(BaseHTTPRequestHandler):
    def reply(self, status, data, content_type):
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        metadata = re.fullmatch(r'/api/packages/([a-z0-9_]+)', self.path)
        if metadata:
            name = metadata.group(1)
            archive = archives / f'{name}.tar.gz'
            if archive.is_file():
                with tarfile.open(archive, 'r:gz') as contents:
                    spec = yaml.safe_load(contents.extractfile('pubspec.yaml'))
                version = str(spec['version'])
                data = {
                    'version': version,
                    'pubspec': spec,
                    'archive_url': f'http://127.0.0.1:{self.server.server_port}/archives/{name}.tar.gz',
                    'archive_sha256': hashlib.sha256(archive.read_bytes()).hexdigest(),
                    'published': datetime.now(timezone.utc).isoformat(),
                }
                self.reply(200, json.dumps({'name': name, 'latest': data, 'versions': [data]}).encode(), 'application/json')
                return
        download = re.fullmatch(r'/archives/([a-z0-9_]+)\.tar\.gz', self.path)
        if download:
            archive = archives / f'{download.group(1)}.tar.gz'
            if archive.is_file():
                self.reply(200, archive.read_bytes(), 'application/gzip')
                return
        if not self.path.startswith('/api/'):
            self.reply(404, b'{}', 'application/json')
            return
        try:
            with urllib.request.urlopen('https://pub.dev' + self.path, timeout=30) as upstream:
                self.reply(upstream.status, upstream.read(), upstream.headers.get('Content-Type', 'application/json'))
        except urllib.error.HTTPError as error:
            self.reply(error.code, error.read(), error.headers.get('Content-Type', 'application/json'))
        except (urllib.error.URLError, TimeoutError, OSError):
            self.reply(503, b'{}', 'application/json')


server = ThreadingHTTPServer(('127.0.0.1', 0), Registry)
Path(sys.argv[2]).write_text(str(server.server_port))
server.serve_forever()
