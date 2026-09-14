const fs = require('fs');
const path = require('path');

async function main() {
  const token = process.env.GITEA_TOKEN;
  const repo = process.env.REPO;
  let apiUrl = (process.env.GITEA_API || 'https://git.djnizz.at/api/v1').replace(/\/$/, '');
  if (!apiUrl.includes('/api/v1')) {
    apiUrl += '/api/v1';
  }
  const tag = process.env.RELEASE_TAG || 'latest';
  const apksDir = path.resolve('release-apks');

  if (!token) {
    console.log('No GITEA_TOKEN provided, skipping direct release publishing.');
    return;
  }
  if (!fs.existsSync(apksDir)) {
    console.log('No release-apks directory found, skipping.');
    return;
  }

  const apkFiles = fs.readdirSync(apksDir).filter(f => f.endsWith('.apk'));
  if (apkFiles.length === 0) {
    console.log('No APK files found in release-apks, skipping.');
    return;
  }

  console.log(`Publishing ${apkFiles.length} APK(s) to Gitea release tag '${tag}'...`);

  // 1. Get or create release
  let release = null;
  const tagRes = await fetch(`${apiUrl}/repos/${repo}/releases/tags/${tag}`, {
    headers: { 'Authorization': `token ${token}` }
  });

  if (tagRes.ok) {
    release = await tagRes.json();
    console.log(`Found existing release (ID: ${release.id}) for tag '${tag}'.`);
  } else {
    console.log(`Release for tag '${tag}' does not exist, creating new release...`);
    const createRes = await fetch(`${apiUrl}/repos/${repo}/releases`, {
      method: 'POST',
      headers: {
        'Authorization': `token ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        tag_name: tag,
        name: `Oggauer Gemeindetrommler - ${tag.toUpperCase()}`,
        body: `Automatische Builds der Android APKs (Split per ABI).\nDirekte APK-Downloads ohne ZIP.`,
        draft: false,
        prerelease: false
      })
    });
    if (!createRes.ok) {
      console.warn(`Could not create release: ${createRes.status} ${await createRes.text()}`);
      return;
    }
    release = await createRes.json();
    console.log(`Created release with ID ${release.id}.`);
  }

  // 2. Query existing assets to delete duplicates
  const assetsRes = await fetch(`${apiUrl}/repos/${repo}/releases/${release.id}/assets`, {
    headers: { 'Authorization': `token ${token}` }
  });
  const existingAssets = assetsRes.ok ? await assetsRes.json() : [];

  // 3. Upload each APK
  for (const fileName of apkFiles) {
    const filePath = path.join(apksDir, fileName);
    const existing = existingAssets.find(a => a.name === fileName);
    if (existing) {
      console.log(`Deleting old asset ${fileName} (ID: ${existing.id})...`);
      await fetch(`${apiUrl}/repos/${repo}/releases/${release.id}/assets/${existing.id}`, {
        method: 'DELETE',
        headers: { 'Authorization': `token ${token}` }
      });
    }

    console.log(`Uploading ${fileName} (${(fs.statSync(filePath).size / (1024 * 1024)).toFixed(1)} MB)...`);
    const fileBytes = fs.readFileSync(filePath);
    const form = new FormData();
    form.append('attachment', new Blob([fileBytes]), fileName);

    const uploadRes = await fetch(`${apiUrl}/repos/${repo}/releases/${release.id}/assets?name=${encodeURIComponent(fileName)}`, {
      method: 'POST',
      headers: {
        'Authorization': `token ${token}`
      },
      body: form
    });

    if (uploadRes.ok) {
      const asset = await uploadRes.json();
      console.log(`✓ Uploaded ${fileName}: ${asset.browser_download_url || fileName}`);
    } else {
      console.warn(`Failed to upload ${fileName}: ${uploadRes.status} ${await uploadRes.text()}`);
    }
  }

  console.log('Finished publishing APKs to Gitea Releases!');
}

main().catch(err => {
  console.error('Error in publish_release.js:', err);
});
