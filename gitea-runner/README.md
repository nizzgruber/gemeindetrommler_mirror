# Gitea Act Runner (Oracle Cloud ARM64 / Docker)

Docker Compose Setup für den Gitea CI/CD Runner zum automatischen Bauen der Android-APKs.

## Schnellstart

1. **Token holen:**
   In Gitea unter **Website-Verwaltung** (oder Repo-Einstellungen) ➔ **Aktionen** ➔ **Runner** ➔ **Neuen Runner erstellen** das Registrierungs-Token kopieren.

2. **Konfiguration erstellen:**
   ```bash
   cp .env.example .env
   nano .env
   ```
   Dort das kopierte Token bei `GITEA_RUNNER_REGISTRATION_TOKEN` eintragen.

3. **Runner starten:**
   ```bash
   docker compose up -d
   ```

4. **Logs ansehen:**
   ```bash
   docker compose logs -f
   ```
