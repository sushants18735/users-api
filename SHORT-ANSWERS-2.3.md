# Short answers — Assignment 2.3

**1. Why is the access token short-lived (15 min) while the refresh token lives 7 days? What does refresh-token rotation with reuse detection protect against?**

An access token is stateless: the server verifies its signature and does not store it, so there is no way to revoke one copy without changing the signing secret. Keeping it to 15 minutes limits the damage if it leaks through logs, a browser or a proxy. The refresh token is stored server-side as a SHA-256 hash, so it can be revoked immediately and can safely live for 7 days. On every refresh we rotate it — issue a new token and revoke the old one — so a stolen refresh token cannot be used again after the legitimate client has refreshed. If the old token is presented a second time, reuse detection assumes theft and revokes the whole token family, forcing both the victim and the attacker to log in again.

**2. Why is the refresh token in an httpOnly SameSite=Strict cookie, and not in localStorage?**

`httpOnly` means JavaScript in the page can never read the cookie, so an XSS injection cannot steal the long-lived credential and send it to an attacker. `SameSite=Strict` means the browser will not attach the cookie to requests from other sites, which mitigates CSRF on the refresh and logout endpoints. The `Path=/api/v1/auth` scope stops the browser from sending it to the rest of the API, and `Secure` is enabled in production so it travels only over HTTPS. If we stored the refresh token in `localStorage`, any script running on the page (including a compromised dependency) could read and exfiltrate it, which is why the access token stays in JS memory and only the refresh token lives in the cookie.

**3. Explain the purpose of `state` and PKCE in your GitHub login.**

`state` is a random value stored in an httpOnly cookie and sent to GitHub; when GitHub redirects back we require the returned `state` to match. An attacker who tricks a user into starting a login with the attacker's account cannot complete it, because they cannot write the victim's `state` cookie — this stops CSRF / login forgery. PKCE adds a random `code_verifier` whose SHA-256 `code_challenge` is sent to GitHub in the authorize request; the verifier is only revealed in the server-to-server token exchange. A stolen `?code=` is therefore useless without the verifier, and the `client_secret` never leaves the server.

**4. Give one rule in your API that is RBAC and one that is ABAC, and explain why the second could not be expressed with roles alone.**

RBAC: `GET /api/v1/users` uses `requireRole('admin')` — the decision depends only on the role in the access token, so customers get 403 and admins get 200. ABAC: `GET /api/v1/users/:id` uses `requirePermission('users:read')`, whose policy allows an admin or the actor whose `id` equals `resource.id`. The second rule cannot be expressed with roles alone because every customer has the same role, but whether Sita may read profile A depends on a relationship between the actor and that particular resource — not on what Sita *is*. Encoding it as roles would require a distinct role for every user/resource pair, which is the "role explosion" problem; `can()` evaluates the attributes of the actor, resource and action at request time instead.
