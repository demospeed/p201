# Http Server
$http = [System.Net.HttpListener]::new() 

$http.Prefixes.Add("http://localhost:9595/")

$http.Start()

if ($http.IsListening) {
    write-host " HTTP Server Ready!  " -f 'black' -b 'gre'
    write-host "now try going to $($http.Prefixes)" -f 'y'
    write-host "then try going to $($http.Prefixes)other/path" -f 'y'
}

try {
    while ($http.IsListening) {

        $contextTask = $http.GetContextAsync()

        while (-not $contextTask.AsyncWaitHandle.WaitOne(200)) { }
        $context = $contextTask.GetAwaiter().GetResult()


        # ROUTE EXAMPLE 1
        if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/') {

            # We can log the request to the terminal
            write-host "$($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'

            [string]$html = "<h1>A Powershell Webserver Hari</h1>" 

            #resposed to the request
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html) 
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length) 
            $context.Response.OutputStream.Close()
        }

    }
}
finally {
    $http.Stop()
}
