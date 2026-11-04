# Security

Please report a security problem privately, not in a public issue: use **Security > Report a vulnerability** on this repository.

Never put a license secret (`LICENSE_SECRET`), a key file, a server key, an access token, a password, an encryption key or a backup archive in an issue, a pull request or a log you paste. Redact them first. If you posted one by mistake, treat it as leaked: rotate it.

This repository mirrors a compose file and guides. Vulnerabilities in Pitstop's images, in Minimal or in the license relay themselves also go through the private report above, or to Littlebit Labs through the [license portal](https://license.littlebitlabs.com).

Pitstop is built for evaluation: plain HTTP on localhost by default, HTTPS in lan and domain modes. It is not a hardened production platform. The guide's operating section says what the backup archive contains (every secret of the installation) and how to protect it.
