# Java

## Options

| Option | Description | Default | Example |
|--------|-------------|---------|---------|
| `path_start_with` | Only instrument classes whose path starts with this prefix | none | `com/example` |
| `path_ends_with` | Only instrument classes whose path ends with this suffix | none | `Controller` |
| `path_include_pattern` | Only instrument classes matching this regex pattern | none | `.*Service.*` |
| `path_exclude_pattern` | Exclude classes matching this regex pattern | none | `.*Test.*` |
| `source_directory` | Root directory containing source files | `src/main/java/` | `/path/to/src` |

## Install Middleware

`webapp/WEB-INF/web.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee 
         http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0">

    <filter>
        <filter-name>introspectorFilter</filter-name>
        <filter-class>com.ecsypno.introspector.middleware.IntrospectorFilter</filter-class>
    </filter>
    
    <filter-mapping>
        <filter-name>introspectorFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>

</web-app>
```

## Load Agent along with your webapp

```bash
MAVEN_OPTS="-javaagent:introspector.jar=path_start_with=com/example" mvn clean package tomcat7:run
```

## Verify

You should see this at the beginning:

```
[INTROSPECTOR] Initializing Codename SCNR Introspector agent...
[INTROSPECTOR] Setting up instrumentation.
```

And messages like this after initialization for each traced line:

```
[INTROSPECTOR] Injecting trace code for com/example/XssServlet.<init> line 11 in src/main/java//com/example/XssServlet.java
```

Finally, for an integration test, to make sure:

```bash
curl -i http://localhost:8080/ -H "X-Scnr-Engine-Scan-Seed:Test" -H "X-Scnr-Introspector-Trace:1" -H "X-SCNR-Request-ID:1"
```

At the end of the HTTP response you should be seeing something like:

```html
<!-- Test
{
    "platforms": ["java"],
    "execution_flow": {
        "points": [
            {
                "method_name": "doGet",
                "class_name": "com/example/SampleWebApp",
                "path": "src/main/java//com/example/SampleWebApp.java",
                "line_number": 16,
                "source": "        resp.setContentType(\"text/html\");",
                "file_contents": "package com.example;\n\nimport java.io.IOException;\nimport javax.servlet.ServletException;\nimport javax.servlet.annotation.WebServlet;\nimport javax.servlet.http.HttpServlet;\nimport javax.servlet.http.HttpServletRequest;\nimport javax.servlet.http.HttpServletResponse;\n\n@WebServlet(\"/\")\npublic class SampleWebApp extends HttpServlet {\n    @Override\n    protected void doGet(HttpServletRequest req, HttpServletResponse resp) \n            throws ServletException, IOException {\n\n        resp.setContentType(\"text/html\");\n\n        resp.getWriter().println(\"<html><body>\");\n        resp.getWriter().println(\"<ul>\");\n        resp.getWriter().println(\"<li><a href='/xss'>XSS</a></li>\");\n        resp.getWriter().println(\"<li><a href='/cmd'>OS Command Injection</a></li>\");\n        resp.getWriter().println(\"</ul>\");\n        resp.getWriter().println(\"</body></html>\");\n    }\n}"
            },
            [...]
        ]
    }
}
Test -->
```
