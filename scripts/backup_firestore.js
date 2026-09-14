const https = require('https');
const fs = require('fs');
const path = require('path');

const PROJECT_ID = 'gemeinde-trommler';
const COLLECTIONS = ['News', 'Issues', 'CitizensForum', 'ContactMessages', 'Admins'];

function fetchCollection(collection) {
  return new Promise((resolve) => {
    const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${collection}?pageSize=300`;
    https.get(url, (res) => {
      let raw = '';
      res.on('data', (chunk) => raw += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(raw);
          if (json.documents) {
            resolve({ collection, status: 'OK', count: json.documents.length, documents: json.documents });
          } else if (json.error) {
            resolve({ collection, status: 'PERMISSION_OR_EMPTY', error: json.error.message, documents: [] });
          } else {
            resolve({ collection, status: 'EMPTY', count: 0, documents: [] });
          }
        } catch (e) {
          resolve({ collection, status: 'PARSE_ERROR', error: e.message, documents: [] });
        }
      });
    }).on('error', (err) => {
      resolve({ collection, status: 'NETWORK_ERROR', error: err.message, documents: [] });
    });
  });
}

async function runBackup() {
  console.log(`[Backup] Starte Sicherung fuer Firebase Projekt: ${PROJECT_ID}...`);
  const results = {};
  const backupDir = path.join(__dirname, '..', 'backups');
  if (!fs.existsSync(backupDir)) {
    fs.mkdirSync(backupDir, { recursive: true });
  }

  for (const col of COLLECTIONS) {
    process.stdout.write(`[Backup] Lade ${col}... `);
    const res = await fetchCollection(col);
    results[col] = res;
    console.log(`${res.status} (${res.documents ? res.documents.length : 0} Dokumente)`);
  }

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const filename = `firestore_backup_${timestamp}.json`;
  const filePath = path.join(backupDir, filename);

  fs.writeFileSync(filePath, JSON.stringify(results, null, 2), 'utf-8');
  console.log(`\n[Backup] Erfolgreich gespeichert in: ${filePath}`);
}

runBackup();
