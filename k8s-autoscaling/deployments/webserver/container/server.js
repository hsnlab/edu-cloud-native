var os = require("os");
var http = require('http');
var hostname = os.hostname();

const client = require('prom-client');
const registry = new client.Registry()
const prefix = 'seminar_'
client.collectDefaultMetrics({ register: registry, prefix})

const counter = new client.Counter({
  name: `${prefix}http_requests_total`,
  help: 'Counts the http requests received by the server',
  registers: [registry],
});


var handleRequest = async function(request, response) {
  if(request.url === '/metrics'){
    handleMetrics(registry, response)
  } else {
    console.log('Received request for URL: ' + request.url);
    let sum = 0;
    for(let i = 0; i < 500000; i++){
      sum += Math.atan(Math.sin(Math.cos(100)))
    }
    console.log(sum)
    counter.inc();
    response.writeHead(200);
    response.end('Hello World from ' + hostname + "!");
  }
};

const handleMetrics = async function(request, response) {
  console.log("Metrics query")
  response.writeHead(200);
  response.end(await registry.metrics());
}

var www = http.createServer(handleRequest);
www.listen(8080);

var metrics = http.createServer(handleMetrics)
metrics.listen(9090)