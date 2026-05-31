# FreeBuff Docker Sandbox

An isolated, high-security Docker sandbox environment for running [FreeBuff](https://www.npmjs.com/package/freebuff)—an AI terminal coding agent—safely on your local machine.

Running AI agents locally poses security risks, such as arbitrary command execution, unintended filesystem modification, or unauthorized network access. This sandbox is pre-configured with strict security baselines to contain those risks.

---

## 🔒 Security Architecture

This sandbox uses multi-layered security controls configured in [docker-compose.yml](./docker-compose.yml):

- **No Host Mounts**: Files from the host's `./workspace` directory are **copied** at build time (`COPY workspace/ /workspace/`) rather than bind-mounted. The AI agent cannot modify your host filesystem.
- **Low-Privilege User**: The container runs under a dedicated, non-root user (`USER freebuff`).
- **Privilege Escalation Prevention**: `security_opt: ["no-new-privileges:true"]` prevents processes from gaining new privileges via `setuid` or `sudo`.
- **Dropped Capabilities**: `cap_drop: ["ALL"]` strips all Linux kernel capabilities, preventing administrative actions or low-level network manipulation.
- **Resource Limits**:
  - `mem_limit: 4g` (4GB RAM limit)
  - `cpus: 4` (CPU allocation limit)
  - `pids_limit: 512` (Fork bomb prevention)
- **Isolated Networking**: Runs on a dedicated bridge network.

---

## 🚀 How to Use the Sandbox Securely

### 1. Prepare Your Workspace

Place **only** the target files you want the AI agent to edit inside the [workspace/](file:///Users/ravuthz/Projects/@oooo/tools/docker-freebuff/workspace) directory on your host machine.

> [!WARNING]
> Do **not** place sensitive secrets, private SSH keys, `.env` files with production credentials, or personal identification files inside the `workspace/` folder.

### 2. Build and run the Sandbox Image

Since files are copied during the build phase, you must rebuild the image whenever you modify the files in `./workspace` on the host:

```bash
docker compose build
```

Start the container and enter an interactive bash session:

```bash
docker compose run --rm freebuff
```

Or run this script

```bash
./start.sh
```

Inside the container, you can run `freebuff` to interact with the AI agent.

### 4. Review and Export Changes

Because the host directory is not mounted, any changes made by the AI agent remain isolated inside the container. To retrieve and review the modified files:

> [!IMPORTANT]
> Since the container runs with the `--rm` flag, it will be deleted immediately upon exit. You must copy the files **before** exiting the interactive container session.

1. Keep the interactive container session running in your first terminal.
2. Open a new terminal window on your host machine.
3. Run the following command to copy the modified workspace to a temporary review directory on your host:
   ```bash
   docker cp freebuff-sandbox:/workspace ./review-output
   ```
4. Use a diff tool (e.g., `git diff`) to inspect all changes in `./review-output` before manually merging them into your primary repository.
5. Exit the container session in your first terminal (e.g., type `exit` or `Ctrl+D`).

---

## ⚠️ Important Guidelines

> [!IMPORTANT]
>
> - **Never Bind Mount the Host**: Do not mount your active development project directory directly into the container using volumes (e.g., `-v`). Doing so allows the AI agent to write directly to your host machine, bypassing the security boundary.
> - **Verify Network Connections**: The container has outbound network access to connect to NPM, GitHub, and AI APIs. Avoid running agents on untrusted repositories that may attempt to exfiltrate data.
> - **Run Cleanup**: Once finished, run `docker compose down` to clean up leftover volumes and networks.
