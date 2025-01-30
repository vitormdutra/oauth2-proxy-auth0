# OAuth2-Proxy with Auth0

This guide provides a step-by-step guide on how to implement **OAuth2-Proxy** along with **Auth0** for access validation.

## Implementation

This implementation uses **Terraform** to provision **OAuth2-Proxy** on a **Kubernetes** cluster.

---
## Configuration in Auth0

### Creating an Application in Auth0

1. Access Auth0 and create a new application by selecting the **Regular Web Application** option.
2. In the application settings, in the **Application URIs** block, fill in the **Allowed Callback URLs** text box with the access URL followed by `/oauth2/callback`, without a trailing slash.

    **Example:**
    ```
    https://${URL}/oauth2/callback, https://${URL}/
    ```

3. In the **Allowed Logout URLs** text box, enter the logout URL:

    **Example:**
    ```
    https://${URL}/
    ```

4. For debugging purposes:

    ```
    https://${URL}.us.webtask.run/auth0-authentication-api-debugger
    ```

5. In the **APIs** tab, authorize the **Auth0 Management API** and add the following permissions:
    ```
    create:client_grants
    read:roles
    read:role_members
    ```

---

### Creating a Custom API in Auth0

1. Create a **Custom API**. 2. In the **RBAC Settings** block, enable the following options:
    - **Enable RBAC**
    - **Add Permissions in the Access Token**
3. In the **Access Settings** block, enable the **Allow Skipping User Consent** option.

---

### User Management in Auth0

1. Create a **Role** for validation in OAuth2-Proxy.

    **Example:**
    ```
    org:internal-tools:admin
    ```

2. Assign this **Role** to users who will have permission to access the application.

---

### Creating an Action in Auth0

1. In Auth0, create a new **Action** using the **Build from scratch** option.
2. Choose the **trigger**: **Login / Post Login**. 3. Configure the Action based on the following example:

    ```javascript
    exports.onExecutePostLogin = async (event, api) => {
        const namespace = '{namespace}/';
        const { ManagementClient } = require('auth0');

        const management = new ManagementClient({
            domain: event.secrets.domain,
            clientId: event.secrets.clientId,
            clientSecret: event.secrets.clientSecret,
        });

        let userRolesResponse = await management.users.getRoles({ id: event.user.user_id });
        let userRoles = userRolesResponse.data.map(role => role.name);
        let userRolesSet = new Set(userRoles);

        if (userRolesSet.has("org:internal-tools:admin")) {
            api.idToken.setCustomClaim('groups', ['admin']);
            api.idToken.setCustomClaim('company_groups', ['admin']);
            api.idToken.setCustomClaim(namespace + 'groups', ['admin']);
        }
        };
    ```

This configuration validates all Auth0 roles and defines permissions in the **id_token**, which will be used by **OAuth2-Proxy** for access control.

---

## OAuth2-Proxy Configuration

After uploading the **OAuth2-Proxy** application and trying to access it:
- Users with permission will be authenticated and will be able to access it normally.
- Users without permission will receive an **unauthorized access** warning.

---

## Conclusion

This guide covers the entire process for integrating **OAuth2-Proxy** with **Auth0**, ensuring secure authentication and role-based access control. With this configuration, only authorized users will be able to access the application.

If you have any questions or need support, please refer to the [official OAuth2-Proxy](https://oauth2-proxy.github.io/oauth2-proxy/) and [Auth0](https://auth0.com/docs) documentation.