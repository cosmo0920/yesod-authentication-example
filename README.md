yesod-auth-sample
===

An example Yesod authentication skeleton application.

### Prepare Google Login

This application uses GoogleEmail2 Yesod authentication plugin.
So, he/she wants to use this application try the following procedure to get client id and client secret for Google Login system:

> In order to use this plugin:

>    Create an application on the Google Developer Console https://console.developers.google.com/
>    Create OAuth credentials. The redirect URI will be http://yourdomain/auth/page/googleemail2/complete. (If you have your authentication subsite at a different root than /auth/, please adjust accordingly.)
>    Enable the Google+ API.

ref: https://hackage.haskell.org/package/yesod-auth-1.4.15/docs/Yesod-Auth-GoogleEmail2.html#g:2

And then fill the following variables in `.env`.
(Please replace `YOUR_CLIENT_ID` and `YOUR_CLIENT_SECRET` with your obtained client id and secret and save as `.env`):

```bash
GOOGLE_LOGIN_CLIENT_ID=YOUR_CLIENT_ID
GOOGLE_LOGIN_CLIENT_SECRET=YOUR_CLIENT_SECRET
```

### Related Articles

* Yesodでの認証のしくみについて
http://qiita.com/cosmo0920/items/1abeffb52eaabcd007f9

### LICENSE

[MIT](LICENSE).
