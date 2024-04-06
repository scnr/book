# Maintain a valid session

SCNR supports automated logout detection and re-login, as well as improved login procedures.

* [Form-based login](#login_form-plugin)
* [Script-based login](#login_script-plugin)
* [Proxy-based login](#proxy-plugin)
* [Cookie-jar login](#cookie-jar)

## login_form plugin

The `login_form` plugin expects for following options:

* `url` -- The URL containing the login form;
* `parameters` -- A URL-query-like string of form parameters;
* `check` -- A pattern to be matched against the response body after requesting
  the supplied URL in order to verify a successful login.

After a successful login, the plugin will configure the system-wide session manager
and let it know of the procedure it needs to follow in order to be able to login
automatically, in case it gets logged out during the scan or the session expires.

**Hint:** If the response of the form submission doesn't contain the `check`, 
you can set a different check URL via the global `--session-check-url` option, 
this will also require that a `--session-check-pattern` be set as well (it can 
be the same as the autologin `check` option).

### Limitations

This plugin operates a browser just like a regular user would and is thus limited
to the same extent.

For example, if the login form is by default hidden and requires a sequence of UI
interactions in order to become visible, this plugin will not be able to submit it.

For more complex sequences please use the [login_script](#login_script-plugin) plugin.

### Example

    bin/scnr http://testfire.net --plugin=login_form:url=http://testfire.net/bank/login.aspx,parameters="uid=jsmith&passw=Demo1234",check="Sign Off|MY ACCOUNT" --scope-exclude-pattern=logout

The login form found in `http://testfire.net/bank/login.aspx` which contains the
`uid` and `passw` inputs will be **updated** with the given values and submitted.

After that, the response will be matched against the `check` pattern -- which will
also be used for the duration of the scan to check whether or not the session is still valid.

(Since the "Sign Off" and "MY ACCOUNT" strings only appear when the user is logged-in, 
they are a reliable way to check the validity of the session.)

Lastly, we **exclude** (`--scope-exclude-pattern`) the logout link from the audit in order to avoid getting logged out.

## login_script plugin

The `login_script` plugin can be used to specify custom login procedures, as simple
Ruby or JS scripts, to be executed prior to the scan and each time a logout is detected.

The script will be run under the context of a plugin, which means that it will 
have access to all system components, allowing you to login in the most optimal
way -- be that via a real browser, via HTTP requests, by loading an external 
cookie-jar file and many more.

### With browser

If a [browser](http://watir.com/) is available, it will be exposed to the script
via the `browser` variable. Otherwise, that variable will have a value of `nil`.

If you require access to Selenium, `browser.wd` will provide you access to the appropriate `WebDriver`.

```ruby
browser.goto 'http://testfire.net/bank/login.aspx'

form = browser.form( id: 'login' )
form.text_field( name: 'uid' ).set 'jsmith'
form.text_field( name: 'passw' ).set 'Demo1234'

form.submit

# You can also configure the session check from the script, dynamically,
# if you don't want to set static options via the user interface.
SCNR::Engine::Options.session.check_url     = browser.url
SCNR::Engine::Options.session.check_pattern = /Sign Off|MY ACCOUNT/
```

### With HTTP Client

If a real browser environment is not required for the login operation, then using 
the system-wide HTTP interface is preferable, as it will be much faster and consume 
much less resources.

```ruby
response = http.post( 'http://testfire.net/bank/login.aspx',
    parameters:     {
        'uid'   => 'jsmith',
        'passw' => 'Demo1234'
    },
    mode:           :sync,
    update_cookies: true
)

SCNR::Engine::Options.session.check_url     = to_absolute( response.headers.location, response.url )
SCNR::Engine::Options.session.check_pattern = /Sign Off|MY ACCOUNT/
```

### From cookie-jar

If an external process is used to manage sessions, you can keep SCNR in sync by
loading cookies from a shared Netscape-style cookie-jar file.

```ruby
http.cookie_jar.load 'cookies.txt'
```

### Advanced session check configuration

In addition to just setting the `check_url` and `check_pattern` options, you can
also set arbitrary HTTP request options for the login check, to cover cases where
extra tokens or a method other than `GET` must be used.

```ruby
framework.session.check_options = {
    # :get, :post, :put, :delete
    method:     :post,

    # URL query parameters.
    parameters: {
        'param1' => 'value'
    },

    # Request body parameters -- can also be a String instead of Hash.
    body:       {
        'body_param1' => 'value'
    },

    cookies:    {
        'custom_cookie' => 'value'
    },

    headers:    {
        'X-Custom-Header' => 'value'
    }
}
```

## Proxy plugin

The `proxy` plugin can be used to train the system by inspecting the traffic
exchanged between the browser and the web application. From that traffic, it can
extract input vectors like links, forms and cookies from both sides -- i.e. from
server responses as well as browser requests.

Since the proxy can inspect all this traffic, it can be instructed to record a
login sequence and then deduce the login form and the values with which it was filled.

Like the `form_login` plugin, the `proxy` plugin will configure the system accordingly.

### Example

    bin/scnr http://testfire.net --plugin=proxy --scope-exclude-pattern=logout

You then need to configure your browser to use this proxy when connecting to the
webapp, press the _record_ button just before logging in and the _stop_ button after.

You'll then be presented with a simple wizard which will guide you through configuring
a login check and verifying that the deduced login sequence works properly.

Lastly, we **exclude** (`--scope-exclude-pattern=logout`) the logout link from the audit in order to avoid getting logged out.

## Cookie-jar

If the aforementioned techniques don't work for you, you can pass a cookie-jar and manually configure the login-check using the following options:

* `--http-cookie-jar`
* `--session-check-url`
* `--session-check-pattern`

This way SCNR will still be able to know if it gets logged out (which is helpful to several system components) but won't be able to log-in automatically.

Of course, you should still exclude any path that can lead to the destruction of the session.
