(function() {
  var HOST, PORT, SITE_ROOT, express, fs, jade, path, server, sys, url;
  sys = require("sys");
  url = require("url");
  path = require("path");
  fs = require("fs");
  require.paths.push('/usr/local/lib/node');
  express = require('express');
  jade = require('jade');
  HOST = "localhost";
  PORT = "8080";
  SITE_ROOT = process.cwd() + '/';
  server = express.createServer();
  server.configure(function() {
    server.set('views', __dirname);
    server.set('partials', __dirname);
    server.set('view engine', 'jade');
    server.use(express.logger());
    server.use(express.bodyDecoder());
    server.use(express.methodOverride());
    server.use(express.staticProvider(__dirname));
    return server.use(server.router);
  });
  server.configure('development', function() {
    return server.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
  });
  server.configure('production', function() {
    return express.errorHandler();
  });
  server.get('/', function(req, res) {
    return res.render('about', {
      locals: {
        title: 'Home',
        content: res.partial('home')
      }
    });
  });
  server.get('/about', function(req, res) {
    return res.render('layout', {
      locals: {
        title: 'About',
        content: res.partial('about')
      }
    });
  });
  server.listen(PORT, HOST);
  sys.puts("Server running at " + HOST + ":" + PORT);
}).call(this);
