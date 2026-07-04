# Git Deployment Instructions

## GitHub Secrets

To enable automatic deployment through GitHub Actions, configure the following repository secrets:

### How to add secrets in GitHub:

1. Go to the repository on GitHub
2. Open **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

### Required secrets:

| Secret                      | Description                                                              | Example value          |
|-----------------------------|--------------------------------------------------------------------------|------------------------|
| `PROJECT_NAME`              | Project name (used for naming Docker images)                             | `my-laravel-app`       |
| `DOCKER_HUB_ACCESS_TOKEN`   | Personal Access Token for GitHub Container Registry (ghcr.io)            | `ghp_xxxxxxxxxxxxx`    |

### How to create DOCKER_HUB_ACCESS_TOKEN:

1. Go to **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **Generate new token** → **Generate new token (classic)**
3. Set a token name (for example, "Docker Deploy Token")
4. Choose the token expiration period
5. Set the following permissions (scopes):
   - `write:packages` - to publish packages
   - `read:packages` - to read packages
   - `delete:packages` - to delete packages (optional)
6. Click **Generate token**
7. **Important:** Copy the token immediately. It will not be shown again!

## Working with tags

The automatic deployment workflow runs when a tag is created and pushed to the repository.

### Creating a tag

#### Option 1: Create an annotated tag (recommended)

```bash
# Create an annotated tag with a message
git tag -a v1.0.0 -m "Release version 1.0.0"

# Create a tag for a specific commit
git tag -a v1.0.0 -m "Release version 1.0.0" <commit-hash>
```

#### Option 2: Create a lightweight tag

```bash
# Create a lightweight tag
git tag v1.0.0

# Push a specific tag
git push origin v1.0.0

# Push all tags
git push origin --tags
```
## What happens when a tag is pushed

When a tag is pushed to the repository, the GitHub Actions workflow (`.github/workflows/deploy.yaml`) starts automatically and:

1. **Builds Docker images:**
   - PostgreSQL Database (`-db`)
   - Nginx Server (`-nginx`)
   - PHP Application (`-php`)
   - Queue Worker (`-worker`)
   - Task Scheduler (`-scheduler`)

2. **Publishes images to GitHub Container Registry:**
   - Images are available at: `ghcr.io/<owner>/<PROJECT_NAME>-<service>:<tag>`
   - Example: `ghcr.io/myuser/my-laravel-app-php:v1.0.0`

3. **Runs deployment** (configured in the `deploy` job)

## Checking deployment results

After pushing a tag:

1. Go to **Actions** on GitHub
2. Find the **"Docker Deploy"** workflow
3. Check the status of all jobs
4. Review the logs if there are errors

## Viewing published images

Published Docker images can be found:

1. In the GitHub repository: **Packages** (on the right side of the repository page)
2. At: `https://github.com/<owner>?tab=packages`
3. Or directly at: `ghcr.io/<owner>/<package-name>`

## Troubleshooting

### Authentication error in GitHub Container Registry

```
Error: denied: permission_denied
```

**Solution:**
- Check that `DOCKER_HUB_ACCESS_TOKEN` is added to the secrets
- Make sure the token has the `write:packages` permission
- Check that the token has not expired

### Workflow does not start

**Solution:**
- Make sure you pushed a tag: `git push origin <tag-name>`
- Check that the workflow file is located at `.github/workflows/deploy.yaml`
- Make sure Actions are enabled in the repository settings

### Tag already exists

```
fatal: tag 'v1.0.0' already exists
```

**Solution:**
- Use a new tag version
- Or delete the old tag and create it again:
  ```bash
  git tag -d v1.0.0
  git push origin --delete v1.0.0
  git tag -a v1.0.0 -m "New message"
  git push origin v1.0.0
  ```
