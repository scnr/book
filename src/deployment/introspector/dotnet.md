# .NET

## Installation

### Install Middleware

Add to your project:

    dotnet add package Introspector.Web

### Install patcher

    dotnet tool install --global Introspector.CLI
    introspector

### Use in a Web Application

`Ecsypno.TestApp.csproj`:

```xml
  <ItemGroup>
    <PackageReference Include="Introspector.Web"/>
  </ItemGroup>
```

`Ecsypno.TestApp.cs`:

```csharp
using Introspector.Web.Extensions;
using System.Web;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

// Add Introspector middleware
app.UseIntrospector();

string ProcessQuery(string input)
{

    return input;
}

app.MapGet("/", () => "Hello, world!");
app.MapGet("/xss", (HttpContext context) =>
{
    var query = ProcessQuery(context.Request.Query["input"]);
    var response = $@"
        <html>
            <body>
                <h1>XSS Example</h1>
                <form method='get' action='/xss'>
                    <label for='input'>Input:</label>
                    <input type='text' id='input' name='input' value='{query}' />
                    <button type='submit'>Submit</button>
                </form>
                <p>{query}</p>
            </body>
        </html>";
    context.Response.ContentType = "text/html";
    return response;
});

app.Run();

```

```bash
dotnet run --project Ecsypno.TestApp -c Release
```

Should output `[INTROSPECTOR] Codename SCNR Introspector middleware initialized.` at the top.

## Patch

```bash
dotnet build Ecsypno.TestApp -c Release # Build first.
introspector Ecsypno.TestApp/bin/Release/ --path-ends-with Ecsypno.TestApp.dll --path-exclude-pattern "ref|obj"
# Processing: Ecsypno.TestApp/bin/Release/net8.0/Ecsypno.TestApp.dll
# Instrumenting Program.<Main>$ at dotnet-instrumentation-example/Ecsypno.TestApp/Program.cs:4
# Instrumenting Program.<Main>$ at dotnet-instrumentation-example/Ecsypno.TestApp/Program.cs:6
# Instrumenting Program.<Main>$ at dotnet-instrumentation-example/Ecsypno.TestApp/Program.cs:9
# Instrumenting Program.<Main>$ at dotnet-instrumentation-example/Ecsypno.TestApp/Program.cs:17
# Instrumenting Program.<Main>$ at dotnet-instrumentation-example/Ecsypno.TestApp/Program.cs:20
# Instrumenting Program.<Main>$ at dotnet-instrumentation-example/Ecsypno.TestApp/Program.cs:39
# Instrumenting Program.<<Main>$>g__ProcessQuery|0_0 at dotnet-instrumentation-example/Ecsypno.TestApp/Program.cs:14
```

## Verify

Run the Web App again:

```bash
dotnet run --project Ecsypno.TestApp -c Release --no-build
```

```bash
curl -i http://localhost:5055/xss?input=test -H "X-Scnr-Engine-Scan-Seed:Test" -H "X-Scnr-Introspector-Trace:1" -H "X-SCNR-Request-ID:1"
```

You should see something like this (the comments are the important part):

```html
HTTP/1.1 200 OK
Content-Length: 2135
Content-Type: text/html
Date: Sat, 11 Jan 2025 10:22:46 GMT
Server: Kestrel


        <html>
            <body>
                <h1>XSS Example</h1>
                <form method='get' action='/xss'>
                    <label for='input'>Input:</label>
                    <input type='text' id='input' name='input' value='test' />
                    <button type='submit'>Submit</button>
                </form>
                <p>test</p>
            </body>
        </html>
<!-- Test
{
  "data_flow": [],
  "execution_flow": {
    "points": [
      {
        "class_name": "Program",
        "method_name": "\u003C\u003CMain\u003E$\u003Eg__ProcessQuery|0_0",
        "path": "/home/zapotek/workspace/scnr/dotnet-instrumentation-example/Ecsypno.TestApp/Program.cs",
        "line_number": 14,
        "source": "    return input;",
        "file_contents": "using Introspector.Web.Extensions;\nusing System.Web;\n\nvar builder = WebApplication.CreateBuilder(args);\n\nvar app = builder.Build();\n\n// Add Introspector middleware\napp.UseIntrospector();\n\nstring ProcessQuery(string input)\n{\n\n    return input;\n}\n\napp.MapGet(\u0022/\u0022, () =\u003E \u0022Hello, world!\u0022);\n\n// Add an XSS example route with a form\napp.MapGet(\u0022/xss\u0022, (HttpContext context) =\u003E\n{\n    var query = ProcessQuery(context.Request.Query[\u0022input\u0022]);\n    var response = $@\u0022\n        \u003Chtml\u003E\n            \u003Cbody\u003E\n                \u003Ch1\u003EXSS Example\u003C/h1\u003E\n                \u003Cform method=\u0027get\u0027 action=\u0027/xss\u0027\u003E\n                    \u003Clabel for=\u0027input\u0027\u003EInput:\u003C/label\u003E\n                    \u003Cinput type=\u0027text\u0027 id=\u0027input\u0027 name=\u0027input\u0027 value=\u0027{query}\u0027 /\u003E\n                    \u003Cbutton type=\u0027submit\u0027\u003ESubmit\u003C/button\u003E\n                \u003C/form\u003E\n                \u003Cp\u003E{query}\u003C/p\u003E\n            \u003C/body\u003E\n        \u003C/html\u003E\u0022;\n    context.Response.ContentType = \u0022text/html\u0022;\n    return response;\n});\n\napp.Run();"
      }
    ]
  },
  "platforms": [
    "aspx"
  ]
}
Test -->
```
